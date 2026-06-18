use crate::prelude::*;

/// Theme provider for CSS-in-JS style theming
#[component]
pub fn ThemeProvider() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Theme configuration
pub struct Theme {
    pub colors: Colors,
    pub spacing: Spacing,
    pub typography: Typography,
    pub dark_mode: bool,
}

pub struct Colors {
    pub primary: String,
    pub secondary: String,
    pub background: String,
    pub surface: String,
    pub text: String,
    pub text_secondary: String,
    pub border: String,
    pub error: String,
    pub success: String,
    pub warning: String,
}

pub struct Spacing {
    pub xs: f32,
    pub sm: f32,
    pub md: f32,
    pub lg: f32,
    pub xl: f32,
}

pub struct Typography {
    pub font_size_base: f32,
    pub font_size_sm: f32,
    pub font_size_lg: f32,
    pub font_size_xl: f32,
    pub font_family: String,
}

/// Hook for using theme
pub fn use_theme() -> Theme {
    Theme {
        colors: Colors {
            primary: "#007AFF".to_string(),
            secondary: "#5856D6".to_string(),
            background: "#FFFFFF".to_string(),
            surface: "#F5F5F5".to_string(),
            text: "#000000".to_string(),
            text_secondary: "#666666".to_string(),
            border: "#E0E0E0".to_string(),
            error: "#FF3B30".to_string(),
            success: "#34C759".to_string(),
            warning: "#FFCC00".to_string(),
        },
        spacing: Spacing {
            xs: 4.0,
            sm: 8.0,
            md: 16.0,
            lg: 24.0,
            xl: 32.0,
        },
        typography: Typography {
            font_size_base: 14.0,
            font_size_sm: 12.0,
            font_size_lg: 16.0,
            font_size_xl: 20.0,
            font_family: "Gotham".to_string(),
        },
        dark_mode: false,
    }
}

/// Hook for dark mode toggle
pub fn use_dark_mode() -> (bool, Box<dyn Fn(bool)>) {
    (false, Box::new(|_| {}))
}
