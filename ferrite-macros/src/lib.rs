extern crate proc_macro;
use proc_macro::TokenStream;
use quote::quote;
use syn::{ItemFn, Stmt, Expr, Attribute};
use std::collections::HashMap;
use std::path::PathBuf;
use std::fs;

fn find_output_dir() -> PathBuf {
    if let Ok(env_path) = std::env::var("FERRITE_OUT_DIR") {
        return PathBuf::from(env_path);
    }
    
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap_or_else(|_| ".".to_string());
    let mut path = PathBuf::from(manifest_dir);
    
    for _ in 0..5 {
        let test_path = path.join("runtime").join("components");
        if test_path.exists() || path.join("Cargo.toml").exists() {
            let _ = fs::create_dir_all(&test_path);
            return test_path;
        }
        if !path.pop() {
            break;
        }
    }
    
    PathBuf::from("runtime/components")
}

fn extract_initial_state(block: &syn::Block) -> HashMap<String, String> {
    let mut state = HashMap::new();
    for stmt in &block.stmts {
        if let Stmt::Local(local) = stmt {
            if let Some(local_init) = &local.init {
                if let Expr::Call(call) = &*local_init.expr {
                    let func_str = quote!(#call.func).to_string();
                    // Check if it's use_state (might have path like crate::use_state or just use_state)
                    if func_str.contains("use_state") && !call.args.is_empty() {
                        let name_str = match &local.pat {
                            syn::Pat::Ident(pat_ident) => pat_ident.ident.to_string(),
                            _ => continue,
                        };
                        if let Expr::Closure(closure) = &call.args[0] {
                            let val_str = compiler::parser::expr_to_luau(&closure.body);
                            state.insert(name_str, val_str);
                        }
                    }
                }
            }
        }
    }
    state
}

fn extract_effects(block: &syn::Block) -> Vec<String> {
    let mut effects = Vec::new();
    for stmt in &block.stmts {
        if let Stmt::Local(local) = stmt {
            if let Some(local_init) = &local.init {
                if let Expr::Call(call) = &*local_init.expr {
                    let func_str = quote!(#call.func).to_string();
                    if func_str.contains("use_effect") && !call.args.is_empty() {
                        if let Expr::Closure(closure) = &call.args[0] {
                            let effect_str = compiler::parser::expr_to_luau(&closure.body);
                            effects.push(effect_str);
                        }
                    }
                }
            }
        }
    }
    effects
}

fn extract_refs(block: &syn::Block) -> HashMap<String, String> {
    let mut refs = HashMap::new();
    for stmt in &block.stmts {
        if let Stmt::Local(local) = stmt {
            if let Some(local_init) = &local.init {
                if let Expr::Call(call) = &*local_init.expr {
                    let func_str = quote!(#call.func).to_string();
                    if func_str.contains("use_ref") && !call.args.is_empty() {
                        let name_str = match &local.pat {
                            syn::Pat::Ident(pat_ident) => pat_ident.ident.to_string(),
                            _ => continue,
                        };
                        let val_str = compiler::parser::expr_to_luau(&call.args[0]);
                        refs.insert(name_str, val_str);
                    }
                }
            }
        }
    }
    refs
}

fn find_view_macro_in_block(block: &syn::Block) -> Option<syn::Macro> {
    for stmt in &block.stmts {
        match stmt {
            syn::Stmt::Macro(stmt_mac) => {
                if stmt_mac.mac.path.is_ident("view") {
                    return Some(stmt_mac.mac.clone());
                }
            }
            syn::Stmt::Expr(expr, _) => {
                if let Some(mac) = find_view_macro_in_expr(expr) {
                    return Some(mac);
                }
            }
            syn::Stmt::Local(local) => {
                if let Some(local_init) = &local.init {
                    if let Some(mac) = find_view_macro_in_expr(&local_init.expr) {
                        return Some(mac);
                    }
                }
            }
            _ => {}
        }
    }
    None
}

fn find_view_macro_in_expr(expr: &syn::Expr) -> Option<syn::Macro> {
    match expr {
        syn::Expr::Macro(mac) => {
            if mac.mac.path.is_ident("view") {
                return Some(mac.mac.clone());
            }
        }
        syn::Expr::Block(expr_block) => {
            return find_view_macro_in_block(&expr_block.block);
        }
        _ => {}
    }
    None
}

#[proc_macro_attribute]
pub fn component(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let input = item.clone();
    
    if let Ok(item_fn) = syn::parse::<ItemFn>(item) {
        let component_name = item_fn.sig.ident.to_string();
        let initial_state = extract_initial_state(&item_fn.block);
        let effects = extract_effects(&item_fn.block);
        let refs = extract_refs(&item_fn.block);
        
        if let Some(mac) = find_view_macro_in_block(&item_fn.block) {
            match compile_view_macro(&component_name, &initial_state, &effects, &refs, mac) {
                Ok(_) => {}
                Err(err) => {
                    return err.to_compile_error().into();
                }
            }
        }
    }
    
    input
}

#[proc_macro_attribute]
pub fn memo(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let input = item.clone();
    
    if let Ok(item_fn) = syn::parse::<ItemFn>(item) {
        let component_name = item_fn.sig.ident.to_string();
        let initial_state = extract_initial_state(&item_fn.block);
        let effects = extract_effects(&item_fn.block);
        let refs = extract_refs(&item_fn.block);
        
        if let Some(mac) = find_view_macro_in_block(&item_fn.block) {
            match compile_view_macro(&component_name, &initial_state, &effects, &refs, mac) {
                Ok(_) => {}
                Err(err) => {
                    return err.to_compile_error().into();
                }
            }
        }
    }
    
    input
}

#[proc_macro_attribute]
pub fn script(_attr: TokenStream, item: TokenStream) -> TokenStream {
    let input = item.clone();
    
    if let Ok(item_fn) = syn::parse::<ItemFn>(item) {
        let script_name = item_fn.sig.ident.to_string();
        match compile_script_macro(&script_name, &item_fn.block) {
            Ok(_) => {}
            Err(err) => {
                return err.to_compile_error().into();
            }
        }
    }
    
    input
}

fn compile_view_macro(component_name: &str, initial_state: &HashMap<String, String>, effects: &Vec<String>, refs: &HashMap<String, String>, mac: syn::Macro) -> Result<(), syn::Error> {
    let ast_node: compiler::parser::AstNode = syn::parse2(mac.tokens)?;
    let state_vars: std::collections::HashSet<String> = initial_state.keys().cloned().collect();
    let ir_node = compiler::parser::convert_ast_to_ir(&ast_node, &state_vars)?;
    let optimized_ir = compiler::optimizer::optimize_tree(ir_node);
    let config = compiler::config::CompilerConfig::default();
    let luau_code = compiler::codegen::generate_luau(component_name, initial_state, effects, refs, &optimized_ir, &config);
    
    let out_dir = find_output_dir();
    let out_file_path = out_dir.join(format!("{}.luau", component_name));
    
    if let Err(e) = fs::write(&out_file_path, luau_code) {
        return Err(syn::Error::new(
            proc_macro2::Span::call_site(),
            format!("Failed to write Luau component: {}", e)
        ));
    }
    
    Ok(())
}

fn compile_script_macro(script_name: &str, block: &syn::Block) -> Result<(), syn::Error> {
    let state_vars = compiler::parser::extract_state_vars(block);
    let mut luau_statements = Vec::new();
    
    for stmt in &block.stmts {
        let stmt_luau = compiler::parser::stmt_to_luau(stmt, &state_vars);
        if !stmt_luau.is_empty() {
            luau_statements.push(stmt_luau);
        }
    }
    
    let luau_code = format!("-- Generated by Ferrite\n-- Script: {}\n\n{}", script_name, luau_statements.join("\n"));
    
    let out_dir = find_output_dir();
    let out_file_path = out_dir.join(format!("{}.luau", script_name));
    
    if let Err(e) = fs::write(&out_file_path, luau_code) {
        return Err(syn::Error::new(
            proc_macro2::Span::call_site(),
            format!("Failed to write Luau script: {}", e)
        ));
    }
    
    Ok(())
}

#[proc_macro]
pub fn view(_input: TokenStream) -> TokenStream {
    quote! {
        UiNode
    }.into()
}
