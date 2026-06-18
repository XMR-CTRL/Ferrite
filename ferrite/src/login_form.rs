use crate::prelude::*;

/// A login form with email and password fields
#[component]
pub fn LoginForm() -> UiNode {
    let email = use_state(|| String::new());
    let password = use_state(|| String::new());
    let is_loading = use_state(|| false);

    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            Frame {
                Size: UDim2::new(0, 350, 0, 400),
                Position: UDim2::new(0.5, -175, 0.5, -200),
                BackgroundColor3: Color3::fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                
                UIListLayout {
                    Padding: UDim::new(0, 16),
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 60),
                    BackgroundTransparency: 1,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Sign In",
                        TextSize: 28,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        BackgroundTransparency: 1,
                        Font: Enum.Font.GothamBold,
                    }
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 50),
                    BackgroundTransparency: 1,
                    
                    UIListLayout {
                        Padding: UDim::new(0, 8),
                    }
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 0, 20),
                        Text: "Email",
                        TextSize: 14,
                        TextColor3: Color3::fromRGB(100, 100, 100),
                        BackgroundTransparency: 1,
                        Font: Enum.Font.Gotham,
                    }
                    
                    TextBox {
                        Size: UDim2::new(1, 0, 0, 30),
                        PlaceholderText: "you@example.com",
                        Text: email.clone(),
                        TextSize: 16,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        BackgroundColor3: Color3::fromRGB(245, 245, 245),
                        BorderSizePixel: 0,
                        ClearTextOnFocus: true,
                    }
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 50),
                    BackgroundTransparency: 1,
                    
                    UIListLayout {
                        Padding: UDim::new(0, 8),
                    }
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 0, 20),
                        Text: "Password",
                        TextSize: 14,
                        TextColor3: Color3::fromRGB(100, 100, 100),
                        BackgroundTransparency: 1,
                        Font: Enum.Font.Gotham,
                    }
                    
                    TextBox {
                        Size: UDim2::new(1, 0, 0, 30),
                        PlaceholderText: "••••••••",
                        Text: password.clone(),
                        TextSize: 16,
                        TextColor3: Color3::fromRGB(0, 0, 0),
                        BackgroundColor3: Color3::fromRGB(245, 245, 245),
                        BorderSizePixel: 0,
                        ClearTextOnFocus: true,
                    }
                }
                
                TextButton {
                    Size: UDim2::new(1, 0, 0, 50),
                    Text: if *is_loading { "Loading..." } else { "Sign In" },
                    TextSize: 16,
                    TextColor3: Color3::fromRGB(255, 255, 255),
                    BackgroundColor3: Color3::fromRGB(0, 122, 255),
                    BorderSizePixel: 0,
                    Font: Enum.Font.GothamBold,
                }
                
                Frame {
                    Size: UDim2::new(1, 0, 0, 20),
                    BackgroundTransparency: 1,
                    
                    TextLabel {
                        Size: UDim2::new(1, 0, 1, 0),
                        Text: "Don't have an account? Sign up",
                        TextSize: 14,
                        TextColor3: Color3::fromRGB(0, 122, 255),
                        BackgroundTransparency: 1,
                        Font: Enum.Font.Gotham,
                    }
                }
            }
        }
    }
}
