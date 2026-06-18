local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)

local Input = {}
Input.__index = Input

function Input.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Input)
    self:_mount()
    return self
end

function Input:_mount()
    local frame0 = Instance.new("Frame")
    frame0.BackgroundColor3 = WHITE
    frame0.BorderSizePixel = 0
    local uiCorner1 = Instance.new("UICorner")
    uiCorner1.CornerRadius = UDim.new(0, 4)
    local uiStroke2 = Instance.new("UIStroke")
    uiStroke2.Color = Color3.fromRGB(200, 200, 200)
    uiStroke2.Thickness = 1
    local textBox3 = Instance.new("TextBox")
    textBox3.Size = UDim2.new(1, 0, 1, 0)
    textBox3.BackgroundTransparency = 1
    textBox3.TextColor3 = BLACK
    textBox3.TextSize = 16
    textBox3.ClearTextOnFocus = false
    textBox3.BorderSizePixel = 0
    local uiPadding4 = Instance.new("UIPadding")
    uiPadding4.PaddingLeft = UDim.new(0, 12)
    uiPadding4.PaddingRight = UDim.new(0, 12)
    uiPadding4.PaddingTop = UDim.new(0, 6)
    uiPadding4.PaddingBottom = UDim.new(0, 6)
    uiPadding4.Parent = textBox3
    uiCorner1.Parent = frame0
    uiStroke2.Parent = frame0
    textBox3.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Input:setState(changes)
    self.state:update(changes)
end

function Input:destroy()
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

return Input
