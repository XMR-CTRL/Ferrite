use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum PropValue {
    Static(String),
    Dynamic(DynamicProp),
    Event(String),
    Animated(AnimatedProp),
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct DynamicProp {
    pub expression: String,
    pub dependencies: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AnimatedProp {
    pub target_value: String,
    pub config: AnimationConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AnimationConfig {
    pub animation_type: AnimationType,
    pub duration: Option<f32>,
    pub easing: Option<String>,
    pub delay: Option<f32>,
    pub spring_config: Option<SpringConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum AnimationType {
    Tween,
    Spring,
    Keyframe,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct SpringConfig {
    pub tension: Option<f32>,
    pub friction: Option<f32>,
    pub mass: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct UiNode {
    pub class: String,
    pub props: Vec<(String, PropValue)>,
    pub children: Vec<UiNode>,
    pub is_static: bool,
    pub key: Option<String>,
}

impl UiNode {
    pub fn new(class: String, props: Vec<(String, PropValue)>, children: Vec<UiNode>) -> Self {
        Self::new_with_key(class, props, children, None)
    }

    pub fn new_with_key(class: String, props: Vec<(String, PropValue)>, children: Vec<UiNode>, key: Option<String>) -> Self {
        // Extract key from props if present and not already provided
        let key = key.or_else(|| {
            props.iter()
                .find(|(k, _)| k == "Key")
                .and_then(|(_, v)| match v {
                    PropValue::Static(s) => Some(s.trim_matches('"').to_string()),
                    PropValue::Dynamic(d) => Some(d.expression.trim_matches('"').to_string()),
                    _ => None,
                })
        });

        let is_static = props.iter().all(|(_, val)| match val {
            PropValue::Static(_) => true,
            PropValue::Animated(_) => false,
            _ => false,
        }) && children.iter().all(|c| c.is_static);

        Self {
            class,
            props,
            children,
            is_static,
            key,
        }
    }
}
