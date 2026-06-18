use crate::prelude::*;

#[component]
pub fn SimpleButton() -> UiNode {
    let count = use_state(|| 0);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            TextButton {
                Size: UDim2::new(0, 200, 0, 50),
                Position: UDim2::new(0.5, -100, 0.5, -25),
                BackgroundColor3: Color3::fromRGB(100, 149, 237),
                Text: "Click Me",
                TextSize: 20,
                TextColor3: Color3::fromRGB(255, 255, 255),
                Font: Enum.Font.GothamBold,
            }
        }
    }
}

#[component]
pub fn ProgressBar() -> UiNode {
    let progress = use_state(|| 50.0);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 300, 0, 30),
                Position: UDim2::new(0.5, -150, 0.5, -15),
                BackgroundColor3: Color3::fromRGB(200, 200, 200),
                BorderSizePixel: 0,
                
                Frame {
                    Size: UDim2::new(0.5, 0, 1, 0),
                    BackgroundColor3: Color3::fromRGB(100, 149, 237),
                    BorderSizePixel: 0,
                }
            }
        }
    }
}

#[component]
pub fn ModalDialog() -> UiNode {
    let is_open = use_state(|| true);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 400, 0, 300),
                Position: UDim2::new(0.5, -200, 0.5, -150),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                
                TextLabel {
                    Size: UDim2::new(1, 0, 0, 50),
                    Text: "Modal Dialog",
                    TextSize: 24,
                    TextColor3: Color3::fromRGB(0, 0, 0),
                    Font: Enum.Font.GothamBold,
                    BackgroundTransparency: 1,
                    TextXAlignment: Enum.TextXAlignment.Center,
                },
                
                TextButton {
                    Size: UDim2::new(0, 100, 0, 40),
                    Position: UDim2::new(0.5, -50, 1, -50),
                    BackgroundColor3: Color3::fromRGB(100, 149, 237),
                    Text: "Close",
                    TextSize: 18,
                    TextColor3: Color3::fromRGB(255, 255, 255),
                    Font: Enum.Font.GothamBold,
                }
            }
        }
    }
}

#[component]
pub fn CardGrid() -> UiNode {
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(1, 0, 1, 0),
                BackgroundColor3: Color3::fromRGB(240, 240, 240),
                BorderSizePixel: 0,
                
                UIListLayout {
                    Padding: UDim::new(0, 10),
                    FillDirection: Enum.FillDirection.Horizontal,
                },
                
                Frame {
                    Size: UDim2::new(0, 200, 0, 150),
                    BackgroundColor3: Color3::fromRGB(255, 255, 255),
                    BorderSizePixel: 0,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Card 1",
                        TextSize: 20,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        Font: Enum.Font.GothamBold,
                        BackgroundTransparency: 1,
                        TextXAlignment: Enum.TextXAlignment.Center,
                        TextYAlignment: Enum.TextYAlignment.Center,
                    }
                },
                
                Frame {
                    Size: UDim2::new(0, 200, 0, 150),
                    BackgroundColor3: Color3::fromRGB(255, 255, 255),
                    BorderSizePixel: 0,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Card 2",
                        TextSize: 20,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        Font: Enum.Font.GothamBold,
                        BackgroundTransparency: 1,
                        TextXAlignment: Enum.TextXAlignment.Center,
                        TextYAlignment: Enum.TextYAlignment.Center,
                    }
                },
                
                Frame {
                    Size: UDim2::new(0, 200, 0, 150),
                    BackgroundColor3: Color3::fromRGB(255, 255, 255),
                    BorderSizePixel: 0,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Card 3",
                        TextSize: 20,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        Font: Enum.Font.GothamBold,
                        BackgroundTransparency: 1,
                        TextXAlignment: Enum.TextXAlignment.Center,
                        TextYAlignment: Enum.TextYAlignment.Center,
                    }
                }
            }
        }
    }
}
