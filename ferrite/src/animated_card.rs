use crate::prelude::*;

#[component]
pub fn AnimatedCard() -> UiNode {
    let is_hovered = use_state(|| false);
    let scale = use_state(|| 1.0);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 400, 0, 300),
                Position: UDim2::new(0.5, -200, 0.5, -150),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                
                UIScale {
                    Scale: 1.0,
                },
                
                UIPadding {
                    PaddingLeft: UDim::new(0, 20),
                    PaddingRight: UDim::new(0, 20),
                    PaddingTop: UDim::new(0, 20),
                    PaddingBottom: UDim::new(0, 20),
                },
                
                UIListLayout {
                    Padding: UDim::new(0, 20),
                    FillDirection: Enum.FillDirection.Vertical,
                    HorizontalAlignment: Enum.HorizontalAlignment.Center,
                },
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 150),
                    BackgroundColor3: Color3::fromRGB(100, 149, 237),
                    BorderSizePixel: 0,
                    
                    Frame {
                        Size: UDim2::new(0, 60, 0, 60),
                        Position: UDim2::new(0.5, -30, 0.5, -30),
                        BackgroundColor3: Color3::fromRGB(255, 255, 255),
                        BorderSizePixel: 0,
                    },
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 0, 30),
                        Position: UDim2::new(0, 0, 1, 10),
                        Text: "Welcome",
                        TextSize: 24,
                        TextColor3: Color3::fromRGB(255, 255, 255),
                        Font: Enum.Font.GothamBold,
                        BackgroundTransparency: 1,
                        TextXAlignment: Enum.TextXAlignment.Center,
                    },
                },
                
                TextLabel {
                    Size: UDim2::new(1, 0, 0, 60),
                    Text: "This is a beautiful animated card with smooth transitions and modern design.",
                    TextSize: 16,
                    TextColor3: Color3::fromRGB(100, 100, 100),
                    Font: Enum.Font.Gotham,
                    BackgroundTransparency: 1,
                    TextWrapped: true,
                    TextXAlignment: Enum.TextXAlignment.Center,
                    TextYAlignment: Enum.TextYAlignment.Top,
                },
                
                TextButton {
                    Size: UDim2::new(0, 120, 0, 40),
                    BackgroundColor3: Color3::fromRGB(100, 149, 237),
                    BorderSizePixel: 0,
                    Text: "Get Started",
                    TextSize: 18,
                    TextColor3: Color3::fromRGB(255, 255, 255),
                    Font: Enum.Font.GothamBold,
                    BackgroundTransparency: 0,
                    TextXAlignment: Enum.TextXAlignment.Center,
                    TextYAlignment: Enum.TextYAlignment.Center,
                },
            }
        }
    }
}
