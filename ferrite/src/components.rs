use crate::prelude::*;

#[component]
pub fn Button() -> UiNode {
    view! {
        TextButton {
            Size: UDim2::new(0, 100, 0, 32),
            BackgroundColor3: Color3::fromRGB(0, 120, 215),
            TextColor3: Color3::fromRGB(255, 255, 255),
            TextSize: 16,
            BorderSizePixel: 0,
            
            UICorner {
                CornerRadius: UDim::new(0, 4),
            }
            
            UIPadding {
                PaddingLeft: UDim::new(0, 16),
                PaddingRight: UDim::new(0, 16),
                PaddingTop: UDim::new(0, 8),
                PaddingBottom: UDim::new(0, 8),
            }
        }
    }
}

#[component]
pub fn Card() -> UiNode {
    view! {
        Frame {
            BackgroundColor3: Color3::fromRGB(255, 255, 255),
            BorderSizePixel: 0,
            
            UICorner {
                CornerRadius: UDim::new(0, 8),
            }
            
            UIStroke {
                Color: Color3::fromRGB(200, 200, 200),
                Thickness: 1,
            }
            
            UIPadding {
                PaddingLeft: UDim::new(0, 16),
                PaddingRight: UDim::new(0, 16),
                PaddingTop: UDim::new(0, 16),
                PaddingBottom: UDim::new(0, 16),
            }
        }
    }
}

#[component]
pub fn Input() -> UiNode {
    view! {
        Frame {
            BackgroundColor3: Color3::fromRGB(255, 255, 255),
            BorderSizePixel: 0,
            
            UICorner {
                CornerRadius: UDim::new(0, 4),
            }
            
            UIStroke {
                Color: Color3::fromRGB(200, 200, 200),
                Thickness: 1,
            }
            
            TextBox {
                Size: UDim2::new(1, 0, 1, 0),
                BackgroundTransparency: 1,
                TextColor3: Color3::fromRGB(0, 0, 0),
                TextSize: 16,
                ClearTextOnFocus: false,
                BorderSizePixel: 0,
                
                UIPadding {
                    PaddingLeft: UDim::new(0, 12),
                    PaddingRight: UDim::new(0, 12),
                    PaddingTop: UDim::new(0, 6),
                    PaddingBottom: UDim::new(0, 6),
                }
            }
        }
    }
}

#[component]
pub fn Modal() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundColor3: Color3::fromRGB(0, 0, 0),
            BackgroundTransparency: 0.5,
            ZIndex: 1000,
            
            Frame {
                Size: UDim2::new(0, 400, 0, 300),
                Position: UDim2::new(0.5, -200, 0.5, -150),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                AnchorPoint: Vector2::new(0.5, 0.5),
                
                UICorner {
                    CornerRadius: UDim::new(0, 8),
                }
                
                UIPadding {
                    PaddingLeft: UDim::new(0, 24),
                    PaddingRight: UDim::new(0, 24),
                    PaddingTop: UDim::new(0, 24),
                    PaddingBottom: UDim::new(0, 24),
                }
            }
        }
    }
}

#[component]
pub fn Spinner() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(0, 40, 0, 40),
            BackgroundTransparency: 1,
            
            ImageLabel {
                Size: UDim2::new(1, 0, 1, 0),
                BackgroundTransparency: 1,
                Image: "rbxassetid://4944326298",
                Rotation: 0,
            }
        }
    }
}
