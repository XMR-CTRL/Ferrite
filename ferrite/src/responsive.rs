use crate::prelude::*;

/// Responsive design utilities
#[component]
pub fn Responsive() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Breakpoint configuration
pub struct Breakpoints {
    pub xs: f32,
    pub sm: f32,
    pub md: f32,
    pub lg: f32,
    pub xl: f32,
}

impl Default for Breakpoints {
    fn default() -> Self {
        Breakpoints {
            xs: 0.0,
            sm: 576.0,
            md: 768.0,
            lg: 992.0,
            xl: 1200.0,
        }
    }
}

/// Hook for responsive breakpoints
pub fn use_breakpoints() -> Breakpoints {
    Breakpoints::default()
}

/// Hook for current breakpoint
pub fn use_current_breakpoint() -> String {
    "md".to_string()
}

/// Hook for media query
pub fn use_media_query(_query: &str) -> bool {
    false
}
