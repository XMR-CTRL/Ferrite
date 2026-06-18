local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)

local Modal = {}
Modal.__index = Modal

function Modal.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Modal)
    self:_mount()
    return self
end

function Modal:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 1, 0)
    frame0.BackgroundColor3 = BLACK
    frame0.BackgroundTransparency = 0.5
    frame0.ZIndex = 1000
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 400, 0, 300)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.AnchorPoint = Vector2.new(0.5, 0.5)
    frame1.Position = UDim2.new(0.5, -200, 0.5, -150)
    local uiCorner2 = Instance.new("UICorner")
    uiCorner2.CornerRadius = UDim.new(0, 8)
    local uiPadding3 = Instance.new("UIPadding")
    uiPadding3.PaddingLeft = UDim.new(0, 24)
    uiPadding3.PaddingRight = UDim.new(0, 24)
    uiPadding3.PaddingTop = UDim.new(0, 24)
    uiPadding3.PaddingBottom = UDim.new(0, 24)
    uiCorner2.Parent = frame1
    uiPadding3.Parent = frame1
    frame1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Modal:setState(changes)
    self.state:update(changes)
end

function Modal:destroy()
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

return Modal
