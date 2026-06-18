use crate::*;

#[component]
pub fn Dashboard() -> UiNode {
    let stats = use_state(|| Stats {
        users: 1250,
        revenue: 45000,
        sessions: 890,
        conversion: 12.5,
    });
    
    let active_tab = use_state(|| "overview".to_string());
    let notifications = use_state(|| Vec::<Notification>::new());
    
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            Frame {
                Size: UDim2.new(1, 0, 1, 0),
                BackgroundColor3: Color3.fromRGB(245, 247, 250),
                UIListLayout {
                    Padding: UDim.new(0, 0),
                    FillDirection: Enum.FillDirection.Horizontal,
                },
                // Sidebar
                Frame {
                    Size: UDim2.new(0, 250, 1, 0),
                    BackgroundColor3: Color3.fromRGB(30, 41, 59),
                    UIListLayout {
                        Padding: UDim.new(0, 8),
                    },
                    Frame {
                        Size: UDim2.new(1, 0, 0, 60),
                        BackgroundTransparency: 1,
                        TextLabel {
                            Size: UDim2.new(1, 0, 1, 0),
                            Text: "Dashboard",
                            TextSize: 24,
                            TextColor3: Color3.fromRGB(255, 255, 255),
                            Font: Enum.Font.GothamBold,
                            BackgroundTransparency: 1,
                        }
                    }
                    SidebarItem {
                        label: "Overview",
                        active: true,
                    }
                    SidebarItem {
                        label: "Analytics",
                        active: false,
                    }
                    SidebarItem {
                        label: "Users",
                        active: false,
                    }
                }
                // Main Content
                Frame {
                    Size: UDim2.new(1, -250, 1, 0),
                    BackgroundTransparency: 1,
                    UIListLayout {
                        Padding: UDim.new(0, 16),
                    },
                    // Header
                    Frame {
                        Size: UDim2.new(1, 0, 0, 60),
                        BackgroundTransparency: 1,
                        TextLabel {
                            Size: UDim2.new(1, -100, 1, 0),
                            Text: "Dashboard",
                            TextSize: 28,
                            TextColor3: Color3.fromRGB(30, 41, 59),
                            Font: Enum.Font.GothamBold,
                            BackgroundTransparency: 1,
                        }
                    }
                    // Stats Grid
                    Frame {
                        Size: UDim2.new(1, 0, 0, 200),
                        BackgroundTransparency: 1,
                        UIGridLayout {
                            CellSize: UDim2.new(0, 250, 0, 90),
                            CellPadding: UDim2.new(0, 16, 0, 16),
                        },
                        StatCard {
                            title: "Total Users",
                            value: "1250",
                            change: "+12.5%",
                            positive: true,
                        }
                        StatCard {
                            title: "Revenue",
                            value: "$45000",
                            change: "+8.2%",
                            positive: true,
                        }
                        StatCard {
                            title: "Sessions",
                            value: "890",
                            change: "-3.1%",
                            positive: false,
                        }
                        StatCard {
                            title: "Conversion",
                            value: "12.5%",
                            change: "+2.4%",
                            positive: true,
                        }
                    }
                }
            }
        }
    }
}

#[derive(Clone)]
struct Stats {
    users: i32,
    revenue: i32,
    sessions: i32,
    conversion: f64,
}

#[derive(Clone)]
struct Notification {
    message: String,
    time: String,
}

fn SidebarItem(label: String, active: bool) -> UiNode {
    view! {
        TextButton {
            Size: UDim2.new(1, -32, 0, 44),
            BackgroundColor3: if active { Color3.fromRGB(59, 130, 246) } else { Color3.fromRGB(30, 41, 59) },
            Text: label.clone(),
            TextSize: 16,
            TextColor3: Color3.fromRGB(255, 255, 255),
            Font: Enum.Font.Gotham,
            BorderSizePixel: 0,
        }
    }
}

fn StatCard(title: String, value: String, change: String, positive: bool) -> UiNode {
    view! {
        Frame {
            Size: UDim2.new(1, 0, 1, 0),
            BackgroundColor3: Color3.fromRGB(255, 255, 255),
            BorderSizePixel: 0,
            UIListLayout {
                Padding: UDim.new(0, 8),
            },
            TextLabel {
                Size: UDim2.new(1, 0, 0, 20),
                Text: title,
                TextSize: 14,
                TextColor3: Color3.fromRGB(107, 114, 128),
                Font: Enum.Font.Gotham,
                BackgroundTransparency: 1,
            }
            TextLabel {
                Size: UDim2.new(1, 0, 0, 30),
                Text: value,
                TextSize: 24,
                TextColor3: Color3.fromRGB(30, 41, 59),
                Font: Enum.Font.GothamBold,
                BackgroundTransparency: 1,
            }
            TextLabel {
                Size: UDim2.new(1, 0, 0, 20),
                Text: change,
                TextSize: 14,
                TextColor3: if positive { Color3.fromRGB(34, 197, 94) } else { Color3.fromRGB(239, 68, 68) },
                Font: Enum.Font.Gotham,
                BackgroundTransparency: 1,
            }
        }
    }
}
