local Signal = require(script.Parent.Parent.Signal)


local ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            progress = 50.0,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, ProgressBar)
    self:_mount()
    return self
end

function ProgressBar:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 300, 0, 30)
    frame1.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -150, 0.5, -15)
    local frame2 = Instance.new("Frame")
    frame2.Size = UDim2.new(0.5, 0, 1, 0)
    frame2.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    frame2.BorderSizePixel = 0
    frame2.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function ProgressBar:setState(changes)
    self.state:update(changes)
end

function ProgressBar:destroy()
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

return ProgressBar
