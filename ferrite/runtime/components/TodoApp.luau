local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)

local TodoApp = {}
TodoApp.__index = TodoApp

function TodoApp.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            todos = {},
            input = "",
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, TodoApp)
    self:_mount()
    return self
end

function TodoApp:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 400, 0, 500)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -200, 0.5, -250)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim.new(0, 12)
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.new(1, 0, 0, 60)
    frame3.BackgroundTransparency = 1
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.Size = UDim2.new(1, 0, 1, 0)
    textLabel4.Text = "Todo App"
    textLabel4.TextSize = 24
    textLabel4.TextColor3 = BLACK
    textLabel4.BackgroundTransparency = 1
    textLabel4.Font = Enum.Font.GothamBold
    textLabel4.Parent = frame3
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(1, 0, 0, 40)
    frame5.BackgroundTransparency = 1
    local uiListLayout6 = Instance.new("UIListLayout")
    uiListLayout6.Padding = UDim.new(0, 8)
    uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
    local textBox7 = Instance.new("TextBox")
    textBox7.PlaceholderText = "Add a todo..."
    textBox7.TextSize = 16
    textBox7.TextColor3 = BLACK
    textBox7.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    textBox7.BorderSizePixel = 0
    textBox7.ClearTextOnFocus = true
    textBox7.Size = UDim2.new(1, -80, 1, 0)
    textBox7.Text = self.state.input:clone()
    table.insert(self._connections, self.state:subscribe("input", function(value)
        textBox7.Text = self.state.input:clone()
    end))
    local textButton8 = Instance.new("TextButton")
    textButton8.Size = UDim2.new(0, 60, 1, 0)
    textButton8.Text = "Add"
    textButton8.TextSize = 16
    textButton8.TextColor3 = WHITE
    textButton8.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    textButton8.BorderSizePixel = 0
    textButton8.Font = Enum.Font.GothamBold
    uiListLayout6.Parent = frame5
    textBox7.Parent = frame5
    textButton8.Parent = frame5
    local frame9 = Instance.new("Frame")
    frame9.BackgroundTransparency = 1
    frame9.Size = UDim2.new(1, 0, 1, -112)
    local uiListLayout10 = Instance.new("UIListLayout")
    uiListLayout10.Padding = UDim.new(0, 8)
    uiListLayout10.Parent = frame9
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame5.Parent = frame1
    frame9.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function TodoApp:setState(changes)
    self.state:update(changes)
end

function TodoApp:destroy()
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

return TodoApp
