use crate::*;

#[component]
pub fn AnimationDemo() -> UiNode {
    let is_animating = use_state(|| false);
    let animation_type = use_state(|| "fade".to_string());
    let progress = use_state(|| 0.0);
    
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            Frame {
                Size: UDim2.new(0, 500, 0, 600),
                Position: UDim2.new(0.5, -250, 0.5, -300),
                BackgroundColor3: Color3.fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                UIListLayout {
                    Padding: UDim.new(0, 16),
                },
                Frame {
                    Size: UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency: 1,
                    TextLabel {
                        Size: UDim2.new(1, 0, 1, 0),
                        Text: "Animation Demo",
                        TextSize: 24,
                        TextColor3: Color3.fromRGB(30, 41, 59),
                        Font: Enum.Font.GothamBold,
                        BackgroundTransparency: 1,
                    }
                }
                // Animation Preview
                Frame {
                    Size: UDim2.new(1, -32, 0, 200),
                    BackgroundColor3: Color3.fromRGB(248, 250, 252),
                    UIListLayout {
                        Padding: UDim.new(0, 8),
                    },
                    TextLabel {
                        Size: UDim2.new(1, 0, 0, 20),
                        Text: "Preview",
                        TextSize: 14,
                        TextColor3: Color3.fromRGB(107, 114, 128),
                        Font: Enum.Font.Gotham,
                        BackgroundTransparency: 1,
                    }
                    Frame {
                        Size: UDim2.new(1, -32, 1, -28),
                        BackgroundColor3: Color3.fromRGB(255, 255, 255),
                        AnimatedBox {
                            is_animating: is_animating.clone(),
                            animation_type: animation_type.clone(),
                            progress: progress.clone(),
                        }
                    }
                }
                // Controls
                Frame {
                    Size: UDim2.new(1, -32, 0, 150),
                    BackgroundTransparency: 1,
                    UIListLayout {
                        Padding: UDim.new(0, 12),
                    },
                    TextLabel {
                        Size: UDim2.new(1, 0, 0, 20),
                        Text: "Controls",
                        TextSize: 14,
                        TextColor3: Color3.fromRGB(107, 114, 128),
                        Font: Enum.Font.Gotham,
                        BackgroundTransparency: 1,
                    }
                    Frame {
                        Size: UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency: 1,
                        UIListLayout {
                            Padding: UDim.new(0, 8),
                            FillDirection: Enum.FillDirection.Horizontal,
                        },
                        TextButton {
                            Size: UDim2.new(0, 100, 1, 0),
                            BackgroundColor3: Color3.fromRGB(34, 197, 94),
                            Text: "Play",
                            TextSize: 16,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.GothamBold,
                            BorderSizePixel: 0,
                        }
                        TextButton {
                            Size: UDim2.new(0, 100, 1, 0),
                            BackgroundColor3: Color3.fromRGB(59, 130, 246),
                            Text: "Reset",
                            TextSize: 16,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.GothamBold,
                            BorderSizePixel: 0,
                        }
                    }
                    Frame {
                        Size: UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency: 1,
                        UIListLayout {
                            Padding: UDim.new(0, 8),
                            FillDirection: Enum.FillDirection.Horizontal,
                        },
                        TextButton {
                            Size: UDim2.new(0, 80, 1, 0),
                            BackgroundColor3: Color3.fromRGB(59, 130, 246),
                            Text: "Fade",
                            TextSize: 14,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.Gotham,
                            BorderSizePixel: 0,
                        }
                        TextButton {
                            Size: UDim2.new(0, 80, 1, 0),
                            BackgroundColor3: Color3.fromRGB(209, 213, 219),
                            Text: "Slide",
                            TextSize: 14,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.Gotham,
                            BorderSizePixel: 0,
                        }
                        TextButton {
                            Size: UDim2.new(0, 80, 1, 0),
                            BackgroundColor3: Color3.fromRGB(209, 213, 219),
                            Text: "Scale",
                            TextSize: 14,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.Gotham,
                            BorderSizePixel: 0,
                        }
                        TextButton {
                            Size: UDim2.new(0, 80, 1, 0),
                            BackgroundColor3: Color3.fromRGB(209, 213, 219),
                            Text: "Rotate",
                            TextSize: 14,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.Gotham,
                            BorderSizePixel: 0,
                        }
                    }
                }
                // Progress Bar
                Frame {
                    Size: UDim2.new(1, -32, 0, 30),
                    BackgroundTransparency: 1,
                    UIListLayout {
                        Padding: UDim.new(0, 8),
                    },
                    TextLabel {
                        Size: UDim2.new(1, 0, 0, 16),
                        Text: "Progress: 0%",
                        TextSize: 14,
                        TextColor3: Color3.fromRGB(107, 114, 128),
                        Font: Enum.Font.Gotham,
                        BackgroundTransparency: 1,
                    }
                    Frame {
                        Size: UDim2.new(1, 0, 0, 6),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                        Frame {
                            Size: UDim2.new(0, 0, 1, 0),
                            BackgroundColor3: Color3.fromRGB(59, 130, 246),
                        }
                    }
                }
            }
        }
    }
}

fn AnimatedBox(is_animating: bool, animation_type: String, progress: f64) -> UiNode {
    let opacity = if animation_type == "fade" { progress } else { 1.0 };
    let offset_x = if animation_type == "slide" { (progress - 0.5) * 200.0 } else { 0.0 };
    let scale = if animation_type == "scale" { 0.5 + progress * 0.5 } else { 1.0 };
    let rotation = if animation_type == "rotate" { progress * 360.0 } else { 0.0 };
    
    view! {
        Frame {
            Size: UDim2.new(0, 100, 0, 100),
            Position: UDim2.new(0.5, -50 + offset_x, 0.5, -50),
            BackgroundColor3: Color3.fromRGB(59, 130, 246),
            BackgroundTransparency: 1.0 - opacity,
            Rotation: rotation,
            AnchorPoint: Vector2.new(0.5, 0.5),
        }
    }
}
