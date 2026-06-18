use crate::*;

#[component]
pub fn SettingsPanel() -> UiNode {
    let settings = use_state(|| Settings {
        notifications_enabled: true,
        dark_mode: false,
        auto_save: true,
        volume: 75,
        language: "en".to_string(),
        theme: "blue".to_string(),
    });
    
    let active_section = use_state(|| "general".to_string());
    
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            Frame {
                Size: UDim2.new(0, 600, 0, 500),
                Position: UDim2.new(0.5, -300, 0.5, -250),
                BackgroundColor3: Color3.fromRGB(255, 255, 255),
                BorderSizePixel: 0,
                UIListLayout {
                    Padding: UDim.new(0, 0),
                    FillDirection: Enum.FillDirection.Horizontal,
                },
                // Sidebar
                Frame {
                    Size: UDim2.new(0, 180, 1, 0),
                    BackgroundColor3: Color3.fromRGB(248, 250, 252),
                    UIListLayout {
                        Padding: UDim.new(0, 4),
                    },
                    Frame {
                        Size: UDim2.new(1, 0, 0, 50),
                        BackgroundTransparency: 1,
                        TextLabel {
                            Size: UDim2.new(1, 0, 1, 0),
                            Text: "Settings",
                            TextSize: 20,
                            TextColor3: Color3.fromRGB(30, 41, 59),
                            Font: Enum.Font.GothamBold,
                            BackgroundTransparency: 1,
                        }
                    }
                    SettingsNavItem {
                        label: "General",
                        active: true,
                    }
                    SettingsNavItem {
                        label: "Appearance",
                        active: false,
                    }
                    SettingsNavItem {
                        label: "Notifications",
                        active: false,
                    }
                }
                // Content
                Frame {
                    Size: UDim2.new(1, -180, 1, 0),
                    BackgroundTransparency: 1,
                    UIListLayout {
                        Padding: UDim.new(0, 16),
                    },
                    Frame {
                        Size: UDim2.new(1, 0, 0, 50),
                        BackgroundTransparency: 1,
                        TextLabel {
                            Size: UDim2.new(1, 0, 1, 0),
                            Text: "Settings",
                            TextSize: 24,
                            TextColor3: Color3.fromRGB(30, 41, 59),
                            Font: Enum.Font.GothamBold,
                            BackgroundTransparency: 1,
                        }
                    }
                    // General Settings
                    Frame {
                        Size: UDim2.new(1, 0, 0, 1),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                    }
                    SettingToggle {
                        label: "Auto Save",
                        description: "Automatically save your work",
                        enabled: settings.auto_save,
                    }
                    Frame {
                        Size: UDim2.new(1, 0, 0, 1),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                    }
                    SettingSlider {
                        label: "Volume",
                        value: settings.volume,
                        min: 0,
                        max: 100,
                    }
                    // Appearance Settings
                    Frame {
                        Size: UDim2.new(1, 0, 0, 1),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                    }
                    SettingToggle {
                        label: "Dark Mode",
                        description: "Enable dark theme",
                        enabled: settings.dark_mode,
                    }
                    Frame {
                        Size: UDim2.new(1, 0, 0, 1),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                    }
                    SettingDropdown {
                        label: "Theme",
                        options: vec!["blue".to_string(), "green".to_string(), "purple".to_string()],
                        selected: settings.theme.clone(),
                    }
                    // Notification Settings
                    Frame {
                        Size: UDim2.new(1, 0, 0, 1),
                        BackgroundColor3: Color3.fromRGB(229, 231, 235),
                    }
                    SettingToggle {
                        label: "Enable Notifications",
                        description: "Receive push notifications",
                        enabled: settings.notifications_enabled,
                    }
                }
            }
        }
    }
}

#[derive(Clone)]
struct Settings {
    notifications_enabled: bool,
    dark_mode: bool,
    auto_save: bool,
    volume: i32,
    language: String,
    theme: String,
}

fn SettingsNavItem(label: String, active: bool) -> UiNode {
    view! {
        TextButton {
            Size: UDim2.new(1, -16, 0, 40),
            BackgroundColor3: if active { Color3.fromRGB(59, 130, 246) } else { Color3.fromRGB(248, 250, 252) },
            Text: label.clone(),
            TextSize: 14,
            TextColor3: if active { Color3.fromRGB(255, 255, 255) } else { Color3.fromRGB(71, 85, 105) },
            Font: Enum.Font.Gotham,
            BorderSizePixel: 0,
        }
    }
}

fn SettingToggle(label: String, description: String, enabled: bool) -> UiNode {
    view! {
        Frame {
            Size: UDim2.new(1, 0, 0, 60),
            BackgroundTransparency: 1,
            UIListLayout {
                Padding: UDim.new(0, 4),
            },
            TextLabel {
                Size: UDim2.new(1, -60, 0, 20),
                Text: label,
                TextSize: 16,
                TextColor3: Color3.fromRGB(30, 41, 59),
                Font: Enum.Font.GothamBold,
                BackgroundTransparency: 1,
            }
            TextLabel {
                Size: UDim2.new(1, -60, 0, 16),
                Text: description,
                TextSize: 12,
                TextColor3: Color3.fromRGB(107, 114, 128),
                Font: Enum.Font.Gotham,
                BackgroundTransparency: 1,
            }
            TextButton {
                Size: UDim2.new(0, 50, 0, 26),
                Position: UDim2.new(1, -55, 0, 17),
                BackgroundColor3: Color3.fromRGB(34, 197, 94),
                Text: "ON",
                TextSize: 12,
                TextColor3: Color3.fromRGB(255, 255, 255),
                Font: Enum.Font.GothamBold,
                BorderSizePixel: 0,
            }
        }
    }
}

fn SettingSlider(label: String, value: i32, min: i32, max: i32) -> UiNode {
    view! {
        Frame {
            Size: UDim2.new(1, 0, 0, 50),
            BackgroundTransparency: 1,
            UIListLayout {
                Padding: UDim.new(0, 4),
            },
            TextLabel {
                Size: UDim2.new(1, 0, 0, 20),
                Text: label,
                TextSize: 16,
                TextColor3: Color3.fromRGB(30, 41, 59),
                Font: Enum.Font.GothamBold,
                BackgroundTransparency: 1,
            }
            Frame {
                Size: UDim2.new(1, 0, 0, 20),
                BackgroundColor3: Color3.fromRGB(229, 231, 235),
                Frame {
                    Size: UDim2.new(0.75, 0, 1, 0),
                    BackgroundColor3: Color3.fromRGB(59, 130, 246),
                }
            }
        }
    }
}

fn SettingDropdown(label: String, options: Vec<String>, selected: String) -> UiNode {
    view! {
        Frame {
            Size: UDim2.new(1, 0, 0, 50),
            BackgroundTransparency: 1,
            UIListLayout {
                Padding: UDim.new(0, 4),
            },
            TextLabel {
                Size: UDim2.new(1, 0, 0, 20),
                Text: label,
                TextSize: 16,
                TextColor3: Color3.fromRGB(30, 41, 59),
                Font: Enum.Font.GothamBold,
                BackgroundTransparency: 1,
            }
            TextButton {
                Size: UDim2.new(1, 0, 0, 26),
                BackgroundColor3: Color3.fromRGB(255, 255, 255),
                BorderSizePixel: 1,
                BorderColor3: Color3.fromRGB(209, 213, 219),
                Text: "blue",
                TextSize: 14,
                TextColor3: Color3.fromRGB(30, 41, 59),
                Font: Enum.Font.Gotham,
            }
        }
    }
}
