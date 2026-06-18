use crate::prelude::*;

/// A simple counter app with increment/decrement buttons
#[component]
pub fn CounterApp() -> UiNode {
    let count = use_state(|| 0);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 200, 0, 150),
                Position: UDim2::new(0.5, -100, 0.5, -75),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                
                UIListLayout {
                    Padding: UDim::new(0, 8),
                    HorizontalAlignment: Enum.HorizontalAlignment.Center,
                }
                
                TextLabel {
                    Size: UDim2::new(1, 0, 0, 30),
                    Text: "Counter App",
                    TextSize: 20,
                    TextColor3: Color3::fromRGB(0, 0, 0),
                    BackgroundTransparency: 1,
                    Font: Enum.Font.GothamBold,
                }
                
                TextLabel {
                    Size: UDim2::new(1, 0, 0, 40),
                    Text: count.to_string(),
                    TextSize: 32,
                    TextColor3: Color3::fromRGB(0, 122, 255),
                    BackgroundTransparency: 1,
                    Font: Enum.Font.GothamBold,
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 40),
                    BackgroundTransparency: 1,
                    
                    UIListLayout {
                        FillDirection: Enum.FillDirection.Horizontal,
                        Padding: UDim::new(0, 8),
                    }
                    
                    TextButton {
                        Size: UDim2::new(0, 60, 1, 0),
                        Text: "-",
                        TextSize: 24,
                        TextColor3: Color3::fromRGB(255, 255, 255),
                        BackgroundColor3: Color3::fromRGB(255, 59, 48),
                        BorderSizePixel: 0,
                        Font: Enum.Font.GothamBold,
                    }
                    
                    TextButton {
                        Size: UDim2::new(0, 60, 1, 0),
                        Text: "+",
                        TextSize: 24,
                        TextColor3: Color3::fromRGB(255, 255, 255),
                        BackgroundColor3: Color3::fromRGB(52, 199, 89),
                        BorderSizePixel: 0,
                        Font: Enum.Font.GothamBold,
                    }
                }
            }
        }
    }
}
