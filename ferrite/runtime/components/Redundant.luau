local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local BLACK = Color3.fromRGB(0, 0, 0)

local Redundant = {}
Redundant.__index = Redundant

function Redundant.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Redundant)
    self:_mount()
    return self
end

function Redundant:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(0, 100, 0, 100)
    frame0.BackgroundColor3 = BLACK
    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Text = "Nested label"
    textLabel1.Size = UDim2.new(1, 0, 0, 20)
    textLabel1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Redundant:setState(changes)
    self.state:update(changes)
end

function Redundant:destroy()
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

return Redundant
