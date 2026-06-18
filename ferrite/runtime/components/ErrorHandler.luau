local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)

local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

function ErrorHandler.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, ErrorHandler)
    self:_mount()
    return self
end

function ErrorHandler:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 1, 0)
    frame0.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Text = "An error occurred"
    textLabel1.Size = UDim2.new(1, 0, 0, 30)
    textLabel1.Position = UDim2.new(0, 0, 0, 20)
    textLabel1.TextColor3 = Color3.fromRGB(255, 100, 100)
    textLabel1.TextSize = 20
    textLabel1.BackgroundTransparency = 1
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Text = "Error details logged to console"
    textLabel2.Size = UDim2.new(1, 0, 0, 20)
    textLabel2.Position = UDim2.new(0, 0, 0, 60)
    textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel2.TextSize = 14
    textLabel2.BackgroundTransparency = 1
    local textButton3 = Instance.new("TextButton")
    textButton3.Text = "Reload"
    textButton3.Size = UDim2.new(0, 100, 0, 30)
    textButton3.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    textButton3.TextColor3 = WHITE
    textButton3.Position = UDim2.new(0.5, -50, 0.5, 50)
    textLabel1.Parent = frame0
    textLabel2.Parent = frame0
    textButton3.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function ErrorHandler:setState(changes)
    self.state:update(changes)
end

function ErrorHandler:destroy()
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

return ErrorHandler
