local Signal = require(script.Parent.Parent.Signal)


local Grid = {}
Grid.__index = Grid

function Grid.new(parent, props)
    local self = setmetatable({
        parent = parent,
        props = props or {},
        state = Signal.new({}),
        refs = {},
        _connections = {},
        _effects = {},
        _animations = {},
        _root = nil,
    }, Grid)
    self:_mount()
    return self
end

function Grid:_mount()
    local frame0 = Instance.new("Frame")
    frame0.Size = UDim2.new(1, 0, 1, 0)
    frame0.BackgroundTransparency = 1
    local uigridlayout1 = Instance.new("UIGridLayout")
    uigridlayout1.FillDirectionMaxCells = 4
    uigridlayout1.CellSize = UDim2:new(0, 100, 0, 100)
    uigridlayout1.CellPadding = UDim2:new(0, 8, 0, 8)
    uigridlayout1.StartCorner = Enum.StartCorner.TopLeft
    uigridlayout1.FillDirection = Enum.FillDirection.Horizontal
    uigridlayout1.Parent = frame0
    frame0.Parent = self.parent
    self._root = frame0
end

function Grid:setState(changes)
    self.state:update(changes)
end

function Grid:destroy()
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

return Grid
