use crate::ir::{UiNode, PropValue, DynamicProp, AnimatedProp, AnimationType};
use crate::config::CompilerConfig;
use std::collections::{HashMap, HashSet};

fn get_deps_from_prop(prop: &PropValue) -> Vec<String> {
    match prop {
        PropValue::Dynamic(d) => d.dependencies.clone(),
        _ => Vec::new(),
    }
}

fn has_dynamic_children(_node: &UiNode) -> bool {
    false
}

fn check_has_animations(node: &UiNode) -> bool {
    for (_, prop) in &node.props {
        if matches!(prop, PropValue::Animated(_)) {
            return true;
        }
    }
    for child in &node.children {
        if check_has_animations(child) {
            return true;
        }
    }
    false
}

fn extract_constants(node: &UiNode) -> Vec<String> {
    let mut constants = Vec::new();
    
    for (_, prop) in &node.props {
        if let PropValue::Static(s) = prop {
            if s.contains("Color3.fromRGB(255, 255, 255)") {
                if !constants.iter().any(|c: &String| c.contains("WHITE")) {
                    constants.push("local WHITE = Color3.fromRGB(255, 255, 255)".to_string());
                }
            }
            if s.contains("Color3.fromRGB(0, 0, 0)") {
                if !constants.iter().any(|c: &String| c.contains("BLACK")) {
                    constants.push("local BLACK = Color3.fromRGB(0, 0, 0)".to_string());
                }
            }
        }
    }
    
    for child in &node.children {
        constants.extend(extract_constants(child));
    }
    
    constants
}

fn replace_constants(value: &str) -> String {
    value
        .replace("Color3.fromRGB(255, 255, 255)", "WHITE")
        .replace("Color3.fromRGB(0, 0, 0)", "BLACK")
}

struct MountGen {
    lines: Vec<String>,
    counter: usize,
    use_vdom: bool,
    name_map: HashMap<String, String>,
    constants: HashMap<String, String>,
    child_vars: Vec<String>,
    used_vars: HashSet<String>,
    event_handlers: HashMap<String, String>,
    refs: HashMap<String, String>,
}

impl MountGen {
    fn new(use_vdom: bool) -> Self {
        Self { 
            lines: Vec::new(), 
            counter: 0, 
            use_vdom,
            name_map: HashMap::new(),
            constants: HashMap::new(),
            child_vars: Vec::new(),
            used_vars: HashSet::new(),
            event_handlers: HashMap::new(),
            refs: HashMap::new(),
        }
    }

    fn mark_used(&mut self, var: &str) {
        self.used_vars.insert(var.to_string());
    }

    fn get_or_create_handler(&mut self, handler_name: String, handler_code: String) -> String {
        if !self.event_handlers.contains_key(&handler_name) {
            self.event_handlers.insert(handler_name.clone(), handler_code);
        }
        handler_name
    }

    fn cache_ref(&mut self, ref_name: String, var_name: String) {
        self.refs.insert(ref_name, var_name);
    }

    fn alloc_var(&mut self, class: &str) -> String {
        let semantic_name = self.get_semantic_name(class);
        let v = semantic_name;
        self.counter += 1;
        v
    }

    fn get_semantic_name(&mut self, class: &str) -> String {
        match class {
            "ScreenGui" => "screenGui".to_string(),
            "Frame" => format!("frame{}", self.counter),
            "TextLabel" => format!("textLabel{}", self.counter),
            "TextButton" => format!("textButton{}", self.counter),
            "ImageButton" => format!("imageButton{}", self.counter),
            "UIListLayout" => format!("uiListLayout{}", self.counter),
            "UIPadding" => format!("uiPadding{}", self.counter),
            "UIScale" => format!("uiScale{}", self.counter),
            "UIStroke" => format!("uiStroke{}", self.counter),
            "UIGradient" => format!("uiGradient{}", self.counter),
            "UICorner" => format!("uiCorner{}", self.counter),
            "ScrollingFrame" => format!("scrollingFrame{}", self.counter),
            "TextBox" => format!("textBox{}", self.counter),
            _ => format!("{}{}", class.to_lowercase(), self.counter),
        }
    }

    fn add_constant(&mut self, name: String, value: String) {
        self.constants.insert(name, value);
    }

    fn emit_node_signal_mode(&mut self, node: &UiNode) -> String {
        let var = self.alloc_var(&node.class);
        self.mark_used(&var);

        if let Some(ref key) = node.key {
            self.cache_ref(key.clone(), var.clone());
        }

        self.lines.push(format!("    local {}: Instance = Instance.new(\"{}\")", var, node.class));

        let mut properties: Vec<(String, String)> = Vec::new();
        let mut seen_props: HashSet<String> = HashSet::new();
        
        for (k, v) in &node.props {
            if k == "Key" {
                continue;
            }
            if let PropValue::Static(s) = v {
                if !seen_props.contains(k) {
                    seen_props.insert(k.clone());
                    let replaced = replace_constants(s);
                    properties.push((k.clone(), replaced));
                }
            }
        }

        for (k, v) in properties {
            self.lines.push(format!("    {}.{} = {}", var, k, v));
        }

        for (k, v) in &node.props {
            if k == "Key" {
                continue;
            }
            if let PropValue::Dynamic(DynamicProp { expression, dependencies }) = v {
                self.lines.push(format!("    {}.{} = {}", var, k, expression));
                
                if !dependencies.is_empty() {
                    if dependencies.len() == 1 {
                        self.lines.push(format!(
                            "    table.insert(self._connections, self.state:subscribe(\"{}\", function(value)",
                            dependencies[0]
                        ));
                        self.lines.push(format!("        {}.{} = {}", var, k, expression));
                        self.lines.push("    end))".to_string());
                    } else {
                        let deps_array = format!("{{{}}}", dependencies.iter().map(|d| format!("\"{}\"", d)).collect::<Vec<_>>().join(", "));
                        self.lines.push(format!(
                            "    table.insert(self._connections, self.state:subscribeMulti({}, function()",
                            deps_array
                        ));
                        self.lines.push(format!("        {}.{} = {}", var, k, expression));
                        self.lines.push("    end))".to_string());
                    }
                }
            }
        }

        for (k, v) in &node.props {
            if k == "Key" {
                continue;
            }
            if let PropValue::Animated(anim) = v {
                self.emit_animation(var.clone(), k.clone(), anim);
            }
        }

        for (k, v) in &node.props {
            if let PropValue::Event(e) = v {
                let event_name = if k.starts_with("On") { &k[2..] } else { k.as_str() };
                
                let handler_name = format!("handle_{}", event_name.to_lowercase());
                let handler_code = e.clone();
                
                if !self.event_handlers.contains_key(&handler_name) {
                    self.event_handlers.insert(handler_name.clone(), handler_code);
                }
                
                self.lines.push(format!(
                    "    table.insert(self._connections, {}.{}:Connect({}))",
                    var, event_name, handler_name
                ));
            }
        }

        let mut child_var_list = Vec::new();
        for child in &node.children {
            let child_var = self.emit_node_signal_mode(child);
            child_var_list.push(child_var);
        }
        
        for child_var in child_var_list {
            self.lines.push(format!("    {}.Parent = {}", child_var, var));
        }

        var
    }

    fn emit_animation(&mut self, instance_var: String, property: String, anim: &AnimatedProp) {
        let duration = anim.config.duration.unwrap_or(0.5);
        let easing = match anim.config.easing {
            Some(ref e) => match e.as_str() {
                "Linear" => "Linear",
                "Quad" => "Quad",
                "Cubic" => "Cubic",
                "Quart" => "Quart",
                "Quint" => "Quint",
                "Sine" => "Sine",
                "Expo" => "Expo",
                "Circ" => "Circ",
                "Elastic" => "Elastic",
                "Back" => "Back",
                "Bounce" => "Bounce",
                _ => "Quad",
            },
            None => "Quad",
        };

        self.lines.push(format!(
            "    local tweenInfo = TweenInfo.new({}, Enum.EasingStyle.{}, Enum.EasingDirection.Out)",
            duration, easing
        ));
        self.lines.push(format!(
            "    local tween = TweenService:Create({}, tweenInfo, {{ {} = {} }})",
            instance_var, property, anim.target_value
        ));
        self.lines.push(format!(
            "    table.insert(self._animations, tween)"
        ));
    }

    fn eliminate_dead_code(&mut self) {
        let mut filtered_lines = Vec::new();
        let mut declared_vars: HashSet<String> = HashSet::new();
        
        for line in &self.lines {
            if line.contains("local ") && line.contains("= Instance.new(") {
                if let Some(start) = line.find("local ") {
                    if let Some(end) = line[start + 6..].find(':') {
                        let var_name = &line[start + 6..start + 6 + end];
                        declared_vars.insert(var_name.to_string());
                    } else if let Some(end) = line[start + 6..].find(' ') {
                        let var_name = &line[start + 6..start + 6 + end];
                        declared_vars.insert(var_name.to_string());
                    }
                }
            }
            
            let mut keep_line = true;
            for var in &declared_vars {
                if line.contains(var) && self.used_vars.contains(var) {
                    keep_line = true;
                    break;
                }
            }
            
            if keep_line {
                filtered_lines.push(line.clone());
            }
        }
        
        self.lines = filtered_lines;
    }

    fn emit_handler_functions(&mut self) {
        if !self.event_handlers.is_empty() {
            self.lines.push("    -- Event handlers".to_string());
            for (name, code) in &self.event_handlers {
                self.lines.push(format!("    local function {}(...)", name));
                self.lines.push(format!("        {}", code));
                self.lines.push("    end".to_string());
            }
        }
    }

    fn emit_vnode(&mut self, node: &UiNode, indent: usize) -> String {
        let ind = "    ".repeat(indent);
        let mut parts = vec![format!("{}{{", ind)];
        
        parts.push(format!("{}    class = \"{}\",", ind, node.class));
        
        if let Some(ref key) = node.key {
            parts.push(format!("{}    key = \"{}\",", ind, key));
        }
        
        parts.push(format!("{}    props = {{", ind));
        for (k, v) in &node.props {
            let value_str = match v {
                PropValue::Static(s) => s.clone(),
                PropValue::Dynamic(DynamicProp { expression, .. }) => expression.clone(),
                PropValue::Event(e) => e.clone(),
                PropValue::Animated(_) => {
                    continue;
                }
            };
            parts.push(format!("{}        {} = {},", ind, k, value_str));
        }
        parts.push(format!("{}    }},", ind));
        
        parts.push(format!("{}    children = {{", ind));
        for child in &node.children {
            let child_str = self.emit_vnode(child, indent + 2);
            parts.push(format!("{},", child_str));
        }
        parts.push(format!("{}    }},", ind));
        
        if node.is_static {
            parts.push(format!("{}    is_static = true,", ind));
        }
        
        parts.push(format!("{}}}", ind));
        parts.join("\n")
    }

}

pub fn generate_luau(
    component_name: &str,
    initial_state: &HashMap<String, String>,
    effects: &Vec<String>,
    refs: &HashMap<String, String>,
    root_node: &UiNode,
    config: &CompilerConfig,
) -> String {
    let state_fields: Vec<String> = initial_state
        .iter()
        .map(|(k, v)| format!("            {} = {},", k, v))
        .collect();

    let state_block = if state_fields.is_empty() {
        "{}".to_string()
    } else {
        format!("{{\n{}\n        }}", state_fields.join("\n"))
    };

    let refs_fields: Vec<String> = refs
        .iter()
        .map(|(k, v)| format!("            {} = {},", k, v))
        .collect();

    let refs_block = if refs_fields.is_empty() {
        "refs = {}".to_string()
    } else {
        format!("refs = {{\n{}\n        }}", refs_fields.join("\n"))
    };

    let _effects_code: String = effects
        .iter()
        .enumerate()
        .map(|(i, effect)| {
            format!(
                "    -- Effect {}\n    local cleanup{} = {}\n    if cleanup{} then\n        table.insert(self._effects, cleanup{})\n    end",
                i, i, effect, i, i
            )
        })
        .collect::<Vec<_>>()
        .join("\n");

    let constants = extract_constants(root_node);
    let constants_block = if constants.is_empty() {
        String::new()
    } else {
        format!(
            "    -- Constants\n    {}\n",
            constants.join("\n    ")
        )
    };

    let needs_vdom = has_dynamic_children(root_node);
    let has_animations = check_has_animations(root_node);

    if needs_vdom {
        let mut vdom_gen = MountGen::new(true);
        let vnode_str = vdom_gen.emit_vnode(root_node, 2);
        
        format!(
            r#"local Runtime = require(script.Parent.Parent.Runtime)
local Signal = require(script.Parent.Parent.Signal)

local {0} = {{}}
{0}.__index = {0}

function {0}.new(parent, props)
    local self = setmetatable({{
        parent = parent,
        props = props or {{}},
        state = Signal.new({1}),
        _connections = {{}},
        _vnode = nil,
    }}, {0})
    self:render()
    return self
end

function {0}:render()
    local newVNode = {2}
    
    local oldVNode = self._vnode
    self._vnode = newVNode
    
    local rootInstance = Runtime.reconcile(self.parent, oldVNode, newVNode, oldVNode and oldVNode.instance)
    newVNode.instance = rootInstance
end

function {0}:setState(changes)
    self.state:update(changes)
    self:render()
end

function {0}:destroy()
    if self._vnode then
        Runtime.destroyNode(self._vnode)
        self._vnode = nil
    end
end

return {0}
"#,
            component_name,
            state_block,
            vnode_str
        )
    } else {
        let mut mount_gen = MountGen::new(false);
        let root_var = mount_gen.emit_node_signal_mode(root_node);
        
        mount_gen.emit_handler_functions();
        
        mount_gen.eliminate_dead_code();
        
        let mount_lines = mount_gen.lines.join("\n");

        let animation_require = if has_animations {
            match config.target_runtime {
                crate::config::RuntimeTarget::Roblox => "local TweenService = game:GetService(\"TweenService\")\n",
                crate::config::RuntimeTarget::Lune => "local TweenService = game:GetService(\"TweenService\")\n",
                crate::config::RuntimeTarget::Standard => "local TweenService = game:GetService(\"TweenService\")\n",
            }
        } else {
            ""
        };

        let signal_require = match config.target_runtime {
            crate::config::RuntimeTarget::Roblox => "local Signal = require(script.Parent.Parent.Signal)\n",
            crate::config::RuntimeTarget::Lune => "local Signal = require(\"../Signal\")\n",
            crate::config::RuntimeTarget::Standard => "local Signal = require(\"Signal\")\n",
        };

        format!(
            r#"{}{}
{}
local {} = {{}}
{}.__index = {}

function {}.new(parent, props)
    local self = setmetatable({{
        parent = parent,
        props = props or {{}},
        state = Signal.new({}),
        {},
        _connections = {{}},
        _effects = {{}},
        _animations = {{}},
        _root = nil,
    }}, {})
    self:_mount()
    return self
end

function {}:_mount()
{}
    {}.Parent = self.parent
    self._root = {}
end

function {}:setState(changes)
    self.state:update(changes)
end

function {}:destroy()
    for _, cleanup in ipairs(self._effects) do
        if type(cleanup) == "function" then
            cleanup()
        end
    end
    
    for _, conn in ipairs(self._connections) do
        if type(conn) == "function" then
            conn()
        elseif typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    for _, anim in ipairs(self._animations) do
        if anim.stop then
            anim:stop()
        elseif anim.Cancel then
            anim:Cancel()
        end
    end
    
    if self._root then
        self._root:Destroy()
        self._root = nil
    end
end

return {}
"#,
            signal_require,
            animation_require,
            constants_block,
            component_name, component_name, component_name, component_name,
            state_block,
            refs_block,
            component_name,
            component_name,
            mount_lines,
            root_var, root_var,
            component_name,
            component_name,
            component_name
        )
    }
}
