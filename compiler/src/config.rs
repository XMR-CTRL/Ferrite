
#[derive(Debug, Clone)]
pub struct CompilerConfig {
    pub optimize_luau: bool,
    pub minify_output: bool,
    pub strict_mode: bool,
    pub inline_literals: bool,
    pub remove_unused_refs: bool,
    pub validate_syntax: bool,
    pub target_runtime: RuntimeTarget,
}

#[derive(Debug, Clone, Copy)]
pub enum RuntimeTarget {
    Roblox,
    Lune,
    Standard,
}

impl Default for CompilerConfig {
    fn default() -> Self {
        Self {
            optimize_luau: true,
            minify_output: false,
            strict_mode: true,
            inline_literals: true,
            remove_unused_refs: true,
            validate_syntax: true,
            target_runtime: RuntimeTarget::Roblox,
        }
    }
}

impl CompilerConfig {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn with_optimization(mut self, enabled: bool) -> Self {
        self.optimize_luau = enabled;
        self
    }

    pub fn with_minification(mut self, enabled: bool) -> Self {
        self.minify_output = enabled;
        self
    }

    pub fn with_strict_mode(mut self, enabled: bool) -> Self {
        self.strict_mode = enabled;
        self
    }

    pub fn with_runtime(mut self, target: RuntimeTarget) -> Self {
        self.target_runtime = target;
        self
    }

    pub fn production() -> Self {
        Self::default()
            .with_optimization(true)
            .with_minification(true)
            .with_strict_mode(true)
    }

    pub fn development() -> Self {
        Self::default()
            .with_optimization(false)
            .with_minification(false)
            .with_strict_mode(false)
    }

    pub fn robust() -> Self {
        Self::default()
            .with_optimization(true)
            .with_minification(false)
            .with_strict_mode(true)
    }
}
