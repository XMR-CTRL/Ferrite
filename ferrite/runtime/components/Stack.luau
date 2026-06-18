local Signal = require(script.Parent.Parent.Signal)


local Stack = {}
Stack.__index = Stack

function Stack.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Stack)
    self:_mount()
    return self
end

function Stack:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 1, 0)
    frame0.BackgroundTransparency = 1
    local uiListLayout1 = Instance.new("UIListLayout")
    uiListLayout1.Padding = UDim:new(0, 8)
    uiListLayout1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Stack:setState(changes)
    self.state:update(changes)
end

function Stack:destroy()
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

return Stack
