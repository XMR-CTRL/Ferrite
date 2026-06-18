use compiler::config::CompilerConfig;
use compiler::codegen::generate_luau;
use compiler::ir::UiNode;
use std::collections::HashMap;

#[test]
fn test_default_config() {
    let config = CompilerConfig::default();
    let initial_state = HashMap::new();
    let effects = Vec::new();
    let refs = HashMap::new();
    let ir_node = UiNode::new("TestNode".to_string(), vec![], vec![]);
    
    let luau_code = generate_luau("TestComponent", &initial_state, &effects, &refs, &ir_node, &config);
    
    println!("Default config output:\n{}", luau_code);
    assert!(luau_code.contains("local Signal = require"));
}

#[test]
fn test_production_config() {
    let config = CompilerConfig::production();
    let initial_state = HashMap::new();
    let effects = Vec::new();
    let refs = HashMap::new();
    let ir_node = UiNode::new("TestNode".to_string(), vec![], vec![]);
    
    let luau_code = generate_luau("TestComponent", &initial_state, &effects, &refs, &ir_node, &config);
    
    println!("Production config output:\n{}", luau_code);
    assert!(luau_code.contains("local Signal = require"));
}

#[test]
fn test_development_config() {
    let config = CompilerConfig::development();
    let initial_state = HashMap::new();
    let effects = Vec::new();
    let refs = HashMap::new();
    let ir_node = UiNode::new("TestNode".to_string(), vec![], vec![]);
    
    let luau_code = generate_luau("TestComponent", &initial_state, &effects, &refs, &ir_node, &config);
    
    println!("Development config output:\n{}", luau_code);
    assert!(luau_code.contains("local Signal = require"));
}

#[test]
fn test_robust_config() {
    let config = CompilerConfig::robust();
    let initial_state = HashMap::new();
    let effects = Vec::new();
    let refs = HashMap::new();
    let ir_node = UiNode::new("TestNode".to_string(), vec![], vec![]);
    
    let luau_code = generate_luau("TestComponent", &initial_state, &effects, &refs, &ir_node, &config);
    
    println!("Robust config output:\n{}", luau_code);
    assert!(luau_code.contains("local Signal = require"));
}

#[test]
fn test_config_flags() {
    let config_optimized = CompilerConfig::default().with_optimization(true);
    let config_not_optimized = CompilerConfig::default().with_optimization(false);
    
    let config_minified = CompilerConfig::default().with_minification(true);
    let config_not_minified = CompilerConfig::default().with_minification(false);
    
    let config_strict = CompilerConfig::default().with_strict_mode(true);
    let config_not_strict = CompilerConfig::default().with_strict_mode(false);
    
    println!("Optimized: {:?}", config_optimized);
    println!("Not Optimized: {:?}", config_not_optimized);
    println!("Minified: {:?}", config_minified);
    println!("Not Minified: {:?}", config_not_minified);
    println!("Strict: {:?}", config_strict);
    println!("Not Strict: {:?}", config_not_strict);
    
    assert!(config_optimized.optimize_luau);
    assert!(!config_not_optimized.optimize_luau);
    assert!(config_minified.minify_output);
    assert!(!config_not_minified.minify_output);
    assert!(config_strict.strict_mode);
    assert!(!config_not_strict.strict_mode);
}
