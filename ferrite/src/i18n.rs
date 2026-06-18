use crate::prelude::*;

/// Internationalization support
#[component]
pub fn I18nProvider() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Translation dictionary
pub struct Translations {
    pub locale: String,
    pub messages: std::collections::HashMap<String, String>,
}

/// Hook for translations
pub fn use_translation(_locale: &str) -> Translations {
    Translations {
        locale: "en".to_string(),
        messages: std::collections::HashMap::new(),
    }
}

/// Hook for current locale
pub fn use_locale() -> String {
    "en".to_string()
}

/// Hook for changing locale
pub fn use_locale_change() -> Box<dyn Fn(String)> {
    Box::new(|_| {})
}

/// Format message with parameters
pub fn format_message(_message: &str, _params: &std::collections::HashMap<String, String>) -> String {
    String::new()
}
