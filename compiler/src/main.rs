use clap::{Parser, Subcommand};
use std::collections::HashMap;
use std::fs;
use std::path::Path;
use walkdir::WalkDir;

#[derive(Parser)]
#[command(name = "ferrite")]
#[command(about = "Ferrite UI Compiler", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build {
        #[arg(short, long, default_value = "src")]
        src: String,

        #[arg(short, long, default_value = "runtime/components")]
        out: String,
    },
    Watch {
        #[arg(short, long, default_value = "src")]
        src: String,

        #[arg(short, long, default_value = "runtime/components")]
        out: String,
    },
    Compile {
        /// Input file path (or use stdin if not provided)
        #[arg(short, long)]
        input: Option<String>,

        /// Output file path (defaults to <component_name>.luau)
        #[arg(short, long)]
        output: Option<String>,
    },
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Build { src, out } => {
            let src_path = Path::new(src);
            let out_path = Path::new(out);

            println!("Ferrite: Starting compilation...");
            println!("Source directory: {:?}", src_path);
            println!("Output directory: {:?}", out_path);

            if !src_path.exists() {
                println!("Error: Source directory {:?} does not exist.", src_path);
                std::process::exit(1);
            }

            let compiled = compile_directory(src_path, out_path)?;
            println!("Ferrite compilation complete. Compiled {} component(s).", compiled);
        }
        Commands::Watch { src, out } => {
            let src_path = Path::new(src);
            let out_path = Path::new(out);

            println!("Ferrite: Starting hot-reload watcher...");
            println!("Watching source directory: {:?}", src_path);
            println!("Output directory: {:?}", out_path);

            if !src_path.exists() {
                println!("Error: Source directory {:?} does not exist.", src_path);
                std::process::exit(1);
            }

            let _ = compile_directory(src_path, out_path);

            use notify::{Watcher, RecursiveMode, Event};
            let (tx, rx) = std::sync::mpsc::channel();
            
            let mut watcher = notify::recommended_watcher(move |res: Result<Event, notify::Error>| {
                if let Ok(event) = res {
                    let _ = tx.send(event);
                }
            })?;
            
            watcher.watch(src_path, RecursiveMode::Recursive)?;
            
            for event in rx {
                for path in event.paths {
                    if path.is_file() && path.extension().map_or(false, |ext| ext == "rs") {
                        println!("Ferrite: File change detected: {:?}", path);
                        if let Err(err) = compile_file(&path, out_path) {
                            println!("Error compiling: {}", err);
                        }
                    }
                }
            }
        }
        Commands::Compile { input, output } => {
            let content = if let Some(input_path) = input {
                fs::read_to_string(input_path)?
            } else {
                use std::io::Read;
                let mut buffer = String::new();
                std::io::stdin().read_to_string(&mut buffer)?;
                buffer
            };

            let (component_name, luau_code) = compile_string(&content)?;
            
            let output_path = output
                .as_ref()
                .map(|s| s.to_string())
                .unwrap_or_else(|| format!("{}.luau", component_name));

            fs::write(&output_path, &luau_code)?;
            println!("✓ Compiled successfully: {}", output_path);
        }
    }

    Ok(())
}

fn compile_directory(src_path: &Path, out_path: &Path) -> Result<usize, Box<dyn std::error::Error>> {
    let mut compiled_count = 0;
    for entry in WalkDir::new(src_path).into_iter().filter_map(|e| e.ok()) {
        let path = entry.path();
        if path.is_file() && path.extension().map_or(false, |ext| ext == "rs") {
            if let Err(err) = compile_file(path, out_path) {
                println!("Error compiling {:?}: {}", path, err);
            } else {
                compiled_count += 1;
            }
        }
    }
    Ok(compiled_count)
}

fn compile_file(file_path: &Path, out_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let content = fs::read_to_string(file_path)?;
    let syntax = syn::parse_file(&content)?;
    
    let mut compiled_any = false;

    // Pattern 1: #[component] fn ComponentName() -> UiNode { ... }
    for item in &syntax.items {
        if let syn::Item::Fn(item_fn) = item {
            let has_component_attr = item_fn.attrs.iter().any(|attr| {
                attr.path().is_ident("component")
            });
            if !has_component_attr {
                continue;
            }

            let name = item_fn.sig.ident.to_string();
            let initial_state = extract_fn_state(&item_fn.block);
            let state_vars = compiler::parser::extract_state_vars(&item_fn.block);

            if let Some(mac) = find_view_macro_in_block(&item_fn.block) {
                let ast_node: compiler::parser::AstNode = syn::parse2(mac.tokens)?;
                let ir_node = compiler::parser::convert_ast_to_ir(&ast_node, &state_vars)?;
                let optimized_ir = compiler::optimizer::optimize_tree(ir_node);
                let effects = Vec::new();
                let refs = HashMap::new();
                let config = compiler::config::CompilerConfig::default();
                let luau_code = compiler::codegen::generate_luau(&name, &initial_state, &effects, &refs, &optimized_ir, &config);

                fs::create_dir_all(out_dir)?;
                let out_file_path = out_dir.join(format!("{}.luau", name));
                fs::write(&out_file_path, luau_code)?;
                println!("✓ Compiled: {} -> {:?}", name, out_file_path);
                compiled_any = true;
            }
        }
    }

    if compiled_any {
        return Ok(());
    }

    // Pattern 2: struct Foo { ... } + impl Foo { fn new() fn render() }
    let mut structs = HashMap::new();
    let mut impls = Vec::new();

    for item in &syntax.items {
        match item {
            syn::Item::Struct(s) => { structs.insert(s.ident.to_string(), s.clone()); }
            syn::Item::Impl(i) => { impls.push(i.clone()); }
            _ => {}
        }
    }

    for (name, _) in &structs {
        let mut initial_state = HashMap::new();
        let mut view_macro: Option<syn::Macro> = None;

        for item_impl in &impls {
            if let syn::Type::Path(type_path) = &*item_impl.self_ty {
                if type_path.path.is_ident(name) {
                    for impl_item in &item_impl.items {
                        if let syn::ImplItem::Fn(method) = impl_item {
                            let method_name = method.sig.ident.to_string();
                            if method_name == "new" || method_name == "init" {
                                if let Some(syn::Stmt::Expr(expr, _)) = method.block.stmts.last() {
                                    if let syn::Expr::Struct(expr_struct) = expr {
                                        for field in &expr_struct.fields {
                                            let field_name = match &field.member {
                                                syn::Member::Named(ident) => ident.to_string(),
                                                syn::Member::Unnamed(index) => index.index.to_string(),
                                            };
                                            let field_val = compiler::parser::expr_to_luau(&field.expr);
                                            initial_state.insert(field_name, field_val);
                                        }
                                    }
                                }
                            } else if method_name == "render" {
                                view_macro = find_view_macro_in_block(&method.block);
                            }
                        }
                    }
                }
            }
        }

        if let Some(mac) = view_macro {
            let ast_node: compiler::parser::AstNode = syn::parse2(mac.tokens)?;
            let ir_node = compiler::parser::convert_ast_to_ir(&ast_node, &std::collections::HashSet::new())?;
            let optimized_ir = compiler::optimizer::optimize_tree(ir_node);
            let effects = Vec::new();
            let refs = HashMap::new();
            let config = compiler::config::CompilerConfig::default();
            let luau_code = compiler::codegen::generate_luau(name, &initial_state, &effects, &refs, &optimized_ir, &config);

            fs::create_dir_all(out_dir)?;
            let out_file_path = out_dir.join(format!("{}.luau", name));
            fs::write(&out_file_path, luau_code)?;
            println!("✓ Compiled: {} -> {:?}", name, out_file_path);
        }
    }

    Ok(())
}

fn extract_fn_state(block: &syn::Block) -> HashMap<String, String> {
    let mut state = HashMap::new();
    for stmt in &block.stmts {
        if let syn::Stmt::Local(local) = stmt {
            if let Some(local_init) = &local.init {
                if let syn::Expr::Call(call) = &*local_init.expr {
                    let func_str = quote::quote!(#call.func).to_string();
                    if func_str.contains("use_state") && !call.args.is_empty() {
                        let name_str = match &local.pat {
                            syn::Pat::Ident(pat_ident) => pat_ident.ident.to_string(),
                            _ => continue,
                        };
                        if let syn::Expr::Closure(closure) = &call.args[0] {
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

fn compile_string(content: &str) -> Result<(String, String), Box<dyn std::error::Error>> {
    let syntax = syn::parse_file(content)?;
    
    // Try Pattern 1: #[component] fn ComponentName() -> UiNode { ... }
    for item in &syntax.items {
        if let syn::Item::Fn(item_fn) = item {
            let has_component_attr = item_fn.attrs.iter().any(|attr| {
                attr.path().is_ident("component")
            });
            if !has_component_attr {
                continue;
            }

            let name = item_fn.sig.ident.to_string();
            let initial_state = extract_fn_state(&item_fn.block);
            let state_vars = compiler::parser::extract_state_vars(&item_fn.block);

            if let Some(mac) = find_view_macro_in_block(&item_fn.block) {
                let ast_node: compiler::parser::AstNode = syn::parse2(mac.tokens)?;
                let ir_node = compiler::parser::convert_ast_to_ir(&ast_node, &state_vars)?;
                let optimized_ir = compiler::optimizer::optimize_tree(ir_node);
                let effects = Vec::new();
                let refs = HashMap::new();
                let config = compiler::config::CompilerConfig::default();
                let luau_code = compiler::codegen::generate_luau(&name, &initial_state, &effects, &refs, &optimized_ir, &config);
                return Ok((name, luau_code));
            }
        }
    }

    // Try Pattern 2: struct Foo { ... } + impl Foo { fn new() fn render() }
    let mut structs = HashMap::new();
    let mut impls = Vec::new();

    for item in &syntax.items {
        match item {
            syn::Item::Struct(s) => { structs.insert(s.ident.to_string(), s.clone()); }
            syn::Item::Impl(i) => { impls.push(i.clone()); }
            _ => {}
        }
    }

    for (name, _) in &structs {
        let mut initial_state = HashMap::new();
        let mut view_macro: Option<syn::Macro> = None;

        for item_impl in &impls {
            if let syn::Type::Path(type_path) = &*item_impl.self_ty {
                if type_path.path.is_ident(name) {
                    for impl_item in &item_impl.items {
                        if let syn::ImplItem::Fn(method) = impl_item {
                            let method_name = method.sig.ident.to_string();
                            if method_name == "new" || method_name == "init" {
                                if let Some(syn::Stmt::Expr(expr, _)) = method.block.stmts.last() {
                                    if let syn::Expr::Struct(expr_struct) = expr {
                                        for field in &expr_struct.fields {
                                            let field_name = match &field.member {
                                                syn::Member::Named(ident) => ident.to_string(),
                                                syn::Member::Unnamed(index) => index.index.to_string(),
                                            };
                                            let field_val = compiler::parser::expr_to_luau(&field.expr);
                                            initial_state.insert(field_name, field_val);
                                        }
                                    }
                                }
                            } else if method_name == "render" {
                                view_macro = find_view_macro_in_block(&method.block);
                            }
                        }
                    }
                }
            }
        }

        if let Some(mac) = view_macro {
            let ast_node: compiler::parser::AstNode = syn::parse2(mac.tokens)?;
            let ir_node = compiler::parser::convert_ast_to_ir(&ast_node, &std::collections::HashSet::new())?;
            let optimized_ir = compiler::optimizer::optimize_tree(ir_node);
            let effects = Vec::new();
            let refs = HashMap::new();
            let config = compiler::config::CompilerConfig::default();
            let luau_code = compiler::codegen::generate_luau(name, &initial_state, &effects, &refs, &optimized_ir, &config);
            return Ok((name.clone(), luau_code));
        }
    }

    Err("No valid component found. Use #[component] fn or struct with render() method.".into())
}



