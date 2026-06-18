local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)

local Counter = {}
Counter.__index = Counter

function Counter.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            count = 0,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Counter)
    self:_mount()
    return self
end

function Counter:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(0, 300, 0, 300)
    frame0.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame0.Position = UDim2.new(0.5, -150, 0.5, -150)
    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Size = UDim2.new(1, 0, 0, 50)
    textLabel1.TextColor3 = WHITE
    textLabel1.TextSize = 24
    textLabel1.BackgroundTransparency = 1
    textLabel1.Text = "Count: " .. tostring(self.state.count)
    table.insert(self._connections, self.state:subscribe("count", function(value)
        textLabel1.Text = "Count: " .. tostring(self.state.count)
    end))
    local textButton2 = Instance.new("TextButton")
    textButton2.Text = "Click to Increment"
    textButton2.Size = UDim2.new(1, 0, 0, 50)
    textButton2.Position = UDim2.new(0, 0, 0, 60)
    textButton2.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    textButton2.TextColor3 = WHITE
    table.insert(self._connections, textButton2.Activated:Connect(function()
        self:setState({ count = self.state.count + 1 })
    end))
    textLabel1.Parent = frame0
    textButton2.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Counter:setState(changes)
    self.state:update(changes)
end

function Counter:destroy()
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

return Counter
