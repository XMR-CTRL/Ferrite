local Signal = require(script.Parent.Parent.Signal)


local SettingsPanel = {}
SettingsPanel.__index = SettingsPanel

function SettingsPanel.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            active_section = "general",
            settings = { notifications_enabled = true, dark_mode = false, auto_save = true, volume = 75, language = "en", theme = "blue" },
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, SettingsPanel)
    self:_mount()
    return self
end

function SettingsPanel:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.BorderSizePixel = 0
    frame1.Size = UDim2:new(0, 600, 0, 500)
    frame1.Position = UDim2:new(0.5, -300, 0.5, -250)
    frame1.BackgroundColor3 = Color3:fromRGB(255, 255, 255)
    local uiListLayout2 = Instance.new("UIListLayout")
    uiListLayout2.Padding = UDim:new(0, 0)
    uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2:new(0, 180, 1, 0)
    frame3.BackgroundColor3 = Color3:fromRGB(248, 250, 252)
    local uiListLayout4 = Instance.new("UIListLayout")
    uiListLayout4.Padding = UDim:new(0, 4)
    local frame5 = Instance.new("Frame")
    frame5.BackgroundTransparency = 1
    frame5.Size = UDim2:new(1, 0, 0, 50)
    local textLabel6 = Instance.new("TextLabel")
    textLabel6.Text = "Settings"
    textLabel6.TextSize = 20
    textLabel6.BackgroundTransparency = 1
    textLabel6.Size = UDim2:new(1, 0, 1, 0)
    textLabel6.TextColor3 = Color3:fromRGB(30, 41, 59)
    textLabel6.Font = Enum.Font.GothamBold
    textLabel6.Parent = frame5
    local settingsnavitem7 = Instance.new("SettingsNavItem")
    settingsnavitem7.label = "General"
    settingsnavitem7.active = true
    local settingsnavitem8 = Instance.new("SettingsNavItem")
    settingsnavitem8.label = "Appearance"
    settingsnavitem8.active = false
    local settingsnavitem9 = Instance.new("SettingsNavItem")
    settingsnavitem9.label = "Notifications"
    settingsnavitem9.active = false
    uiListLayout4.Parent = frame3
    frame5.Parent = frame3
    settingsnavitem7.Parent = frame3
    settingsnavitem8.Parent = frame3
    settingsnavitem9.Parent = frame3
    local frame10 = Instance.new("Frame")
    frame10.BackgroundTransparency = 1
    frame10.Size = UDim2:new(1, -180, 1, 0)
    local uiListLayout11 = Instance.new("UIListLayout")
    uiListLayout11.Padding = UDim:new(0, 16)
    local frame12 = Instance.new("Frame")
    frame12.BackgroundTransparency = 1
    frame12.Size = UDim2:new(1, 0, 0, 50)
    local textLabel13 = Instance.new("TextLabel")
    textLabel13.Text = "Settings"
    textLabel13.TextSize = 24
    textLabel13.BackgroundTransparency = 1
    textLabel13.Size = UDim2:new(1, 0, 1, 0)
    textLabel13.TextColor3 = Color3:fromRGB(30, 41, 59)
    textLabel13.Font = Enum.Font.GothamBold
    textLabel13.Parent = frame12
    local frame14 = Instance.new("Frame")
    frame14.Size = UDim2:new(1, 0, 0, 1)
    frame14.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local settingtoggle15 = Instance.new("SettingToggle")
    settingtoggle15.label = "Auto Save"
    settingtoggle15.description = "Automatically save your work"
    settingtoggle15.enabled = self.state.settings.auto_save
    table.insert(self._connections, self.state:subscribe("settings", function(value)
        settingtoggle15.enabled = self.state.settings.auto_save
    end))
    local frame16 = Instance.new("Frame")
    frame16.Size = UDim2:new(1, 0, 0, 1)
    frame16.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local settingslider17 = Instance.new("SettingSlider")
    settingslider17.label = "Volume"
    settingslider17.min = 0
    settingslider17.max = 100
    settingslider17.value = self.state.settings.volume
    table.insert(self._connections, self.state:subscribe("settings", function(value)
        settingslider17.value = self.state.settings.volume
    end))
    local frame18 = Instance.new("Frame")
    frame18.Size = UDim2:new(1, 0, 0, 1)
    frame18.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local settingtoggle19 = Instance.new("SettingToggle")
    settingtoggle19.label = "Dark Mode"
    settingtoggle19.description = "Enable dark theme"
    settingtoggle19.enabled = self.state.settings.dark_mode
    table.insert(self._connections, self.state:subscribe("settings", function(value)
        settingtoggle19.enabled = self.state.settings.dark_mode
    end))
    local frame20 = Instance.new("Frame")
    frame20.Size = UDim2:new(1, 0, 0, 1)
    frame20.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local settingdropdown21 = Instance.new("SettingDropdown")
    settingdropdown21.label = "Theme"
    settingdropdown21.options = vec! ["blue".to_string(), "green".to_string(), "purple".to_string()]
    settingdropdown21.selected = self.state.settings.theme:clone()
    table.insert(self._connections, self.state:subscribe("settings", function(value)
        settingdropdown21.selected = self.state.settings.theme:clone()
    end))
    local frame22 = Instance.new("Frame")
    frame22.Size = UDim2:new(1, 0, 0, 1)
    frame22.BackgroundColor3 = Color3:fromRGB(229, 231, 235)
    local settingtoggle23 = Instance.new("SettingToggle")
    settingtoggle23.label = "Enable Notifications"
    settingtoggle23.description = "Receive push notifications"
    settingtoggle23.enabled = self.state.settings.notifications_enabled
    table.insert(self._connections, self.state:subscribe("settings", function(value)
        settingtoggle23.enabled = self.state.settings.notifications_enabled
    end))
    uiListLayout11.Parent = frame10
    frame12.Parent = frame10
    frame14.Parent = frame10
    settingtoggle15.Parent = frame10
    frame16.Parent = frame10
    settingslider17.Parent = frame10
    frame18.Parent = frame10
    settingtoggle19.Parent = frame10
    frame20.Parent = frame10
    settingdropdown21.Parent = frame10
    frame22.Parent = frame10
    settingtoggle23.Parent = frame10
    uiListLayout2.Parent = frame1
    frame3.Parent = frame1
    frame10.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function SettingsPanel:setState(changes)
    self.state:update(changes)
end

function SettingsPanel:destroy()
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

return SettingsPanel
