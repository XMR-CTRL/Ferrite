local Signal = require(script.Parent.Parent.Signal)


local Spinner = {}
Spinner.__index = Spinner

function Spinner.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Spinner)
    self:_mount()
    return self
end

function Spinner:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(0, 40, 0, 40)
    frame0.BackgroundTransparency = 1
    local imagelabel1 = Instance.new("ImageLabel")
    imagelabel1.Size = UDim2.new(1, 0, 1, 0)
    imagelabel1.BackgroundTransparency = 1
    imagelabel1.Image = "rbxassetid://4944326298"
    imagelabel1.Rotation = 0
    imagelabel1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Spinner:setState(changes)
    self.state:update(changes)
end

function Spinner:destroy()
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

return Spinner
