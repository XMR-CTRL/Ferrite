use std::collections::{HashSet, HashMap};
use serde::{Deserialize, Serialize};
use std::sync::OnceLock;

static API_CACHE: OnceLock<ApiDump> = OnceLock::new();

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiDump {
    #[serde(rename = "Classes")]
    pub classes: Vec<ApiClass>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiClass {
    #[serde(rename = "Name")]
    pub name: String,
    
    #[serde(rename = "Members")]
    pub members: Vec<ApiMember>,
    
    #[serde(rename = "Superclass", default)]
    pub superclass: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "MemberType")]
pub enum ApiMember {
    Property {
        #[serde(rename = "Name")]
        name: String,
        
        #[serde(rename = "Security", default)]
        security: ApiSecurity,
        
        #[serde(rename = "Tags", default)]
        tags: Vec<String>,
    },
    Event {
        #[serde(rename = "Name")]
        name: String,
        
        #[serde(rename = "Security", default)]
        security: ApiSecurity,
    },
    Function {
        #[serde(rename = "Name")]
        name: String,
    },
    Callback {
        #[serde(rename = "Name")]
        name: String,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ApiSecurity {
    #[serde(rename = "Read", default)]
    pub read: String,
    
    #[serde(rename = "Write", default)]
    pub write: String,
}

impl ApiDump {
    /// Load API dump from JSON file or use embedded fallback
    pub fn load() -> &'static Self {
        API_CACHE.get_or_init(|| {
            // Try loading from API-Dump.json in current directory or parent directory
            let content = std::fs::read_to_string("API-Dump.json")
                .or_else(|_| std::fs::read_to_string("../API-Dump.json"));
            if let Ok(content) = content {
                if let Ok(dump) = serde_json::from_str::<ApiDump>(&content) {
                    return dump;
                }
            }
            
            // Fallback to embedded minimal schema
            Self::fallback()
        })
    }
    
    /// Fallback minimal schema for common UI classes
    fn fallback() -> Self {
        let json = r#"{
            "Classes": [
                {
                    "Name": "Instance",
                    "Superclass": "",
                    "Members": [
                        {"MemberType": "Property", "Name": "Name", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Parent", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "GuiObject",
                    "Superclass": "GuiBase2d",
                    "Members": [
                        {"MemberType": "Property", "Name": "Size", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Position", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "AnchorPoint", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "BackgroundColor3", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "BackgroundTransparency", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "BorderSizePixel", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "BorderColor3", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Visible", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "ZIndex", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Rotation", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "ClipsDescendants", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "LayoutOrder", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "Frame",
                    "Superclass": "GuiObject",
                    "Members": []
                },
                {
                    "Name": "TextLabel",
                    "Superclass": "GuiObject",
                    "Members": [
                        {"MemberType": "Property", "Name": "Text", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextColor3", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextSize", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Font", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextXAlignment", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextYAlignment", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextScaled", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextWrapped", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TextTransparency", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "RichText", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "TextButton",
                    "Superclass": "TextLabel",
                    "Members": [
                        {"MemberType": "Property", "Name": "AutoButtonColor", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Event", "Name": "Activated", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseButton1Click", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseEnter", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseLeave", "Security": {"Read": "None", "Write": "None"}}
                    ]
                },
                {
                    "Name": "ImageLabel",
                    "Superclass": "GuiObject",
                    "Members": [
                        {"MemberType": "Property", "Name": "Image", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "ImageColor3", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "ImageTransparency", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "ScaleType", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "TileSize", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "ImageButton",
                    "Superclass": "ImageLabel",
                    "Members": [
                        {"MemberType": "Property", "Name": "AutoButtonColor", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Event", "Name": "Activated", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseButton1Click", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseEnter", "Security": {"Read": "None", "Write": "None"}},
                        {"MemberType": "Event", "Name": "MouseLeave", "Security": {"Read": "None", "Write": "None"}}
                    ]
                },
                {
                    "Name": "UIListLayout",
                    "Superclass": "UILayout",
                    "Members": [
                        {"MemberType": "Property", "Name": "FillDirection", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "HorizontalAlignment", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "VerticalAlignment", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "SortOrder", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Padding", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "UIPadding",
                    "Superclass": "UIComponent",
                    "Members": [
                        {"MemberType": "Property", "Name": "PaddingTop", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "PaddingBottom", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "PaddingLeft", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "PaddingRight", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "UICorner",
                    "Superclass": "UIComponent",
                    "Members": [
                        {"MemberType": "Property", "Name": "CornerRadius", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "UIStroke",
                    "Superclass": "UIComponent",
                    "Members": [
                        {"MemberType": "Property", "Name": "Color", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Thickness", "Security": {"Read": "None", "Write": "None"}, "Tags": []},
                        {"MemberType": "Property", "Name": "Transparency", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                },
                {
                    "Name": "UIScale",
                    "Superclass": "UIComponent",
                    "Members": [
                        {"MemberType": "Property", "Name": "Scale", "Security": {"Read": "None", "Write": "None"}, "Tags": []}
                    ]
                }
            ]
        }"#;
        
        serde_json::from_str(json).expect("Fallback schema must be valid")
    }
    
    /// Build a map of class -> valid properties/events for efficient lookup
    pub fn build_property_map(&self) -> HashMap<String, HashSet<String>> {
        let mut map: HashMap<String, HashSet<String>> = HashMap::new();
        
        for class in &self.classes {
            let mut props = HashSet::new();
            self.collect_inherited_members(&class.name, &mut props);
            map.insert(class.name.clone(), props);
        }
        
        map
    }
    
    fn collect_inherited_members(&self, class_name: &str, accumulator: &mut HashSet<String>) {
        if let Some(class) = self.classes.iter().find(|c| c.name == class_name) {
            for member in &class.members {
                match member {
                    ApiMember::Property { name, security, tags } => {
                        // Only include scriptable properties (no PluginSecurity, RobloxScriptSecurity)
                        if security.write == "None" || security.write.is_empty() {
                            if !tags.contains(&"Deprecated".to_string()) && !tags.contains(&"NotScriptable".to_string()) {
                                accumulator.insert(name.clone());
                            }
                        }
                    }
                    ApiMember::Event { name, .. } => {
                        accumulator.insert(name.clone());
                    }
                    _ => {}
                }
            }
            
            // Recursively inherit from superclass
            if !class.superclass.is_empty() {
                self.collect_inherited_members(&class.superclass, accumulator);
            }
        }
    }
}

pub fn validate_property(class_name: &str, prop_name: &str) -> Result<(), String> {
    // Special case: Key is metadata for reconciler
    if prop_name == "Key" {
        return Ok(());
    }
    
    let api = ApiDump::load();
    let prop_map = api.build_property_map();
    
    if let Some(valid_props) = prop_map.get(class_name) {
        if valid_props.contains(prop_name) {
            Ok(())
        } else {
            Err(format!(
                "Property '{}' is not valid for Roblox class '{}'. Valid properties: {:?}",
                prop_name, class_name, valid_props
            ))
        }
    } else {
        // Unknown class — allow without validation (extensibility)
        eprintln!("Warning: Class '{}' not found in API dump. Skipping validation for property '{}'.", class_name, prop_name);
        Ok(())
    }
}
