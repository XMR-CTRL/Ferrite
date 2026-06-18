use crate::ir::{UiNode, PropValue};

const UTILITY_CLASSES: &[&str] = &[
    "UIListLayout",
    "UIGridLayout",
    "UIPageLayout",
    "UITableLayout",
    "UICorner",
    "UIPadding",
    "UIScale",
    "UIStroke",
    "UIAspectRatioConstraint",
    "UISizeConstraint",
    "UITextSizeConstraint",
    "UIGradient",
];

fn is_utility(class: &str) -> bool {
    UTILITY_CLASSES.contains(&class)
}

fn has_visual_props(node: &UiNode) -> bool {
    node.props.iter().any(|(name, _)| {
        matches!(
            name.as_str(),
            "BackgroundColor3"
                | "BackgroundTransparency"
                | "BorderSizePixel"
                | "BorderColor3"
                | "Image"
                | "ImageColor3"
                | "Text"
                | "Rotation"
                | "ZIndex"
                | "Visible"
        )
    })
}

fn has_event_props(node: &UiNode) -> bool {
    node.props.iter().any(|(_, v)| matches!(v, PropValue::Event(_)))
}

fn has_layout_children(node: &UiNode) -> bool {
    node.children.iter().any(|c| is_utility(&c.class))
}

fn separate_utility_children(node: &UiNode) -> (Vec<UiNode>, Vec<UiNode>) {
    let mut utilities = Vec::new();
    let mut structural = Vec::new();
    
    for child in &node.children {
        if is_utility(&child.class) {
            utilities.push(child.clone());
        } else {
            structural.push(child.clone());
        }
    }
    
    (utilities, structural)
}

pub fn optimize_tree(node: UiNode) -> UiNode {
    let optimized_children: Vec<UiNode> = node
        .children
        .clone()
        .into_iter()
        .map(optimize_tree)
        .collect();

    let (utilities, structural) = separate_utility_children(&UiNode {
        class: node.class.clone(),
        props: node.props.clone(),
        children: optimized_children.clone(),
        is_static: node.is_static,
        key: node.key.clone(),
    });

    // Optimization Rule: Collapse redundant wrapper Frame with single structural child
    if node.class == "Frame"
        && structural.len() == 1
        && !has_visual_props(&node)
        && !has_event_props(&node)
        && !is_utility(&structural[0].class)
    {
        let mut child = structural[0].clone();

        // Inherit layout properties from parent if child doesn't define them
        for (prop_name, prop_val) in &node.props {
            if (prop_name == "Size" || prop_name == "Position" || prop_name == "AnchorPoint")
                && !child.props.iter().any(|(k, _)| k == prop_name)
            {
                child.props.push((prop_name.clone(), prop_val.clone()));
            }
        }
        
        // Preserve utility children (UICorner, UIPadding, etc.) by re-parenting them to the child
        for utility in utilities {
            child.children.push(utility);
        }

        // PRESERVE KEY: If the wrapper had a key and child doesn't, propagate it
        let child_key = child.key.clone().or(node.key.clone());
        child.key = child_key;

        return UiNode::new_with_key(child.class, child.props, child.children, child.key);
    }

    // No optimization applied — preserve structure and key
    let mut result = UiNode::new(node.class, node.props, optimized_children);
    result.key = node.key.clone();
    result
}
