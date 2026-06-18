local Signal = require(script.Parent.Parent.Signal)


local BadCodeApp = {}
BadCodeApp.__index = BadCodeApp

function BadCodeApp.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            z = 0,
            messyVar2 = "test",
            y = "",
            MESSY_VAR_3 = 100,
            messy_var_1 = false,
            x = {},
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, BadCodeApp)
    self:_mount()
    return self
end

function BadCodeApp:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.BorderSizePixel = 0
    frame1.Size = UDim2:new(0, 400, 0, 300)
    frame1.Position = UDim2:new(0.5, -200, 0.5, -150)
    frame1.BackgroundColor3 = Color3:fromRGB(255, 255, 255)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim:new(0, 8)
    local textLabel3 = Instance.new("TextLabel")
    textLabel3.Text = "Bad Code App"
    textLabel3.TextSize = 24
    textLabel3.BackgroundTransparency = 1
    textLabel3.Size = UDim2:new(1, 0, 0, 40)
    textLabel3.TextColor3 = Color3:fromRGB(0, 0, 0)
    textLabel3.Font = Enum.Font.GothamBold
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.TextSize = 18
    textLabel4.BackgroundTransparency = 1
    textLabel4.Size = UDim2:new(1, 0, 0, 30)
    textLabel4.Text = "Count: " .. tostring(self.state.z:clone())
    table.insert(self._connections, self.state:subscribe("z", function(value)
        textLabel4.Text = "Count: " .. tostring(self.state.z:clone())
    end))
    textLabel4.TextColor3 = Color3:fromRGB(0, 0, 0)
    textLabel4.Font = Enum.Font.Gotham
    local frame5 = Instance.new("Frame")
    frame5.BackgroundTransparency = 1
    frame5.Size = UDim2:new(1, 0, 0, 40)
    local uiListLayout6 = Instance.new("UIListLayout")
    uiListLayout6.Padding = UDim:new(0, 8)
    uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
    local textButton7 = Instance.new("TextButton")
    textButton7.Text = "+"
    textButton7.TextSize = 24
    textButton7.BorderSizePixel = 0
    textButton7.Size = UDim2:new(0, 80, 1, 0)
    textButton7.BackgroundColor3 = Color3:fromRGB(59, 130, 246)
    textButton7.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton7.Font = Enum.Font.GothamBold
    local textButton8 = Instance.new("TextButton")
    textButton8.Text = "-"
    textButton8.TextSize = 24
    textButton8.BorderSizePixel = 0
    textButton8.Size = UDim2:new(0, 80, 1, 0)
    textButton8.BackgroundColor3 = Color3:fromRGB(239, 68, 68)
    textButton8.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton8.Font = Enum.Font.GothamBold
    uiListLayout6.Parent = frame5
    textButton7.Parent = frame5
    textButton8.Parent = frame5
    local textLabel9 = Instance.new("TextLabel")
    textLabel9.TextSize = 16
    textLabel9.BackgroundTransparency = 1
    textLabel9.Size = UDim2:new(1, 0, 0, 30)
    textLabel9.Text = "Input: " .. tostring(self.state.y:clone())
    table.insert(self._connections, self.state:subscribe("y", function(value)
        textLabel9.Text = "Input: " .. tostring(self.state.y:clone())
    end))
    textLabel9.TextColor3 = Color3:fromRGB(0, 0, 0)
    textLabel9.Font = Enum.Font.Gotham
    local textBox10 = Instance.new("TextBox")
    textBox10.PlaceholderText = "Type something..."
    textBox10.TextSize = 16
    textBox10.BorderSizePixel = 0
    textBox10.Size = UDim2:new(1, 0, 0, 30)
    textBox10.TextColor3 = Color3:fromRGB(0, 0, 0)
    textBox10.BackgroundColor3 = Color3:fromRGB(240, 240, 240)
    uiListLayout2.Parent = frame1
    textLabel3.Parent = frame1
    textLabel4.Parent = frame1
    frame5.Parent = frame1
    textLabel9.Parent = frame1
    textBox10.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function BadCodeApp:setState(changes)
    self.state:update(changes)
end

function BadCodeApp:destroy()
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

return BadCodeApp
