local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)

local LoginForm = {}
LoginForm.__index = LoginForm

function LoginForm.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            email = "",
            password = "",
            is_loading = false,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, LoginForm)
    self:_mount()
    return self
end

function LoginForm:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 350, 0, 400)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -175, 0.5, -200)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim.new(0, 16)
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.new(1, 0, 0, 60)
    frame3.BackgroundTransparency = 1
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.Size = UDim2.new(1, 0, 1, 0)
    textLabel4.Text = "Sign In"
    textLabel4.TextSize = 28
    textLabel4.TextColor3 = BLACK
    textLabel4.BackgroundTransparency = 1
    textLabel4.Font = Enum.Font.GothamBold
    textLabel4.Parent = frame3
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(1, 0, 0, 50)
    frame5.BackgroundTransparency = 1
    local uiListLayout6 = Instance.new("UIListLayout")
    uiListLayout6.Padding = UDim.new(0, 8)
    local textLabel7 = Instance.new("TextLabel")
    textLabel7.Size = UDim2.new(1, 0, 0, 20)
    textLabel7.Text = "Email"
    textLabel7.TextSize = 14
    textLabel7.TextColor3 = Color3.fromRGB(100, 100, 100)
    textLabel7.BackgroundTransparency = 1
    textLabel7.Font = Enum.Font.Gotham
    local textBox8 = Instance.new("TextBox")
    textBox8.Size = UDim2.new(1, 0, 0, 30)
    textBox8.PlaceholderText = "you@example.com"
    textBox8.TextSize = 16
    textBox8.TextColor3 = BLACK
    textBox8.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    textBox8.BorderSizePixel = 0
    textBox8.ClearTextOnFocus = true
    textBox8.Text = self.state.email:clone()
    table.insert(self._connections, self.state:subscribe("email", function(value)
        textBox8.Text = self.state.email:clone()
    end))
    uiListLayout6.Parent = frame5
    textLabel7.Parent = frame5
    textBox8.Parent = frame5
    local frame9 = Instance.new("Frame")
    frame9.Size = UDim2.new(1, 0, 0, 50)
    frame9.BackgroundTransparency = 1
    local uiListLayout10 = Instance.new("UIListLayout")
    uiListLayout10.Padding = UDim.new(0, 8)
    local textLabel11 = Instance.new("TextLabel")
    textLabel11.Size = UDim2.new(1, 0, 0, 20)
    textLabel11.Text = "Password"
    textLabel11.TextSize = 14
    textLabel11.TextColor3 = Color3.fromRGB(100, 100, 100)
    textLabel11.BackgroundTransparency = 1
    textLabel11.Font = Enum.Font.Gotham
    local textBox12 = Instance.new("TextBox")
    textBox12.Size = UDim2.new(1, 0, 0, 30)
    textBox12.PlaceholderText = "••••••••"
    textBox12.TextSize = 16
    textBox12.TextColor3 = BLACK
    textBox12.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    textBox12.BorderSizePixel = 0
    textBox12.ClearTextOnFocus = true
    textBox12.Text = self.state.password:clone()
    table.insert(self._connections, self.state:subscribe("password", function(value)
        textBox12.Text = self.state.password:clone()
    end))
    uiListLayout10.Parent = frame9
    textLabel11.Parent = frame9
    textBox12.Parent = frame9
    local textButton13 = Instance.new("TextButton")
    textButton13.Size = UDim2.new(1, 0, 0, 50)
    textButton13.TextSize = 16
    textButton13.TextColor3 = WHITE
    textButton13.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    textButton13.BorderSizePixel = 0
    textButton13.Text = if self.state.is_loading then "Loading..." else "Sign In" end
    table.insert(self._connections, self.state:subscribe("is_loading", function(value)
        textButton13.Text = if self.state.is_loading then "Loading..." else "Sign In" end
    end))
    textButton13.Font = Enum.Font.GothamBold
    local frame14 = Instance.new("Frame")
    frame14.Size = UDim2.new(1, 0, 0, 20)
    frame14.BackgroundTransparency = 1
    local textLabel15 = Instance.new("TextLabel")
    textLabel15.Size = UDim2.new(1, 0, 1, 0)
    textLabel15.Text = "Don't have an account? Sign up"
    textLabel15.TextSize = 14
    textLabel15.TextColor3 = Color3.fromRGB(0, 122, 255)
    textLabel15.BackgroundTransparency = 1
    textLabel15.Font = Enum.Font.Gotham
    textLabel15.Parent = frame14
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame5.Parent = frame1
    frame9.Parent = frame1
    textButton13.Parent = frame1
    frame14.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function LoginForm:setState(changes)
    self.state:update(changes)
end

function LoginForm:destroy()
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

return LoginForm
