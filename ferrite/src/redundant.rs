use crate::prelude::*;

#[component]
pub fn Redundant() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(0, 100, 0, 100),
            BackgroundColor3: Color3::fromRGB(0, 0, 0),
            
            Frame {
                Size: UDim2::new(1, 0, 1, 0),
                TextLabel {
                    Text: "Nested label",
                    Size: UDim2::new(1, 0, 0, 20),
                }
            }
        }
    }
}
