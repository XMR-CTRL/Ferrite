use crate::prelude::*;

/// Flexbox-like layout container
#[component]
pub fn Flex() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
            
            UIListLayout {
                FillDirection: Enum.FillDirection.Horizontal,
                Padding: UDim.new(0, 8),
                HorizontalAlignment: Enum.HorizontalAlignment.Left,
                VerticalAlignment: Enum.VerticalAlignment.Top,
            }
        }
    }
}

/// Grid layout container
#[component]
pub fn Grid() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
            
            UIGridLayout {
                CellSize: UDim2.new(0, 100, 0, 100),
                CellPadding: UDim2.new(0, 8, 0, 8),
                StartCorner: Enum.StartCorner.TopLeft,
                FillDirection: Enum.FillDirection.Horizontal,
                FillDirectionMaxCells: 4,
            }
        }
    }
}

/// Stack layout for vertical/horizontal stacking
#[component]
pub fn Stack() -> UiNode {
    view! {
        Frame {
            Size: UDim2::new(1, 0, 1, 0),
            BackgroundTransparency: 1,
            
            UIListLayout {
                Padding: UDim.new(0, 8),
            }
        }
    }
}

/// Layout configuration
pub struct LayoutConfig {
    pub direction: Direction,
    pub justify: JustifyContent,
    pub align: AlignItems,
    pub gap: f32,
    pub wrap: bool,
}

pub enum Direction {
    Row,
    Column,
    RowReverse,
    ColumnReverse,
}

pub enum JustifyContent {
    Start,
    End,
    Center,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly,
}

pub enum AlignItems {
    Start,
    End,
    Center,
    Stretch,
    Baseline,
}
