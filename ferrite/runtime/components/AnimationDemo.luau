local Signal = require(script.Parent.Parent.Signal)


local AnimationDemo = {}
AnimationDemo.__index = AnimationDemo

function AnimationDemo.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            is_animating = false,
            animation_type = "fade",
            progress = 0.0,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, AnimationDemo)
    self:_mount()
    return self
end

function AnimationDemo:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.BorderSizePixel = 0
    frame1.Size = UDim2:new(0, 500, 0, 600)
    frame1.Position = UDim2:new(0.5, -250, 0.5, -300)
    frame1.BackgroundColor3 = Color3:fromRGB(255, 255, 255)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim:new(0, 16)
    local frame3 = Instance.new("Frame")
    frame3.BackgroundTransparency = 1
    frame3.Size = UDim2:new(1, 0, 0, 60)
    local textLabel4 = Instance.new("TextLabel")
    textLabel4.Text = "Animation Demo"
    textLabel4.TextSize = 24
    textLabel4.BackgroundTransparency = 1
    textLabel4.Size = UDim2:new(1, 0, 1, 0)
    textLabel4.TextColor3 = Color3:fromRGB(30, 41, 59)
    textLabel4.Font = Enum.Font.GothamBold
    textLabel4.Parent = frame3
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2:new(1, -32, 0, 200)
    frame5.BackgroundColor3 = Color3:fromRGB(248, 250, 252)
    local uiListLayout6 = Instance.new("UIListLayout")
    uiListLayout6.Padding = UDim:new(0, 8)
    local textLabel7 = Instance.new("TextLabel")
    textLabel7.Text = "Preview"
    textLabel7.TextSize = 14
    textLabel7.BackgroundTransparency = 1
    textLabel7.Size = UDim2:new(1, 0, 0, 20)
    textLabel7.TextColor3 = Color3:fromRGB(107, 114, 128)
    textLabel7.Font = Enum.Font.Gotham
    local frame8 = Instance.new("Frame")
    frame8.Size = UDim2:new(1, -32, 1, -28)
    frame8.BackgroundColor3 = Color3:fromRGB(255, 255, 255)
    local animatedbox9 = Instance.new("AnimatedBox")
    animatedbox9.is_animating = self.state.is_animating:clone()
    table.insert(self._connections, self.state:subscribe("is_animating", function(value)
        animatedbox9.is_animating = self.state.is_animating:clone()
    end))
    animatedbox9.animation_type = self.state.animation_type:clone()
    table.insert(self._connections, self.state:subscribe("animation_type", function(value)
        animatedbox9.animation_type = self.state.animation_type:clone()
    end))
    animatedbox9.progress = self.state.progress:clone()
    table.insert(self._connections, self.state:subscribe("progress", function(value)
        animatedbox9.progress = self.state.progress:clone()
    end))
    animatedbox9.Parent = frame8
    uiListLayout6.Parent = frame5
    textLabel7.Parent = frame5
    frame8.Parent = frame5
    local frame10 = Instance.new("Frame")
    frame10.BackgroundTransparency = 1
    frame10.Size = UDim2:new(1, -32, 0, 150)
    local uiListLayout11 = Instance.new("UIListLayout")
    uiListLayout11.Padding = UDim:new(0, 12)
    local textLabel12 = Instance.new("TextLabel")
    textLabel12.Text = "Controls"
    textLabel12.TextSize = 14
    textLabel12.BackgroundTransparency = 1
    textLabel12.Size = UDim2:new(1, 0, 0, 20)
    textLabel12.TextColor3 = Color3:fromRGB(107, 114, 128)
    textLabel12.Font = Enum.Font.Gotham
    local frame13 = Instance.new("Frame")
    frame13.BackgroundTransparency = 1
    frame13.Size = UDim2:new(1, 0, 0, 40)
    local uiListLayout14 = Instance.new("UIListLayout")
    uiListLayout14.Padding = UDim:new(0, 8)
    uiListLayout14.FillDirection = Enum.FillDirection.Horizontal
    local textButton15 = Instance.new("TextButton")
    textButton15.Text = "Play"
    textButton15.TextSize = 16
    textButton15.BorderSizePixel = 0
    textButton15.Size = UDim2:new(0, 100, 1, 0)
    textButton15.BackgroundColor3 = Color3:fromRGB(34, 197, 94)
    textButton15.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton15.Font = Enum.Font.GothamBold
    local textButton16 = Instance.new("TextButton")
    textButton16.Text = "Reset"
    textButton16.TextSize = 16
    textButton16.BorderSizePixel = 0
    textButton16.Size = UDim2:new(0, 100, 1, 0)
    textButton16.BackgroundColor3 = Color3:fromRGB(59, 130, 246)
    textButton16.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton16.Font = Enum.Font.GothamBold
    uiListLayout14.Parent = frame13
    textButton15.Parent = frame13
    textButton16.Parent = frame13
    local frame17 = Instance.new("Frame")
    frame17.BackgroundTransparency = 1
    frame17.Size = UDim2:new(1, 0, 0, 40)
    local uiListLayout18 = Instance.new("UIListLayout")
    uiListLayout18.Padding = UDim:new(0, 8)
    uiListLayout18.FillDirection = Enum.FillDirection.Horizontal
    local textButton19 = Instance.new("TextButton")
    textButton19.Text = "Fade"
    textButton19.TextSize = 14
    textButton19.BorderSizePixel = 0
    textButton19.Size = UDim2:new(0, 80, 1, 0)
    textButton19.BackgroundColor3 = Color3:fromRGB(59, 130, 246)
    textButton19.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton19.Font = Enum.Font.Gotham
    local textButton20 = Instance.new("TextButton")
    textButton20.Text = "Slide"
    textButton20.TextSize = 14
    textButton20.BorderSizePixel = 0
    textButton20.Size = UDim2:new(0, 80, 1, 0)
    textButton20.BackgroundColor3 = Color3:fromRGB(209, 213, 219)
    textButton20.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton20.Font = Enum.Font.Gotham
    local textButton21 = Instance.new("TextButton")
    textButton21.Text = "Scale"
    textButton21.TextSize = 14
    textButton21.BorderSizePixel = 0
    textButton21.Size = UDim2:new(0, 80, 1, 0)
    textButton21.BackgroundColor3 = Color3:fromRGB(209, 213, 219)
    textButton21.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton21.Font = Enum.Font.Gotham
    local textButton22 = Instance.new("TextButton")
    textButton22.Text = "Rotate"
    textButton22.TextSize = 14
    textButton22.BorderSizePixel = 0
    textButton22.Size = UDim2:new(0, 80, 1, 0)
    textButton22.BackgroundColor3 = Color3:fromRGB(209, 213, 219)
    textButton22.TextColor3 = Color3:fromRGB(255, 255, 255)
    textButton22.Font = Enum.Font.Gotham
    uiListLayout18.Parent = frame17
    textButton19.Parent = frame17
    textButton20.Parent = frame17
    textButton21.Parent = frame17
    textButton22.Parent = frame17
    uiListLayout11.Parent = frame10
    textLabel12.Parent = frame10
    frame13.Parent = frame10
    frame17.Parent = frame10
    local frame23 = Instance.new("Frame")
    frame23.BackgroundTransparency = 1
    frame23.Size = UDim2:new(1, -32, 0, 30)
    local uiListLayout24 = Instance.new("UIListLayout")
    uiListLayout24.Padding = UDim:new(0, 8)
    local textLabel25 = Instance.new("TextLabel")
    textLabel25.Text = "Progress: 0%"
    textLabel25.TextSize = 14
    textLabel25.BackgroundTransparency = 1
    textLabel25.Size = UDim2:new(1, 0, 0, 16)
    textLabel25.TextColor3 = Color3:fromRGB(107, 114, 128)
    textLabel25.Font = Enum.Font.Gotham
    local frame26 = Instance.new("Frame")
    frame26.Size = UDim2:new(1, 0, 0, 6)
    frame26.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local frame27 = Instance.new("Frame")
    frame27.Size = UDim2:new(0, 0, 1, 0)
    frame27.BackgroundColor3 = Color3:fromRGB(59, 130, 246)
    frame27.Parent = frame26
    uiListLayout24.Parent = frame23
    textLabel25.Parent = frame23
    frame26.Parent = frame23
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame5.Parent = frame1
    frame10.Parent = frame1
    frame23.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function AnimationDemo:setState(changes)
    self.state:update(changes)
end

function AnimationDemo:destroy()
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

return AnimationDemo
