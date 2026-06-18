local Signal = require(script.Parent.Parent.Signal)


local Dashboard = {}
Dashboard.__index = Dashboard

function Dashboard.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            notifications = {},
            active_tab = "overview",
            stats = { users = 1250, revenue = 45000, sessions = 890, conversion = 12.5 },
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Dashboard)
    self:_mount()
    return self
end

function Dashboard:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2:new(1, 0, 1, 0)
    frame1.BackgroundColor3 = Color3:fromRGB(245, 247, 250)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim:new(0, 0)
    uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2:new(0, 250, 1, 0)
    frame3.BackgroundColor3 = Color3:fromRGB(30, 41, 59)
    local uiListLayout4 = Instance.new("UIListLayout")
    uiListLayout4.Padding = UDim:new(0, 8)
    local frame5 = Instance.new("Frame")
    frame5.BackgroundTransparency = 1
    frame5.Size = UDim2:new(1, 0, 0, 60)
    local textLabel6 = Instance.new("TextLabel")
    textLabel6.Text = "Dashboard"
    textLabel6.TextSize = 24
    textLabel6.BackgroundTransparency = 1
    textLabel6.Size = UDim2:new(1, 0, 1, 0)
    textLabel6.TextColor3 = Color3:fromRGB(255, 255, 255)
    textLabel6.Font = Enum.Font.GothamBold
    textLabel6.Parent = frame5
    local sidebaritem7 = Instance.new("SidebarItem")
    sidebaritem7.label = "Overview"
    sidebaritem7.active = true
    local sidebaritem8 = Instance.new("SidebarItem")
    sidebaritem8.label = "Analytics"
    sidebaritem8.active = false
    local sidebaritem9 = Instance.new("SidebarItem")
    sidebaritem9.label = "Users"
    sidebaritem9.active = false
    uiListLayout4.Parent = frame3
    frame5.Parent = frame3
    sidebaritem7.Parent = frame3
    sidebaritem8.Parent = frame3
    sidebaritem9.Parent = frame3
    local frame10 = Instance.new("Frame")
    frame10.BackgroundTransparency = 1
    frame10.Size = UDim2:new(1, -250, 1, 0)
    local uiListLayout11 = Instance.new("UIListLayout")
    uiListLayout11.Padding = UDim:new(0, 16)
    local frame12 = Instance.new("Frame")
    frame12.BackgroundTransparency = 1
    frame12.Size = UDim2:new(1, 0, 0, 60)
    local textLabel13 = Instance.new("TextLabel")
    textLabel13.Text = "Dashboard"
    textLabel13.TextSize = 28
    textLabel13.BackgroundTransparency = 1
    textLabel13.Size = UDim2:new(1, -100, 1, 0)
    textLabel13.TextColor3 = Color3:fromRGB(30, 41, 59)
    textLabel13.Font = Enum.Font.GothamBold
    textLabel13.Parent = frame12
    local frame14 = Instance.new("Frame")
    frame14.BackgroundTransparency = 1
    frame14.Size = UDim2:new(1, 0, 0, 200)
    local uigridlayout15 = Instance.new("UIGridLayout")
    uigridlayout15.CellSize = UDim2:new(0, 250, 0, 90)
    uigridlayout15.CellPadding = UDim2:new(0, 16, 0, 16)
    local statcard16 = Instance.new("StatCard")
    statcard16.title = "Total Users"
    statcard16.value = "1250"
    statcard16.change = "+12.5%"
    statcard16.positive = true
    local statcard17 = Instance.new("StatCard")
    statcard17.title = "Revenue"
    statcard17.value = "$45000"
    statcard17.change = "+8.2%"
    statcard17.positive = true
    local statcard18 = Instance.new("StatCard")
    statcard18.title = "Sessions"
    statcard18.value = "890"
    statcard18.change = "-3.1%"
    statcard18.positive = false
    local statcard19 = Instance.new("StatCard")
    statcard19.title = "Conversion"
    statcard19.value = "12.5%"
    statcard19.change = "+2.4%"
    statcard19.positive = true
    uigridlayout15.Parent = frame14
    statcard16.Parent = frame14
    statcard17.Parent = frame14
    statcard18.Parent = frame14
    statcard19.Parent = frame14
    uiListLayout11.Parent = frame10
    frame12.Parent = frame10
    frame14.Parent = frame10
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame10.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function Dashboard:setState(changes)
    self.state:update(changes)
end

function Dashboard:destroy()
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

return Dashboard
