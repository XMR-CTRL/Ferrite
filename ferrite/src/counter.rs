use crate::prelude::*;

#[component]
pub fn Counter() -> UiNode {
    let mut count = use_state(|| 0);

    view! {
        Frame {
            Size: UDim2::new(0, 300, 0, 300),
            Position: UDim2::new(0.5, -150, 0.5, -150),
            BackgroundColor3: Color3::fromRGB(50, 50, 50),
            
            TextLabel {
                Text: format!("Count: {}", count.get()),
                Size: UDim2::new(1, 0, 0, 50),
                TextColor3: Color3::fromRGB(255, 255, 255),
                TextSize: 24,
                BackgroundTransparency: 1,
            },
            
            TextButton {
                Text: "Click to Increment",
                Size: UDim2::new(1, 0, 0, 50),
                Position: UDim2::new(0, 0, 0, 60),
                BackgroundColor3: Color3::fromRGB(0, 120, 215),
                TextColor3: Color3::fromRGB(255, 255, 255),
                Activated: || count.set(count.get() + 1),
            }
        }
    }
}
