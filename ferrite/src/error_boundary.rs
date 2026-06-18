use crate::prelude::*;

/// Error Boundary component for catching errors in child components
#[component]
pub fn ErrorBoundary() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundColor3: Color3::fromRGB(50, 50, 50),
            
            TextLabel {
                Text: "Something went wrong",
                Size: UDim2::new(1, 0, 0, 30),
                TextColor3: Color3::fromRGB(255, 100, 100),
                TextSize: 20,
                BackgroundTransparency: 1,
            }
            
            TextButton {
                Text: "Try Again",
                Size: UDim2::new(0, 100, 0, 30),
                Position: UDim2::new(0.5, -50, 0.5, 50),
                BackgroundColor3: Color3::fromRGB(0, 120, 215),
                TextColor3: Color3::fromRGB(255, 255, 255),
            }
        }
    }
}
