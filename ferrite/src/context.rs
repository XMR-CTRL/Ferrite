use crate::prelude::*;

/// Context Provider component for sharing state through the component tree
#[component]
pub fn Provider<T>() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Consumer component for accessing context values
#[component]
pub fn Consumer<T>() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Create a new context with a default value
pub fn create_context<T>(default: T) -> Context<T> {
    Context::new(default)
}
