local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)

local SimpleButton = {}
SimpleButton.__index = SimpleButton

function SimpleButton.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            count = 0,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, SimpleButton)
    self:_mount()
    return self
end

function SimpleButton:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local textButton1 = Instance.new("TextButton")
    textButton1.Size = UDim2.new(0, 200, 0, 50)
    textButton1.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    textButton1.Text = "Click Me"
    textButton1.TextSize = 20
    textButton1.TextColor3 = WHITE
    textButton1.Position = UDim2.new(0.5, -100, 0.5, -25)
    textButton1.Font = Enum.Font.GothamBold
    textButton1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function SimpleButton:setState(changes)
    self.state:update(changes)
end

function SimpleButton:destroy()
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

return SimpleButton
