use crate::prelude::*;

/// Portal component for rendering children outside the parent component hierarchy
#[component]
pub fn Portal() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}
