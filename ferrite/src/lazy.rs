use crate::prelude::*;

/// Lazy component for code splitting and lazy loading
#[component]
pub fn Lazy() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Hook for lazy loading components
pub fn use_lazy<T, F>(loader: F) -> Option<T>
where
    F: FnOnce() -> T,
{
    // This will be implemented by the macro to handle lazy loading
    None
}
