use crate::prelude::*;

/// A todo list app with add/remove functionality
#[component]
pub fn TodoApp() -> UiNode {
    let todos = use_state(|| Vec::<String>::new());
    let input = use_state(|| String::new());

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 400, 0, 500),
                Position: UDim2::new(0.5, -200, 0.5, -250),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                
                UIListLayout {
                    Padding: UDim::new(0, 12),
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 60),
                    BackgroundTransparency: 1,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Todo App",
                        TextSize: 24,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        BackgroundTransparency: 1,
                        Font: Enum.Font.GothamBold,
                    }
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 40),
                    BackgroundTransparency: 1,
                    
                    UIListLayout {
                        FillDirection: Enum.FillDirection.Horizontal,
                        Padding: UDim::new(0, 8),
                    }
                    
                    TextBox {
                        Size: UDim2::new(1, -80, 1, 0),
                        PlaceholderText: "Add a todo...",
                        Text: input.clone(),
                        TextSize: 16,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        BackgroundColor3: Color3::fromRGB(240, 240, 240),
                        BorderSizePixel: 0,
                        ClearTextOnFocus: true,
                    }
                    
                    TextButton {
                        Size: UDim2::new(0, 60, 1, 0),
                        Text: "Add",
                        TextSize: 16,
                        TextColor3: Color3::fromRGB(255, 255, 255),
                        BackgroundColor3: Color3::fromRGB(0, 122, 255),
                        BorderSizePixel: 0,
                        Font: Enum.Font.GothamBold,
                    }
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 1, -112),
                    BackgroundTransparency: 1,
                    
                    UIListLayout {
                        Padding: UDim::new(0, 8),
                    }
                }
            }
        }
    }
}
