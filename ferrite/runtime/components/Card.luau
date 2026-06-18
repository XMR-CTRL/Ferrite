local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)

local Card = {}
Card.__index = Card

function Card.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Card)
    self:_mount()
    return self
end

function Card:_mount()
    local frame0 = Instance.new("Frame")
    frame0.BackgroundColor3 = WHITE
    frame0.BorderSizePixel = 0
    local uiCorner1 = Instance.new("UICorner")
    uiCorner1.CornerRadius = UDim.new(0, 8)
    local uiStroke2 = Instance.new("UIStroke")
    uiStroke2.Color = Color3.fromRGB(200, 200, 200)
    uiStroke2.Thickness = 1
    local uiPadding3 = Instance.new("UIPadding")
    uiPadding3.PaddingLeft = UDim.new(0, 16)
    uiPadding3.PaddingRight = UDim.new(0, 16)
    uiPadding3.PaddingTop = UDim.new(0, 16)
    uiPadding3.PaddingBottom = UDim.new(0, 16)
    uiCorner1.Parent = frame0
    uiStroke2.Parent = frame0
    uiPadding3.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Card:setState(changes)
    self.state:update(changes)
end

function Card:destroy()
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

return Card
