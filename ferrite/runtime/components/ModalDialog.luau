local Signal = require(script.Parent.Parent.Signal)

    -- Constants
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local WHITE = Color3.fromRGB(255, 255, 255)

local ModalDialog = {}
ModalDialog.__index = ModalDialog

function ModalDialog.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({
            is_open = true,
        }),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, ModalDialog)
    self:_mount()
    return self
end

function ModalDialog:_mount()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    local frame1 = Instance.new("Frame")
    frame1.Size = UDim2.new(0, 400, 0, 300)
    frame1.BackgroundColor3 = WHITE
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, -200, 0.5, -150)
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Size = UDim2.new(1, 0, 0, 50)
    textLabel2.Text = "Modal Dialog"
    textLabel2.TextSize = 24
    textLabel2.TextColor3 = BLACK
    textLabel2.BackgroundTransparency = 1
    textLabel2.Font = Enum.Font.GothamBold
    textLabel2.TextXAlignment = Enum.TextXAlignment.Center
    local textButton3 = Instance.new("TextButton")
    textButton3.Size = UDim2.new(0, 100, 0, 40)
    textButton3.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    textButton3.Text = "Close"
    textButton3.TextSize = 18
    textButton3.TextColor3 = WHITE
    textButton3.Position = UDim2.new(0.5, -50, 1, -50)
    textButton3.Font = Enum.Font.GothamBold
    textLabel2.Parent = frame1
    textButton3.Parent = frame1
    frame1.Parent = screenGui
    screenGui.Parent = self.parent
    self._root = screenGui
end

function ModalDialog:setState(changes)
    self.state:update(changes)
end

function ModalDialog:destroy()
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

return ModalDialog
