local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)

local FormField = {}
FormField.__index = FormField

function FormField.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, FormField)
    self:_mount()
    return self
end

function FormField:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 0, 60)
    frame0.BackgroundTransparency = 1
    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Size = UDim2.new(1, 0, 0, 20)
    textLabel1.TextColor3 = BLACK
    textLabel1.TextSize = 14
    textLabel1.BackgroundTransparency = 1
    local textBox2 = Instance.new("TextBox")
    textBox2.Size = UDim2.new(1, 0, 0, 30)
    textBox2.Position = UDim2.new(0, 0, 0, 25)
    textBox2.BackgroundColor3 = WHITE
    textBox2.BorderSizePixel = 1
    textBox2.BorderColor3 = Color3.fromRGB(200, 200, 200)
    textLabel1.Parent = frame0
    textBox2.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function FormField:setState(changes)
    self.state:update(changes)
end

function FormField:destroy()
    -- Run effect cleanups
    for _, cleanup in ipairs(self._effects) do
        if type(cleanup) == "function" then
            cleanup()
        end
    end
    
    -- Disconnect signal subscriptions
    for _, conn in ipairs(self._connections) do
        if type(conn) == "function" then
            conn()
        elseif typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    -- Stop all animations (handle both custom Animation and Roblox Tween)
    for _, anim in ipairs(self._animations) do
        if anim.stop then
            anim:stop()
        elseif anim.Cancel then
            anim:Cancel()
        end
    end
    
    -- Destroy root instance
    if self._root then
        self._root:Destroy()
        self._root = nil
    end
end

return FormField
