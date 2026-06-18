use crate::prelude::*;

/// Router component for client-side routing
#[component]
pub fn Router() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Route component
#[component]
pub fn Route() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Link component for navigation
#[component]
pub fn Link() -> UiNode {
    view! {
        TextButton {
            Size: UDim2::new(0, 100, 0, 30),
            BackgroundTransparency: 1,
            TextColor3: Color3::fromRGB(0, 122, 255),
            TextSize: 14,
        }
    }
}

/// Hook for router navigation
pub fn use_router() -> Router {
    Router {
        current_path: "/".to_string(),
        push: Box::new(|_| {}),
        replace: Box::new(|_| {}),
        back: Box::new(|| {}),
        forward: Box::new(|| {}),
    }
}

/// Router state
pub struct Router {
    pub current_path: String,
    pub push: Box<dyn Fn(String)>,
    pub replace: Box<dyn Fn(String)>,
    pub back: Box<dyn Fn()>,
    pub forward: Box<dyn Fn()>,
}

/// Hook for route parameters
pub fn use_params() -> std::collections::HashMap<String, String> {
    std::collections::HashMap::new()
}
