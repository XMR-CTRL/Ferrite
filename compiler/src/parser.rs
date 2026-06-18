use syn::parse::{Parse, ParseStream};
use syn::{Ident, Expr, Token, braced, token};
use crate::ir::{UiNode, PropValue, DynamicProp};
use std::collections::HashSet;

pub struct AstNode {
    pub name: Ident,
    pub props: Vec<AstProp>,
    pub children: Vec<AstNode>,
}

pub struct AstProp {
    pub name: Ident,
    pub value: Expr,
}

impl Parse for AstNode {
    fn parse(input: ParseStream) -> syn::Result<Self> {
        let name: Ident = input.parse()?;
        let content;
        braced!(content in input);
        
        let mut props = Vec::new();
        let mut children = Vec::new();
        
        while !content.is_empty() {
            let member_name: Ident = content.parse()?;
            
            if content.peek(Token![:]) {
                content.parse::<Token![:]>()?;
                let value: Expr = content.parse()?;
                if content.peek(Token![,]) {
                    content.parse::<Token![,]>()?;
                }
                props.push(AstProp { name: member_name, value });
            } else if content.peek(token::Brace) {
                let inner;
                braced!(inner in content);
                let child = AstNode::parse_with_name(member_name, &inner)?;
                children.push(child);
                if content.peek(Token![,]) {
                    content.parse::<Token![,]>()?;
                }
            } else {
                return Err(content.error("Expected ':' for property or '{' for child node"));
            }
        }
        
        Ok(AstNode { name, props, children })
    }
}

impl AstNode {
    pub fn parse_with_name(name: Ident, content: ParseStream) -> syn::Result<Self> {
        let mut props = Vec::new();
        let mut children = Vec::new();
        
        while !content.is_empty() {
            let member_name: Ident = content.parse()?;
            
            if content.peek(Token![:]) {
                content.parse::<Token![:]>()?;
                let value: Expr = content.parse()?;
                if content.peek(Token![,]) {
                    content.parse::<Token![,]>()?;
                }
                props.push(AstProp { name: member_name, value });
            } else if content.peek(token::Brace) {
                let inner;
                braced!(inner in content);
                let child = AstNode::parse_with_name(member_name, &inner)?;
                children.push(child);
                if content.peek(Token![,]) {
                    content.parse::<Token![,]>()?;
                }
            } else {
                return Err(content.error("Expected ':' for property or '{' for child node"));
            }
        }
        
        Ok(AstNode { name, props, children })
    }
}

pub fn is_assign_op(op: &syn::BinOp) -> bool {
    matches!(op,
        syn::BinOp::AddAssign(_)
        | syn::BinOp::SubAssign(_)
        | syn::BinOp::MulAssign(_)
        | syn::BinOp::DivAssign(_)
        | syn::BinOp::RemAssign(_)
        | syn::BinOp::BitXorAssign(_)
        | syn::BinOp::BitAndAssign(_)
        | syn::BinOp::BitOrAssign(_)
        | syn::BinOp::ShlAssign(_)
        | syn::BinOp::ShrAssign(_)
    )
}

pub fn is_event_name(name: &str) -> bool {
    name.starts_with("On") || name == "Activated" || name == "MouseButton1Click" || name == "MouseEnter" || name == "MouseLeave"
}

/// AST-based dependency extractor - walks the expression tree to find state variable references
pub fn extract_state_deps_from_expr(expr: &Expr, state_vars: &HashSet<String>) -> Vec<String> {
    let mut deps = Vec::new();
    collect_state_deps(expr, state_vars, &mut deps);
    deps.sort();
    deps.dedup();
    deps
}

fn collect_state_deps(expr: &Expr, state_vars: &HashSet<String>, deps: &mut Vec<String>) {
    match expr {
        Expr::Path(path) => {
            let path_str = quote::quote!(#path).to_string().replace(" :: ", ".");
            // Check if this is a state variable reference
            if state_vars.contains(&path_str) {
                deps.push(path_str);
            }
        }
        Expr::Field(field) => {
            let base_str = expr_to_luau_with_state(&field.base, state_vars);
            let member_name = match &field.member {
                syn::Member::Named(ident) => ident.to_string(),
                syn::Member::Unnamed(index) => index.index.to_string(),
            };
            
            // Check if accessing state or props
            if base_str == "self.state" || base_str.starts_with("self.state.") {
                // Extract the field name
                if base_str == "self.state" {
                    deps.push(member_name);
                } else if base_str.starts_with("self.state.") {
                    // Already has self.state prefix - extract the key
                    let key = &base_str["self.state.".len()..];
                    deps.push(key.to_string());
                }
            }
            
            // Recurse into base
            collect_state_deps(&field.base, state_vars, deps);
        }
        Expr::MethodCall(method_call) => {
            // Check if this is state.get() or state.set()
            let receiver_str = expr_to_luau_with_state(&method_call.receiver, state_vars);
            let method_name = method_call.method.to_string();
            
            if method_name == "get" && state_vars.iter().any(|v| receiver_str.starts_with(v)) {
                // state.get() - dependency on this state var
                if let Some(arg) = method_call.args.first() {
                    if let Expr::Lit(lit) = arg {
                        if let syn::Lit::Str(s) = &lit.lit {
                            deps.push(s.value());
                        }
                    }
                }
            }
            
            // Recurse into receiver and args
            collect_state_deps(&method_call.receiver, state_vars, deps);
            for arg in &method_call.args {
                collect_state_deps(arg, state_vars, deps);
            }
        }
        Expr::Call(call) => {
            collect_state_deps(&call.func, state_vars, deps);
            for arg in &call.args {
                collect_state_deps(arg, state_vars, deps);
            }
        }
        Expr::Binary(bin) => {
            collect_state_deps(&bin.left, state_vars, deps);
            collect_state_deps(&bin.right, state_vars, deps);
        }
        Expr::Unary(unary) => {
            collect_state_deps(&unary.expr, state_vars, deps);
        }
        Expr::Assign(assign) => {
            collect_state_deps(&assign.left, state_vars, deps);
            collect_state_deps(&assign.right, state_vars, deps);
        }
        Expr::Index(index) => {
            collect_state_deps(&index.expr, state_vars, deps);
            collect_state_deps(&index.index, state_vars, deps);
        }
        Expr::Tuple(tuple) => {
            for elem in &tuple.elems {
                collect_state_deps(elem, state_vars, deps);
            }
        }
        Expr::Array(array) => {
            for elem in &array.elems {
                collect_state_deps(elem, state_vars, deps);
            }
        }
        Expr::Struct(strukt) => {
            for field in &strukt.fields {
                collect_state_deps(&field.expr, state_vars, deps);
            }
        }
        Expr::Block(block) => {
            for stmt in &block.block.stmts {
                match stmt {
                    syn::Stmt::Expr(expr, _) => collect_state_deps(expr, state_vars, deps),
                    syn::Stmt::Local(local) => {
                        if let Some(init) = &local.init {
                            collect_state_deps(&init.expr, state_vars, deps);
                        }
                    }
                    _ => {}
                }
            }
        }
        Expr::Closure(closure) => {
            collect_state_deps(&closure.body, state_vars, deps);
        }
        Expr::Macro(mac) => {
            // For format! macro, check arguments
            if mac.mac.path.is_ident("format") {
                if let Ok(args) = mac.mac.parse_body_with(syn::punctuated::Punctuated::<syn::Expr, syn::Token![,]>::parse_terminated) {
                    for arg in args.iter().skip(1) { // Skip format string
                        collect_state_deps(arg, state_vars, deps);
                    }
                }
            }
        }
        Expr::If(expr_if) => {
            collect_state_deps(&expr_if.cond, state_vars, deps);
            // then_branch is a Block, extract expressions from it
            for stmt in &expr_if.then_branch.stmts {
                match stmt {
                    syn::Stmt::Expr(expr, _) => collect_state_deps(expr, state_vars, deps),
                    syn::Stmt::Local(local) => {
                        if let Some(init) = &local.init {
                            collect_state_deps(&init.expr, state_vars, deps);
                        }
                    }
                    _ => {}
                }
            }
            if let Some((_, else_branch)) = &expr_if.else_branch {
                collect_state_deps(else_branch, state_vars, deps);
            }
        }
        Expr::Match(match_expr) => {
            collect_state_deps(&match_expr.expr, state_vars, deps);
            for arm in &match_expr.arms {
                collect_state_deps(&arm.body, state_vars, deps);
            }
        }
        Expr::Range(range) => {
            if let Some(start) = &range.start {
                collect_state_deps(start, state_vars, deps);
            }
            if let Some(end) = &range.end {
                collect_state_deps(end, state_vars, deps);
            }
        }
        Expr::Reference(reference) => {
            collect_state_deps(&reference.expr, state_vars, deps);
        }
        Expr::Paren(paren) => {
            collect_state_deps(&paren.expr, state_vars, deps);
        }
        Expr::Cast(cast) => {
            collect_state_deps(&cast.expr, state_vars, deps);
        }
        Expr::Repeat(repeat) => {
            collect_state_deps(&repeat.expr, state_vars, deps);
            if let Expr::Lit(_lit) = &*repeat.len {
                // Literal length, no deps
            } else if let syn::Expr::Path(_) = &*repeat.len {
                // Path, check if state var
                collect_state_deps(&repeat.len, state_vars, deps);
            }
        }
        // For other expression types, we don't extract deps (conservative approach)
        _ => {}
    }
}

pub fn is_expr_static(expr: &Expr) -> bool {
    match expr {
        Expr::Lit(_) => true,
        Expr::Call(call) => {
            call.args.iter().all(is_expr_static)
        }
        Expr::Path(path) => {
            let path_str = quote::quote!(#path).to_string();
            !(path_str.contains("self") || path_str.contains("state") || path_str.contains("props"))
        }
        Expr::Binary(bin) => {
            is_expr_static(&bin.left) && is_expr_static(&bin.right)
        }
        Expr::Block(block) => {
            if block.block.stmts.len() == 1 {
                if let syn::Stmt::Expr(inner_expr, _) = &block.block.stmts[0] {
                    is_expr_static(inner_expr)
                } else {
                    false
                }
            } else {
                false
            }
        }
        _ => false,
    }
}

pub fn expr_to_luau(expr: &Expr) -> String {
    expr_to_luau_with_state(expr, &HashSet::new())
}

pub fn expr_to_luau_with_state(expr: &Expr, state_vars: &HashSet<String>) -> String {
    match expr {
        Expr::Lit(lit) => {
            match &lit.lit {
                syn::Lit::Str(s) => format!("\"{}\"", s.value()),
                syn::Lit::Int(i) => i.base10_digits().to_string(),
                syn::Lit::Float(f) => f.base10_digits().to_string(),
                syn::Lit::Bool(b) => b.value.to_string(),
                _ => quote::quote!(#lit).to_string(),
            }
        }
        Expr::Path(path) => {
            let path_str = quote::quote!(#path).to_string();
            let cleaned = path_str.replace(" :: ", ".");
            if cleaned == "state" {
                "self.state".to_string()
            } else if cleaned == "props" {
                "self.props".to_string()
            } else if state_vars.contains(&cleaned) {
                format!("self.state.{}", cleaned)
            } else {
                cleaned
            }
        }
        Expr::Field(field) => {
            let base_str = expr_to_luau_with_state(&field.base, state_vars);
            let member_name = match &field.member {
                syn::Member::Named(ident) => ident.to_string(),
                syn::Member::Unnamed(index) => index.index.to_string(),
            };
            
            if base_str == "state" {
                format!("self.state.{}", member_name)
            } else if base_str == "props" {
                format!("self.props.{}", member_name)
            } else {
                format!("{}.{}", base_str, member_name)
            }
        }
        Expr::MethodCall(method_call) => {
            let receiver_str = expr_to_luau_with_state(&method_call.receiver, state_vars);
            let method_name = method_call.method.to_string();
            
            if method_name == "get" {
                let clean_name = if receiver_str.starts_with("self.state.") {
                    &receiver_str["self.state.".len()..]
                } else {
                    &receiver_str
                };
                format!("self.state.{}", clean_name)
            } else if method_name == "set" && !method_call.args.is_empty() {
                let clean_name = if receiver_str.starts_with("self.state.") {
                    &receiver_str["self.state.".len()..]
                } else {
                    &receiver_str
                };
                let arg_luau = expr_to_luau_with_state(&method_call.args[0], state_vars);
                format!("self:setState({{ {} = {} }})", clean_name, arg_luau)
            } else if method_name == "to_string" {
                // Luau strings don't need .to_string(), just return the receiver
                receiver_str
            } else {
                let args: Vec<String> = method_call.args.iter().map(|e| expr_to_luau_with_state(e, state_vars)).collect();
                format!("{}:{}({})", receiver_str, method_name, args.join(", "))
            }
        }
        Expr::Call(call) => {
            let func_str = expr_to_luau_with_state(&call.func, state_vars);
            let func_str_clean = func_str.replace(" :: ", ".");
            
            // Special handling for Vec::new() and String::new()
            if func_str_clean == "Vec.new" || func_str_clean.contains("Vec.<") && func_str_clean.contains(">.new") {
                return "{}".to_string();
            }
            if func_str_clean == "String.new" {
                return "\"\"".to_string();
            }
            
            let args: Vec<String> = call.args.iter().map(|e| expr_to_luau_with_state(e, state_vars)).collect();
            format!("{}({})", func_str, args.join(", "))
        }
        Expr::Binary(bin) => {
            let left = expr_to_luau_with_state(&bin.left, state_vars);
            let right = expr_to_luau_with_state(&bin.right, state_vars);
            let op = match bin.op {
                syn::BinOp::Add(_) => "+",
                syn::BinOp::Sub(_) => "-",
                syn::BinOp::Mul(_) => "*",
                syn::BinOp::Div(_) => "/",
                syn::BinOp::Eq(_) => "==",
                syn::BinOp::Ne(_) => "~=",
                syn::BinOp::Lt(_) => "<",
                syn::BinOp::Le(_) => "<=",
                syn::BinOp::Gt(_) => ">",
                syn::BinOp::Ge(_) => ">=",
                syn::BinOp::And(_) => "and",
                syn::BinOp::Or(_) => "or",
                _ => "+",
            };
            format!("{} {} {}", left, op, right)
        }
        Expr::Closure(closure) => {
            // Unwrap single-statement blocks before matching
            let body_expr = match &*closure.body {
                Expr::Block(block) if block.block.stmts.len() == 1 => {
                    match &block.block.stmts[0] {
                        syn::Stmt::Expr(expr, _) => expr,
                        _ => &*closure.body,
                    }
                }
                _ => &*closure.body,
            };

            let body_luau = match body_expr {
                Expr::Binary(bin) if is_assign_op(&bin.op) => {
                    let left_str = expr_to_luau_with_state(&bin.left, state_vars);
                    let right_str = expr_to_luau_with_state(&bin.right, state_vars);
                    
                    // Check if left is a state variable
                    let is_state_var = if let Expr::Path(path) = &*bin.left {
                        let path_str = quote::quote!(#path).to_string().replace(" :: ", ".");
                        state_vars.contains(&path_str)
                    } else {
                        left_str.starts_with("self.state.")
                    };
                    
                    if is_state_var {
                        let field_name = if left_str.starts_with("self.state.") {
                            &left_str["self.state.".len()..]
                        } else {
                            &left_str
                        };
                        let op_str = match bin.op {
                            syn::BinOp::AddAssign(_) => "+",
                            syn::BinOp::SubAssign(_) => "-",
                            syn::BinOp::MulAssign(_) => "*",
                            syn::BinOp::DivAssign(_) => "/",
                            _ => "=",
                        };
                        format!("self:setState({{ {} = self.state.{} {} {} }})", field_name, field_name, op_str, right_str)
                    } else {
                        let op_str = match bin.op {
                            syn::BinOp::AddAssign(_) => "+",
                            syn::BinOp::SubAssign(_) => "-",
                            syn::BinOp::MulAssign(_) => "*",
                            syn::BinOp::DivAssign(_) => "/",
                            _ => "=",
                        };
                        format!("{} = {} {} {}", left_str, left_str, op_str, right_str)
                    }
                }
                Expr::Assign(assign) => {
                    let left_str = expr_to_luau_with_state(&assign.left, state_vars);
                    let right_str = expr_to_luau_with_state(&assign.right, state_vars);
                    
                    let is_state_var = if let Expr::Path(path) = &*assign.left {
                        let path_str = quote::quote!(#path).to_string().replace(" :: ", ".");
                        state_vars.contains(&path_str)
                    } else {
                        left_str.starts_with("self.state.")
                    };
                    
                    if is_state_var {
                        let field_name = if left_str.starts_with("self.state.") {
                            &left_str["self.state.".len()..]
                        } else {
                            &left_str
                        };
                        format!("self:setState({{ {} = {} }})", field_name, right_str)
                    } else {
                        format!("{} = {}", left_str, right_str)
                    }
                }
                Expr::Block(block) => {
                    // Multi-statement block
                    let mut statements = Vec::new();
                    for stmt in &block.block.stmts {
                        match stmt {
                            syn::Stmt::Local(local) => {
                                if let Some(local_init) = &local.init {
                                    let name = match &local.pat {
                                        syn::Pat::Ident(pat_ident) => pat_ident.ident.to_string(),
                                        _ => "temp".to_string(),
                                    };
                                    let value = expr_to_luau_with_state(&local_init.expr, state_vars);
                                    statements.push(format!("local {} = {}", name, value));
                                }
                            }
                            syn::Stmt::Expr(expr, _) => {
                                match expr {
                                    Expr::Binary(bin) if is_assign_op(&bin.op) => {
                                        let left_str = expr_to_luau_with_state(&bin.left, state_vars);
                                        let right_str = expr_to_luau_with_state(&bin.right, state_vars);
                                        
                                        let is_state_var = if let Expr::Path(path) = &*bin.left {
                                            let path_str = quote::quote!(#path).to_string().replace(" :: ", ".");
                                            state_vars.contains(&path_str)
                                        } else {
                                            left_str.starts_with("self.state.")
                                        };
                                        
                                        if is_state_var {
                                            let field_name = if left_str.starts_with("self.state.") {
                                                &left_str["self.state.".len()..]
                                            } else {
                                                &left_str
                                            };
                                            let op_str = match bin.op {
                                                syn::BinOp::AddAssign(_) => "+",
                                                syn::BinOp::SubAssign(_) => "-",
                                                syn::BinOp::MulAssign(_) => "*",
                                                syn::BinOp::DivAssign(_) => "/",
                                                _ => "=",
                                            };
                                            statements.push(format!("self:setState({{ {} = self.state.{} {} {} }})", field_name, field_name, op_str, right_str));
                                        } else {
                                            let op_str = match bin.op {
                                                syn::BinOp::AddAssign(_) => "+",
                                                syn::BinOp::SubAssign(_) => "-",
                                                syn::BinOp::MulAssign(_) => "*",
                                                syn::BinOp::DivAssign(_) => "/",
                                                _ => "=",
                                            };
                                            statements.push(format!("{} = {} {} {}", left_str, left_str, op_str, right_str));
                                        }
                                    }
                                    Expr::Assign(assign) => {
                                        let left_str = expr_to_luau_with_state(&assign.left, state_vars);
                                        let right_str = expr_to_luau_with_state(&assign.right, state_vars);
                                        
                                        let is_state_var = if let Expr::Path(path) = &*assign.left {
                                            let path_str = quote::quote!(#path).to_string().replace(" :: ", ".");
                                            state_vars.contains(&path_str)
                                        } else {
                                            left_str.starts_with("self.state.")
                                        };
                                        
                                        if is_state_var {
                                            let field_name = if left_str.starts_with("self.state.") {
                                                &left_str["self.state.".len()..]
                                            } else {
                                                &left_str
                                            };
                                            statements.push(format!("self:setState({{ {} = {} }})", field_name, right_str));
                                        } else {
                                            statements.push(format!("{} = {}", left_str, right_str));
                                        }
                                    }
                                    _ => {
                                        let expr_str = expr_to_luau_with_state(expr, state_vars);
                                        if !expr_str.is_empty() {
                                            statements.push(expr_str);
                                        }
                                    }
                                }
                            }
                            _ => {}
                        }
                    }
                    statements.join("\n        ")
                }
                expr => expr_to_luau_with_state(expr, state_vars),
            };
            format!("function()\n        {}\n    end", body_luau)
        }
        Expr::If(expr_if) => {
            let cond = expr_to_luau_with_state(&expr_if.cond, state_vars);
            let then_branch = if expr_if.then_branch.stmts.len() == 1 {
                if let syn::Stmt::Expr(expr, _) = &expr_if.then_branch.stmts[0] {
                    expr_to_luau_with_state(expr, state_vars)
                } else {
                    "nil".to_string()
                }
            } else {
                "nil".to_string()
            };
            let else_branch = if let Some((_, else_expr)) = &expr_if.else_branch {
                let expr_str = expr_to_luau_with_state(else_expr, state_vars);
                // Remove braces from single string literals in else branch
                if expr_str.starts_with("{ ") && expr_str.ends_with(" }") {
                    let inner = &expr_str[2..expr_str.len()-2];
                    // Check if it's a single string literal
                    if inner.starts_with("\"") && inner.ends_with("\"") {
                        inner.to_string()
                    } else {
                        expr_str
                    }
                } else {
                    expr_str
                }
            } else {
                "nil".to_string()
            };
            format!("if {} then {} else {} end", cond, then_branch, else_branch)
        }
        Expr::Unary(unary) => {
            let operand = expr_to_luau_with_state(&unary.expr, state_vars);
            let op = match unary.op {
                syn::UnOp::Neg(_) => "-",
                syn::UnOp::Not(_) => "not ",
                _ => "",
            };
            format!("{}{}", op, operand)
        }
        Expr::Macro(mac) => {
            if mac.mac.path.is_ident("format") {
                if let Ok(args) = mac.mac.parse_body_with(syn::punctuated::Punctuated::<syn::Expr, syn::Token![,]>::parse_terminated) {
                    let args: Vec<syn::Expr> = args.into_iter().collect();
                    if !args.is_empty() {
                        if let syn::Expr::Lit(lit) = &args[0] {
                            if let syn::Lit::Str(s) = &lit.lit {
                                let fmt = s.value();
                                let mut luau_parts = Vec::new();
                                let mut arg_idx = 1;
                                let mut current_part = String::new();
                                let mut chars = fmt.chars().peekable();
                                while let Some(c) = chars.next() {
                                    if c == '{' && chars.peek() == Some(&'}') {
                                        chars.next(); // consume '}'
                                        if !current_part.is_empty() {
                                            luau_parts.push(format!("\"{}\"", current_part));
                                            current_part.clear();
                                        }
                                        if let Some(arg) = args.get(arg_idx) {
                                            let arg_luau = expr_to_luau_with_state(arg, state_vars);
                                            luau_parts.push(format!("tostring({})", arg_luau));
                                            arg_idx += 1;
                                        }
                                    } else {
                                        current_part.push(c);
                                    }
                                }
                                if !current_part.is_empty() {
                                    luau_parts.push(format!("\"{}\"", current_part));
                                }
                                return luau_parts.join(" .. ");
                            }
                        }
                    }
                }
            }
            quote::quote!(#mac).to_string()
        }
        Expr::Struct(strukt) => {
            let fields: Vec<String> = strukt.fields.iter().map(|field| {
                let field_name = match &field.member {
                    syn::Member::Named(ident) => ident.to_string(),
                    syn::Member::Unnamed(index) => format!("{}", index.index),
                };
                let field_value = expr_to_luau_with_state(&field.expr, state_vars);
                format!("{} = {}", field_name, field_value)
            }).collect();
            format!("{{ {} }}", fields.join(", "))
        }
        Expr::ForLoop(for_loop) => {
            let pat_str = match &*for_loop.pat {
                syn::Pat::Ident(ident) => ident.ident.to_string(),
                _ => quote::quote!(#for_loop.pat).to_string(),
            };
            let iter_str = expr_to_luau_with_state(&for_loop.expr, state_vars);
            let body_str = block_to_luau(&for_loop.body, state_vars);
            format!("for {} in {} do\n        {}\n    end", pat_str, iter_str, body_str)
        }
        Expr::While(while_loop) => {
            let cond_str = expr_to_luau_with_state(&while_loop.cond, state_vars);
            let body_str = block_to_luau(&while_loop.body, state_vars);
            format!("while {} do\n        {}\n    end", cond_str, body_str)
        }
        Expr::Loop(loop_expr) => {
            let body_str = block_to_luau(&loop_expr.body, state_vars);
            format!("repeat\n        {}\n    until false", body_str)
        }
        _ => quote::quote!(#expr).to_string(),
    }
}

pub fn convert_ast_to_ir(ast: &AstNode, state_vars: &HashSet<String>) -> Result<UiNode, syn::Error> {
    let mut props = Vec::new();
    for prop in &ast.props {
        let name_str = prop.name.to_string();
        
        if let Err(err_msg) = crate::api_dump::validate_property(&ast.name.to_string(), &name_str) {
            return Err(syn::Error::new(prop.name.span(), err_msg));
        }
        
        let val = if is_event_name(&name_str) {
            PropValue::Event(expr_to_luau_with_state(&prop.value, state_vars))
        } else if is_expr_static(&prop.value) {
            PropValue::Static(expr_to_luau_with_state(&prop.value, state_vars))
        } else {
            // Dynamic property - extract dependencies from AST
            let expression = expr_to_luau_with_state(&prop.value, state_vars);
            let dependencies = extract_state_deps_from_expr(&prop.value, state_vars);
            PropValue::Dynamic(DynamicProp {
                expression,
                dependencies,
            })
        };
        props.push((name_str, val));
    }

    let mut children = Vec::new();
    for child in &ast.children {
        children.push(convert_ast_to_ir(child, state_vars)?);
    }
    
    Ok(UiNode::new(ast.name.to_string(), props, children))
}

pub fn extract_state_vars(block: &syn::Block) -> HashSet<String> {
    let mut state_vars = HashSet::new();
    for stmt in &block.stmts {
        if let syn::Stmt::Local(local) = stmt {
            if let Some(local_init) = &local.init {
                if let syn::Expr::Call(call) = &*local_init.expr {
                    let func_str = quote::quote!(#call.func).to_string();
                    if func_str.contains("use_state") {
                        if let syn::Pat::Ident(pat_ident) = &local.pat {
                            state_vars.insert(pat_ident.ident.to_string());
                        }
                    }
                }
            }
        }
    }
    state_vars
}

pub fn stmt_to_luau(stmt: &syn::Stmt, state_vars: &HashSet<String>) -> String {
    match stmt {
        syn::Stmt::Local(local) => {
            if let Some(local_init) = &local.init {
                let pat_str = match &local.pat {
                    syn::Pat::Ident(ident) => ident.ident.to_string(),
                    _ => quote::quote!(#local.pat).to_string(),
                };
                let init_str = expr_to_luau_with_state(&local_init.expr, state_vars);
                format!("local {} = {}", pat_str, init_str)
            } else {
                String::new()
            }
        }
        syn::Stmt::Expr(expr, _) => {
            expr_to_luau_with_state(expr, state_vars)
        }
        syn::Stmt::Item(item) => {
            quote::quote!(#item).to_string()
        }
        _ => String::new(),
    }
}

fn block_to_luau(block: &syn::Block, state_vars: &HashSet<String>) -> String {
    let mut statements = Vec::new();
    for stmt in &block.stmts {
        let stmt_luau = stmt_to_luau(stmt, state_vars);
        if !stmt_luau.is_empty() {
            statements.push(stmt_luau);
        }
    }
    statements.join("\n        ")
}
