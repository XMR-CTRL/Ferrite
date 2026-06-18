local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)

local CardGrid = {}
CardGrid.__index = CardGrid

function CardGrid.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, CardGrid)
    self:_mount()
    return self
end

function CardGrid:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(1, 0, 1, 0)
    frame1.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    frame1.BorderSizePixel = 0
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim.new(0, 10)
    uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.new(0, 200, 0, 150)
    frame3.BackgroundColor3 = WHITE
    frame3.BorderSizePixel = 0
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.Size = UDim2.new(1, 0, 1, 0)
    textLabel4.Text = "Card 1"
    textLabel4.TextSize = 20
    textLabel4.TextColor3 = BLACK
    textLabel4.BackgroundTransparency = 1
    textLabel4.Font = Enum.Font.GothamBold
    textLabel4.TextXAlignment = Enum.TextXAlignment.Center
    textLabel4.TextYAlignment = Enum.TextYAlignment.Center
    textLabel4.Parent = frame3
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(0, 200, 0, 150)
    frame5.BackgroundColor3 = WHITE
    frame5.BorderSizePixel = 0
    local textLabel6 = Instance.new("TextLabel")
    textLabel6.Size = UDim2.new(1, 0, 1, 0)
    textLabel6.Text = "Card 2"
    textLabel6.TextSize = 20
    textLabel6.TextColor3 = BLACK
    textLabel6.BackgroundTransparency = 1
    textLabel6.Font = Enum.Font.GothamBold
    textLabel6.TextXAlignment = Enum.TextXAlignment.Center
    textLabel6.TextYAlignment = Enum.TextYAlignment.Center
    textLabel6.Parent = frame5
    local frame7 = Instance.new("Frame")
    frame7.Size = UDim2.new(0, 200, 0, 150)
    frame7.BackgroundColor3 = WHITE
    frame7.BorderSizePixel = 0
    local textLabel8 = Instance.new("TextLabel")
    textLabel8.Size = UDim2.new(1, 0, 1, 0)
    textLabel8.Text = "Card 3"
    textLabel8.TextSize = 20
    textLabel8.TextColor3 = BLACK
    textLabel8.BackgroundTransparency = 1
    textLabel8.Font = Enum.Font.GothamBold
    textLabel8.TextXAlignment = Enum.TextXAlignment.Center
    textLabel8.TextYAlignment = Enum.TextYAlignment.Center
    textLabel8.Parent = frame7
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame5.Parent = frame1
    frame7.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function CardGrid:setState(changes)
    self.state:update(changes)
end

function CardGrid:destroy()
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

return CardGrid
