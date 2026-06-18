use crate::*;

#[component]
pub fn BadCodeApp() -> UiNode {
    let x = use_state(|| Vec::<()>::new());
    let y = use_state(|| String::new());
    let z = use_state(|| 0);
    let _unused = "this is unused";
    let _also_unused = 42;
    
    let messy_var_1 = use_state(|| false);
    let messyVar2 = use_state(|| "test".to_string());
    let MESSY_VAR_3 = use_state(|| 100);
    
    let redundant = if true { true } else { false };
    let _more_redundant = match redundant {
        true => true,
        false => false,
    };
    
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            Frame {
                Size: UDim2.new(0, 400, 0, 300),
                Position: UDim2.new(0.5, -200, 0.5, -150),
                BackgroundColor3: Color3.fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                UIListLayout {
                    Padding: UDim.new(0, 8),
                },
                TextLabel {
                    Size: UDim2.new(1, 0, 0, 40),
                    Text: "Bad Code App",
                    TextSize: 24,
                    TextColor3: Color3.fromRGB(0, 0, 0),
                    Font: Enum.Font.GothamBold,
                    BackgroundTransparency: 1,
                }
                TextLabel {
                    Size: UDim2.new(1, 0, 0, 30),
                    Text: format!("Count: {}", z.clone()),
                    TextSize: 18,
                    TextColor3: Color3.fromRGB(0, 0, 0),
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
                        Size: UDim2.new(0, 80, 1, 0),
                        BackgroundColor3: Color3.fromRGB(59, 130, 246),
                        Text: "+",
                        TextSize: 24,
                        TextColor3: Color3.fromRGB(255, 255, 255),
                        Font: Enum.Font.GothamBold,
                        BorderSizePixel: 0,
                    }
                    TextButton {
                        Size: UDim2.new(0, 80, 1, 0),
                        BackgroundColor3: Color3.fromRGB(239, 68, 68),
                        Text: "-",
                        TextSize: 24,
                        TextColor3: Color3.fromRGB(255, 255, 255),
                        Font: Enum.Font.GothamBold,
                        BorderSizePixel: 0,
                    }
                }
                TextLabel {
                    Size: UDim2.new(1, 0, 0, 30),
                    Text: format!("Input: {}", y.clone()),
                    TextSize: 16,
                    TextColor3: Color3.fromRGB(0, 0, 0),
                    Font: Enum.Font.Gotham,
                    BackgroundTransparency: 1,
                }
                TextBox {
                    Size: UDim2.new(1, 0, 0, 30),
                    PlaceholderText: "Type something...",
                    TextSize: 16,
                    TextColor3: Color3.fromRGB(0, 0, 0),
                    BackgroundColor3: Color3.fromRGB(240, 240, 240),
                    BorderSizePixel: 0,
                }
            }
        }
    }
}
