# Ferrite

Write Roblox UIs in Rust, get optimized Luau code.

## What it does

Ferrite compiles Rust code to Luau for Roblox UIs. It's type-safe and generates clean, performant code automatically.

## Features

- Type-safe Rust with compile-time checking
- Generates optimized Luau with semantic names
- Dead code elimination
- Constant pooling for colors and numbers
- Strict type annotations
- Proper cleanup tracking (connections, tweens)
- Signal-based state management
- TweenService animations

## Installation

```bash
cargo build --release
# Binary at target/release/ferrite.exe
```

## Quick Start

Write a component in Rust:

```rust
use ferrite::prelude::*;

#[component]
pub fn SimpleButton() -> UiNode {
    view! {
        ScreenGui {
            IgnoreGuiInset: true,
            
            TextButton {
                Size: UDim2::new(0, 200, 0, 50),
                Position: UDim2::new(0.5, -100, 0.5, -25),
                BackgroundColor3: Color3::fromRGB(100, 149, 237),
                Text: "Click Me",
                TextSize: 20,
                TextColor3: Color3::fromRGB(255, 255, 255),
                Font: Enum.Font.GothamBold,
            }
        }
    }
}
```

Compile it:

```bash
ferrite compile --input src/main.rs --output SimpleButton.luau
```

Use it in Roblox:

```lua
local SimpleButton = require(game.ReplicatedStorage.SimpleButton)
local button = SimpleButton.new(script.Parent)
```

## Project Structure

```
ferrite/
├── compiler/       # Rust compiler
├── ferrite/        # Component library
├── ferrite-macros/ # Macros
└── runtime/        # Luau runtime files
```

## How it works

1. Write UI components in Rust using the `#[component]` macro
2. Compiler parses and optimizes the code
3. Generates optimized Luau following best practices
4. Output is production-ready Luau

## License

Apache 2.0
