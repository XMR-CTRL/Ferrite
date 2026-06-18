use crate::prelude::*;

#[component]
pub fn TestSimple() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(0, 200, 0, 100),
            Position: UDim2::new(0.5, -100, 0.5, -50),
            BackgroundColor3: Color3::fromRGB(100, 100, 100),
            
            TextLabel {
                Text: "Hello World",
                Size: UDim2::new(1, 0, 1, 0),
                TextColor3: Color3::fromRGB(255, 255, 255),
                TextSize: 20,
                BackgroundTransparency: 1,
            }
        }
    }
}
