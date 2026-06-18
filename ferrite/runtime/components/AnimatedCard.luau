local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)

local AnimatedCard = {}
AnimatedCard.__index = AnimatedCard

function AnimatedCard.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            scale = 1.0,
            is_hovered = false,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, AnimatedCard)
    self:_mount()
    return self
end

function AnimatedCard:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 400, 0, 300)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -200, 0.5, -150)
    local uiScale2 = Instance.new("UIScale")
    uiScale2.Scale = 1.0
    local uiPadding3 = Instance.new("UIPadding")
    uiPadding3.PaddingLeft = UDim.new(0, 20)
    uiPadding3.PaddingRight = UDim.new(0, 20)
    uiPadding3.PaddingTop = UDim.new(0, 20)
    uiPadding3.PaddingBottom = UDim.new(0, 20)
    local uiListLayout4 = Instance.new("UIListLayout")
    uiListLayout4.Padding = UDim.new(0, 20)
    uiListLayout4.FillDirection = Enum.FillDirection.Vertical
    uiListLayout4.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(1, 0, 0, 150)
    frame5.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    frame5.BorderSizePixel = 0
    local frame6 = Instance.new("Frame")
    frame6.Size = UDim2.new(0, 60, 0, 60)
    frame6.BackgroundColor3 = WHITE
    frame6.BorderSizePixel = 0
    frame6.Position = UDim2.new(0.5, -30, 0.5, -30)
    local textLabel7 = Instance.new("TextLabel")
    textLabel7.Size = UDim2.new(1, 0, 0, 30)
    textLabel7.Position = UDim2.new(0, 0, 1, 10)
    textLabel7.Text = "Welcome"
    textLabel7.TextSize = 24
    textLabel7.TextColor3 = WHITE
    textLabel7.BackgroundTransparency = 1
    textLabel7.Font = Enum.Font.GothamBold
    textLabel7.TextXAlignment = Enum.TextXAlignment.Center
    frame6.Parent = frame5
    textLabel7.Parent = frame5
    local textLabel8 = Instance.new("TextLabel")
    textLabel8.Size = UDim2.new(1, 0, 0, 60)
    textLabel8.Text = "This is a beautiful animated card with smooth transitions and modern design."
    textLabel8.TextSize = 16
    textLabel8.TextColor3 = Color3.fromRGB(100, 100, 100)
    textLabel8.BackgroundTransparency = 1
    textLabel8.TextWrapped = true
    textLabel8.Font = Enum.Font.Gotham
    textLabel8.TextXAlignment = Enum.TextXAlignment.Center
    textLabel8.TextYAlignment = Enum.TextYAlignment.Top
    local textButton9 = Instance.new("TextButton")
    textButton9.Size = UDim2.new(0, 120, 0, 40)
    textButton9.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    textButton9.BorderSizePixel = 0
    textButton9.Text = "Get Started"
    textButton9.TextSize = 18
    textButton9.TextColor3 = WHITE
    textButton9.BackgroundTransparency = 0
    textButton9.Font = Enum.Font.GothamBold
    textButton9.TextXAlignment = Enum.TextXAlignment.Center
    textButton9.TextYAlignment = Enum.TextYAlignment.Center
    uiScale2.Parent = frame1
    uiPadding3.Parent = frame1
    uiListLayout4.Parent = frame1
    frame5.Parent = frame1
    textLabel8.Parent = frame1
    textButton9.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function AnimatedCard:setState(changes)
    self.state:update(changes)
end

function AnimatedCard:destroy()
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

return AnimatedCard
