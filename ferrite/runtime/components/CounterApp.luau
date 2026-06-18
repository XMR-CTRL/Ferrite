local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)

local CounterApp = {}
CounterApp.__index = CounterApp

function CounterApp.new(parent, props)
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
    }, CounterApp)
    self:_mount()
    return self
end

function CounterApp:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 200, 0, 150)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -100, 0.5, -75)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim.new(0, 8)
    uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local textLabel3 = Instance.new("TextLabel")
    textLabel3.Size = UDim2.new(1, 0, 0, 30)
    textLabel3.Text = "Counter App"
    textLabel3.TextSize = 20
    textLabel3.TextColor3 = BLACK
    textLabel3.BackgroundTransparency = 1
    textLabel3.Font = Enum.Font.GothamBold
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.Size = UDim2.new(1, 0, 0, 40)
    textLabel4.TextSize = 32
    textLabel4.TextColor3 = Color3.fromRGB(0, 122, 255)
    textLabel4.BackgroundTransparency = 1
    textLabel4.Text = self.state.count
    table.insert(self._connections, self.state:subscribe("count", function(value)
        textLabel4.Text = self.state.count
    end))
    textLabel4.Font = Enum.Font.GothamBold
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(1, 0, 0, 40)
    frame5.BackgroundTransparency = 1
    local uiListLayout6 = Instance.new("UIListLayout")
    uiListLayout6.Padding = UDim.new(0, 8)
    uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
    local textButton7 = Instance.new("TextButton")
    textButton7.Size = UDim2.new(0, 60, 1, 0)
    textButton7.Text = "-"
    textButton7.TextSize = 24
    textButton7.TextColor3 = WHITE
    textButton7.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    textButton7.BorderSizePixel = 0
    textButton7.Font = Enum.Font.GothamBold
    local textButton8 = Instance.new("TextButton")
    textButton8.Size = UDim2.new(0, 60, 1, 0)
    textButton8.Text = "+"
    textButton8.TextSize = 24
    textButton8.TextColor3 = WHITE
    textButton8.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    textButton8.BorderSizePixel = 0
    textButton8.Font = Enum.Font.GothamBold
    uiListLayout6.Parent = frame5
    textButton7.Parent = frame5
    textButton8.Parent = frame5
    uiListLayout2.Parent = frame1
    textLabel3.Parent = frame1
    textLabel4.Parent = frame1
    frame5.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function CounterApp:setState(changes)
    self.state:update(changes)
end

function CounterApp:destroy()
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

return CounterApp
