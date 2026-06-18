local DevTools = {}
DevTools.__index = DevTools

-- Component registry for debugging
local componentRegistry = {}
local componentInstances = {}

function DevTools.registerComponent(name, component)
    componentRegistry[name] = component
end

function DevTools.trackInstance(componentName, instance)
    if not componentInstances[componentName] then
        componentInstances[componentName] = {}
    end
    table.insert(componentInstances[componentName], {
        instance = instance,
        timestamp = tick(),
    })
end

function DevTools.getComponentTree()
    local tree = {}
    for name, instances in pairs(componentInstances) do
        tree[name] = #instances
    end
    return tree
end

function DevTools.inspectComponent(componentName)
    local instances = componentInstances[componentName]
    if not instances then
        return nil
    end
    
    local info = {
        name = componentName,
        instanceCount = #instances,
        instances = {},
    }
    
    for i, data in ipairs(instances) do
        table.insert(info.instances, {
            index = i,
            timestamp = data.timestamp,
            properties = DevTools.getInstanceProperties(data.instance),
        })
    end
    
    return info
end

function DevTools.getInstanceProperties(instance)
    local props = {}
    for _, prop in ipairs(instance:GetChildren()) do
        props[prop.Name] = {
            ClassName = prop.ClassName,
            Properties = DevTools.getUIProperties(prop),
        }
    end
    return props
end

function DevTools.getUIProperties(instance)
    local props = {}
    local uiProps = {
        "Size", "Position", "AnchorPoint", "BackgroundColor3", "BackgroundTransparency",
        "TextColor3", "TextSize", "Text", "Visible", "ZIndex"
    }
    
    for _, prop in ipairs(uiProps) do
        local success, value = pcall(function()
            return instance[prop]
        end)
        if success then
            props[prop] = value
        end
    end
    
    return props
end

function DevTools.enableProfiler()
    DevTools.profilerEnabled = true
    DevTools.profileData = {}
end

function DevTools.disableProfiler()
    DevTools.profilerEnabled = false
end

function DevTools.recordRender(componentName, duration)
    if DevTools.profilerEnabled then
        if not DevTools.profileData[componentName] then
            DevTools.profileData[componentName] = {
                renderCount = 0,
                totalTime = 0,
                avgTime = 0,
            }
        end
        
        local data = DevTools.profileData[componentName]
        data.renderCount = data.renderCount + 1
        data.totalTime = data.totalTime + duration
        data.avgTime = data.totalTime / data.renderCount
    end
end

function DevTools.getProfileData()
    return DevTools.profileData
end

function DevTools.clearProfileData()
    DevTools.profileData = {}
end

-- Create devtools UI
function DevTools.createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FerriteDevTools"
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(1, -320, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.Parent = screenGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Ferrite DevTools"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.Parent = mainFrame
    
    local componentList = Instance.new("ScrollingFrame")
    componentList.Name = "ComponentList"
    componentList.Size = UDim2.new(1, 0, 1, 0)
    componentList.BackgroundTransparency = 1
    componentList.ScrollBarThickness = 8
    componentList.Parent = contentFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = componentList
    
    -- Refresh button
    local refreshButton = Instance.new("TextButton")
    refreshButton.Name = "RefreshButton"
    refreshButton.Size = UDim2.new(0, 80, 0, 24)
    refreshButton.Position = UDim2.new(1, -90, 0, 3)
    refreshButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Text = "Refresh"
    refreshButton.TextSize = 12
    refreshButton.Parent = titleBar
    
    refreshButton.MouseButton1Click:Connect(function()
        DevTools.refreshComponentList(componentList)
    end)
    
    DevTools.screenGui = screenGui
    DevTools.componentList = componentList
    
    return screenGui
end

function DevTools.refreshComponentList(scrollingFrame)
    -- Clear existing items
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add component items
    local tree = DevTools.getComponentTree()
    for name, count in pairs(tree) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = name .. "Item"
        itemFrame.Size = UDim2.new(1, 0, 0, 30)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        itemFrame.Parent = scrollingFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        local countLabel = Instance.new("TextLabel")
        countLabel.Name = "CountLabel"
        countLabel.Size = UDim2.new(0.4, 0, 1, 0)
        countLabel.Position = UDim2.new(0.6, 0, 0, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = tostring(count)
        countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        countLabel.TextSize = 14
        countLabel.Parent = itemFrame
        
        local inspectButton = Instance.new("TextButton")
        inspectButton.Name = "InspectButton"
        inspectButton.Size = UDim2.new(0, 60, 0, 20)
        inspectButton.Position = UDim2.new(1, -70, 0.5, -10)
        inspectButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        inspectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        inspectButton.Text = "Inspect"
        inspectButton.TextSize = 12
        inspectButton.Parent = itemFrame
        
        inspectButton.MouseButton1Click:Connect(function()
            DevTools.showComponentInspector(name)
        end)
    end
end

function DevTools.showComponentInspector(componentName)
    local info = DevTools.inspectComponent(componentName)
    if not info then
        return
    end
    
    -- Create inspector window
    local inspectorGui = Instance.new("ScreenGui")
    inspectorGui.Name = "ComponentInspector"
    inspectorGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.Parent = inspectorGui
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.TextSize = 16
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        inspectorGui:Destroy()
    end)
    
    DevTools.inspectorGui = inspectorGui
end

function DevTools.toggle()
    if DevTools.screenGui then
        DevTools.screenGui.Enabled = not DevTools.screenGui.Enabled
    else
        DevTools.createUI()
    end
end

return DevTools
