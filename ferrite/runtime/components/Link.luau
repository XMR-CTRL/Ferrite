local Signal = require(script.Parent.Parent.Signal)


local Link = {}
Link.__index = Link

function Link.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Link)
    self:_mount()
    return self
end

function Link:_mount()
    local textButton0 = Instance.new("TextButton")
    textButton0.Size = UDim2.new(0, 100, 0, 30)
    textButton0.BackgroundTransparency = 1
    textButton0.TextColor3 = Color3.fromRGB(0, 122, 255)
    textButton0.TextSize = 14
    textButton0.Parent = self.parent
    self._root = textButton0
end

function Link:setState(changes)
    self.state:update(changes)
end

function Link:destroy()
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

return Link
