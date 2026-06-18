local HMR = {}
HMR.__index = HMR

-- Hot Module Replacement system for development
local componentVersions = {}
local hotReloadCallbacks = {}
local componentInstances = {} -- Track all component instances
local stateSnapshots = {} -- Store state snapshots for hot reload

function HMR.enable()
    HMR.enabled = true
    print("HMR Enabled")
end

function HMR.disable()
    HMR.enabled = false
    print("HMR Disabled")
end

function HMR.registerComponent(componentName, component)
    if not componentVersions[componentName] then
        componentVersions[componentName] = {
            version = 0,
            current = component,
        }
    else
        componentVersions[componentName].version = componentVersions[componentName].version + 1
        local oldComponent = componentVersions[componentName].current
        componentVersions[componentName].current = component
        
        -- Trigger hot reload for this component
        HMR.triggerReload(componentName, oldComponent, component)
    end
end

function HMR.trackInstance(componentName, instance)
    if not componentInstances[componentName] then
        componentInstances[componentName] = {}
    end
    table.insert(componentInstances[componentName], instance)
end

function HMR.untrackInstance(componentName, instance)
    if componentInstances[componentName] then
        for i, inst in ipairs(componentInstances[componentName]) do
            if inst == instance then
                table.remove(componentInstances[componentName], i)
                break
            end
        end
    end
end

function HMR.triggerReload(componentName, oldComponent, newComponent)
    if not HMR.enabled then return end
    
    print("Hot reloading: " .. componentName)
    
    -- Take state snapshot before reload
    HMR.takeStateSnapshot(componentName)
    
    -- Call registered callbacks
    if hotReloadCallbacks[componentName] then
        for _, callback in ipairs(hotReloadCallbacks[componentName]) do
            callback(oldComponent, newComponent)
        end
    end
    
    -- Find and reload all instances of this component
    HMR.reloadComponentInstances(componentName, oldComponent, newComponent)
    
    -- Restore state after reload
    HMR.restoreStateSnapshot(componentName)
end

function HMR.takeStateSnapshot(componentName)
    if not componentInstances[componentName] then return end
    
    stateSnapshots[componentName] = {}
    
    for _, instance in ipairs(componentInstances[componentName]) do
        local snapshot = HMR.preserveState(instance)
        table.insert(stateSnapshots[componentName], snapshot)
    end
end

function HMR.restoreStateSnapshot(componentName)
    if not stateSnapshots[componentName] then return end
    if not componentInstances[componentName] then return end
    
    for i, instance in ipairs(componentInstances[componentName]) do
        local snapshot = stateSnapshots[componentName][i]
        if snapshot then
            HMR.restoreState(instance, snapshot)
        end
    end
    
    stateSnapshots[componentName] = nil
end

function HMR.reloadComponentInstances(componentName, oldComponent, newComponent)
    if not componentInstances[componentName] then return end
    
    for _, instance in ipairs(componentInstances[componentName]) do
        -- Preserve component props and state
        local props = instance.props or {}
        local parent = instance.parent
        
        -- Destroy old instance
        if instance.destroy then
            instance:destroy()
        elseif instance.Destroy then
            instance:Destroy()
        end
        
        -- Create new instance with same props
        local newInstance = newComponent.new(parent, props)
        
        -- Update tracking
        HMR.untrackInstance(componentName, instance)
        HMR.trackInstance(componentName, newInstance)
    end
end

function HMR.onReload(componentName, callback)
    if not hotReloadCallbacks[componentName] then
        hotReloadCallbacks[componentName] = {}
    end
    table.insert(hotReloadCallbacks[componentName], callback)
end

function HMR.getComponentVersion(componentName)
    if componentVersions[componentName] then
        return componentVersions[componentName].version
    end
    return 0
end

function HMR.getCurrentComponent(componentName)
    if componentVersions[componentName] then
        return componentVersions[componentName].current
    end
    return nil
end

-- Enhanced state preservation during hot reload
function HMR.preserveState(componentInstance)
    local state = {}
    
    if componentInstance.state then
        for key, value in pairs(componentInstance.state.value or {}) do
            state[key] = value
        end
    end
    
    if componentInstance.refs then
        state._refs = componentInstance.refs
    end
    
    if componentInstance.props then
        state._props = componentInstance.props
    end
    
    -- Preserve any custom data
    if componentInstance._customData then
        state._customData = componentInstance._customData
    end
    
    return state
end

function HMR.restoreState(componentInstance, state)
    if state._refs then
        componentInstance.refs = state._refs
        state._refs = nil
    end
    
    if state._props then
        componentInstance.props = state._props
        state._props = nil
    end
    
    if state._customData then
        componentInstance._customData = state._customData
        state._customData = nil
    end
    
    if componentInstance.state and componentInstance.state.update then
        componentInstance.state:update(state)
    end
end

-- WebSocket connection for live updates (development server)
function HMR.connectToDevServer(url)
    url = url or "ws://localhost:8080/hmr"
    
    local http = game:GetService("HttpService")
    
    spawn(function()
        while HMR.enabled do
            local success, response = pcall(function()
                return http:RequestAsync({
                    Url = url:gsub("ws://", "http://") .. "/status",
                    Method = "GET",
                })
            end)
            
            if success and response.StatusCode == 200 then
                local data = http:JSONDecode(response.Body)
                if data.components then
                    for componentName, version in pairs(data.components) do
                        local currentVersion = HMR.getComponentVersion(componentName)
                        if version > currentVersion then
                            print("New version available for: " .. componentName)
                            -- Trigger reload of new component
                            HMR.reloadComponent(componentName)
                        end
                    end
                end
            end
            
            wait(2) -- Poll every 2 seconds
        end
    end)
end

function HMR.reloadComponent(componentName)
    -- This would fetch the new component from the dev server
    -- For now, this is a placeholder
    print("Would reload component: " .. componentName)
end

-- Create HMR UI for development
function HMR.createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HMRUI"
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(1, -210, 1, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.Parent = screenGui
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.Text = "HMR: " .. (HMR.enabled and "Enabled" or "Disabled")
    statusLabel.TextColor3 = HMR.enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = mainFrame
    
    local reloadButton = Instance.new("TextButton")
    reloadButton.Name = "ReloadButton"
    reloadButton.Size = UDim2.new(1, -20, 0, 30)
    reloadButton.Position = UDim2.new(0, 10, 0, 40)
    reloadButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    reloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    reloadButton.Text = "Reload All"
    reloadButton.TextSize = 14
    reloadButton.Parent = mainFrame
    
    reloadButton.MouseButton1Click:Connect(function()
        HMR.reloadAllComponents()
    end)
    
    local componentList = Instance.new("ScrollingFrame")
    componentList.Name = "ComponentList"
    componentList.Size = UDim2.new(1, 0, 1, -80)
    componentList.Position = UDim2.new(0, 0, 0, 80)
    componentList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    componentList.ScrollBarThickness = 6
    componentList.Parent = mainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = componentList
    
    HMR.ui = {
        screenGui = screenGui,
        statusLabel = statusLabel,
        componentList = componentList,
    }
    
    HMR.updateComponentList()
    
    return screenGui
end

function HMR.updateComponentList()
    if not HMR.ui then return end
    
    -- Clear existing items
    for _, child in ipairs(HMR.ui.componentList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add component items
    for componentName, data in pairs(componentVersions) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = componentName .. "Item"
        itemFrame.Size = UDim2.new(1, 0, 0, 25)
        itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        itemFrame.Parent = HMR.ui.componentList
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = componentName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        local versionLabel = Instance.new("TextLabel")
        versionLabel.Name = "VersionLabel"
        versionLabel.Size = UDim2.new(0.3, 0, 1, 0)
        versionLabel.Position = UDim2.new(0.7, 0, 0, 0)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "v" .. data.version
        versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        versionLabel.TextSize = 12
        versionLabel.Parent = itemFrame
        
        local instanceCountLabel = Instance.new("TextLabel")
        instanceCountLabel.Name = "InstanceCountLabel"
        instanceCountLabel.Size = UDim2.new(0, 40, 0, 20)
        instanceCountLabel.Position = UDim2.new(1, -50, 0.5, -10)
        instanceCountLabel.BackgroundTransparency = 1
        instanceCountLabel.Text = componentInstances[componentName] and tostring(#componentInstances[componentName]) or "0"
        instanceCountLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        instanceCountLabel.TextSize = 10
        instanceCountLabel.Parent = itemFrame
    end
end

function HMR.toggleUI()
    if HMR.ui and HMR.ui.screenGui then
        HMR.ui.screenGui.Enabled = not HMR.ui.screenGui.Enabled
    else
        HMR.createUI()
    end
end

function HMR.reloadAllComponents()
    print("Reloading all components...")
    for componentName, _ in pairs(componentVersions) do
        HMR.reloadComponent(componentName)
    end
end

return HMR
