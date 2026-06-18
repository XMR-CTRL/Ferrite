use crate::prelude::*;

/// Enhanced error boundary with stack traces and logging
#[component]
pub fn ErrorHandler() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundColor3: Color3::fromRGB(50, 50, 50),
            
            TextLabel {
                Text: "An error occurred",
                Size: UDim2::new(1, 0, 0, 30),
                Position: UDim2::new(0, 0, 0, 20),
                TextColor3: Color3::fromRGB(255, 100, 100),
                TextSize: 20,
                BackgroundTransparency: 1,
            }
            
            TextLabel {
                Text: "Error details logged to console",
                Size: UDim2::new(1, 0, 0, 20),
                Position: UDim2::new(0, 0, 0, 60),
                TextColor3: Color3::fromRGB(200, 200, 200),
                TextSize: 14,
                BackgroundTransparency: 1,
            }
            
            TextButton {
                Text: "Reload",
                Size: UDim2::new(0, 100, 0, 30),
                Position: UDim2::new(0.5, -50, 0.5, 50),
                BackgroundColor3: Color3::fromRGB(0, 120, 215),
                TextColor3: Color3::fromRGB(255, 255, 255),
            }
        }
    }
}

/// Error logging system
pub struct ErrorLogger;

impl ErrorLogger {
    pub fn log_error(error: &str, stack_trace: &str) {
        // Log error with stack trace
        println!("ERROR: {}", error);
        println!("STACK TRACE:\n{}", stack_trace);
    }
    
    pub fn log_warning(warning: &str) {
        println!("WARNING: {}", warning);
    }
    
    pub fn log_info(info: &str) {
        println!("INFO: {}", info);
    }
}
