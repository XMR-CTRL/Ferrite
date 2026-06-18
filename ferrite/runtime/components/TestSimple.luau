local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)

local TestSimple = {}
TestSimple.__index = TestSimple

function TestSimple.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, TestSimple)
    self:_mount()
    return self
end

function TestSimple:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(0, 200, 0, 100)
    frame0.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    frame0.Position = UDim2.new(0.5, -100, 0.5, -50)
    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Text = "Hello World"
    textLabel1.Size = UDim2.new(1, 0, 1, 0)
    textLabel1.TextColor3 = WHITE
    textLabel1.TextSize = 20
    textLabel1.BackgroundTransparency = 1
    textLabel1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function TestSimple:setState(changes)
    self.state:update(changes)
end

function TestSimple:destroy()
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

return TestSimple
