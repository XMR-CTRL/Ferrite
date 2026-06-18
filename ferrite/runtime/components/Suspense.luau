local Signal = require(script.Parent.Parent.Signal)


local Suspense = {}
Suspense.__index = Suspense

function Suspense.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Suspense)
    self:_mount()
    return self
end

function Suspense:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 1, 0)
    frame0.BackgroundTransparency = 1
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 40, 0, 40)
    frame1.BackgroundTransparency = 1
    frame1.Position = UDim2.new(0.5, -20, 0.5, -20)
    local imagelabel2 = Instance.new("ImageLabel")
    imagelabel2.Size = UDim2.new(1, 0, 1, 0)
    imagelabel2.Image = "rbxassetid://4944326298"
    imagelabel2.Rotation = 0
    imagelabel2.Parent = frame1
    frame1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Suspense:setState(changes)
    self.state:update(changes)
end

function Suspense:destroy()
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

return Suspense
