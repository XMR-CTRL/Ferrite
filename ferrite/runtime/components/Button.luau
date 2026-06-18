local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)

local Button = {}
Button.__index = Button

function Button.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Button)
    self:_mount()
    return self
end

function Button:_mount()
    local textButton0 = Instance.new("TextButton")
    textButton0.Size = UDim2.new(0, 100, 0, 32)
    textButton0.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    textButton0.TextColor3 = WHITE
    textButton0.TextSize = 16
    textButton0.BorderSizePixel = 0
    local uiCorner1 = Instance.new("UICorner")
    uiCorner1.CornerRadius = UDim.new(0, 4)
    local uiPadding2 = Instance.new("UIPadding")
    uiPadding2.PaddingLeft = UDim.new(0, 16)
    uiPadding2.PaddingRight = UDim.new(0, 16)
    uiPadding2.PaddingTop = UDim.new(0, 8)
    uiPadding2.PaddingBottom = UDim.new(0, 8)
    uiCorner1.Parent = textButton0
    uiPadding2.Parent = textButton0
    textButton0.Parent = self.parent
    self._root = textButton0
end

function Button:setState(changes)
    self.state:update(changes)
end

function Button:destroy()
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

return Button
