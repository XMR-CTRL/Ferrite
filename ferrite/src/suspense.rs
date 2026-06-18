use crate::prelude::*;

/// Suspense component for async components with loading states
#[component]
pub fn Suspense() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
            
            Frame {
                Size: UDim2::new(0, 40, 0, 40),
                Position: UDim2::new(0.5, -20, 0.5, -20),
                BackgroundTransparency: 1,
                
                ImageLabel {
                    Size: UDim2::new(1, 0, 1, 0),
                    Image: "rbxassetid://4944326298",
                    Rotation: 0,
                }
            }
        }
    }
}
