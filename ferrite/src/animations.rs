use crate::prelude::*;

/// Physics-based animation system
#[component]
pub fn Animated() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
        }
    }
}

/// Animation configuration
pub struct AnimationConfig {
    pub duration: f32,
    pub easing: EasingFunction,
    pub delay: f32,
}

pub enum EasingFunction {
    Linear,
    EaseIn,
    EaseOut,
    EaseInOut,
    Spring { stiffness: f32, damping: f32 },
}

/// Hook for animations
pub fn use_animation(_config: AnimationConfig) {
    // This will be implemented by the macro
}
