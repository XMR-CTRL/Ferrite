--[[
    Ferrite Animation System
    
    Spring physics, easing functions, composable animations
    Better than Roblox TweenService
]]

local Animation = {}
Animation.__index = Animation

-- RunService for frame-based updates
local RunService = (game and game:GetService("RunService")) or {
    Heartbeat = {
        Connect = function(_, callback)
            return { Disconnect = function() end, Connected = true }
        end,
        Wait = function() end,
    }
}

-- ============================================================================
-- EASING FUNCTIONS (Robert Penner's equations)
-- ============================================================================

local Easing = {}

-- Linear
Easing.Linear = function(t) return t end

-- Quad
Easing.InQuad = function(t) return t * t end
Easing.OutQuad = function(t) return t * (2 - t) end
Easing.InOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end

-- Cubic
Easing.InCubic = function(t) return t * t * t end
Easing.OutCubic = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end
Easing.InOutCubic = function(t) return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1 end

-- Quart
Easing.InQuart = function(t) return t * t * t * t end
Easing.OutQuart = function(t) return 1 - (t - 1) * (t - 1) * (t - 1) * (t - 1) end
Easing.InOutQuart = function(t) return t < 0.5 and 8 * t * t * t * t or 1 - 8 * (t - 1) * (t - 1) * (t - 1) * (t - 1) end

-- Quint
Easing.InQuint = function(t) return t * t * t * t * t end
Easing.OutQuint = function(t) return 1 + (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) end
Easing.InOutQuint = function(t) return t < 0.5 and 16 * t * t * t * t * t or 1 + 16 * (t - 1) * (t - 1) * (t - 1) * (t - 1) * (t - 1) end

-- Sine
Easing.InSine = function(t) return 1 - math.cos(t * math.pi / 2) end
Easing.OutSine = function(t) return math.sin(t * math.pi / 2) end
Easing.InOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end

-- Expo
Easing.InExpo = function(t) return t == 0 and 0 or 2 ^ (10 * (t - 1)) end
Easing.OutExpo = function(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end
Easing.InOutExpo = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    t = t * 2
    if t < 1 then return 0.5 * 2 ^ (10 * (t - 1)) end
    return 0.5 * (2 - 2 ^ (-10 * (t - 1)))
end

-- Circ
Easing.InCirc = function(t) return 1 - math.sqrt(1 - t * t) end
Easing.OutCirc = function(t) return math.sqrt(1 - (t - 1) * (t - 1)) end
Easing.InOutCirc = function(t)
    t = t * 2
    if t < 1 then return -(math.sqrt(1 - t * t) - 1) / 2 end
    t = t - 2
    return (math.sqrt(1 - t * t) + 1) / 2
end

-- Back (overshoot)
Easing.InBack = function(t)
    local s = 1.70158
    return t * t * ((s + 1) * t - s)
end
Easing.OutBack = function(t)
    local s = 1.70158
    t = t - 1
    return t * t * ((s + 1) * t + s) + 1
end
Easing.InOutBack = function(t)
    local s = 1.70158 * 1.525
    t = t * 2
    if t < 1 then return 0.5 * (t * t * ((s + 1) * t - s)) end
    t = t - 2
    return 0.5 * (t * t * ((s + 1) * t + s) + 2)
end

-- Elastic (bouncy)
Easing.InElastic = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    t = t - 1
    return -(2 ^ (10 * t)) * math.sin((t - 0.075) * (2 * math.pi) / 0.3)
end
Easing.OutElastic = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    return 2 ^ (-10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) + 1
end
Easing.InOutElastic = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    t = t * 2 - 1
    if t < 0 then
        return -0.5 * (2 ^ (10 * t)) * math.sin((t - 0.1125) * (2 * math.pi) / 0.45)
    end
    return 0.5 * 2 ^ (-10 * t) * math.sin((t - 0.1125) * (2 * math.pi) / 0.45) + 1
end

-- Bounce
local function bounceOut(t)
    if t < 1 / 2.75 then
        return 7.5625 * t * t
    elseif t < 2 / 2.75 then
        t = t - 1.5 / 2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5 / 2.75 then
        t = t - 2.25 / 2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625 / 2.75
        return 7.5625 * t * t + 0.984375
    end
end

Easing.InBounce = function(t) return 1 - bounceOut(1 - t) end
Easing.OutBounce = bounceOut
Easing.InOutBounce = function(t)
    if t < 0.5 then
        return (1 - bounceOut(1 - 2 * t)) / 2
    end
    return (1 + bounceOut(2 * t - 1)) / 2
end

Animation.Easing = Easing

-- ============================================================================
-- SPRING PHYSICS (High-performance spring simulation)
-- ============================================================================

local Spring = {}
Spring.__index = Spring

function Spring.new(target, config)
    config = config or {}
    
    return setmetatable({
        position = target or 0,
        velocity = 0,
        target = target or 0,
        
        -- Spring parameters
        tension = config.tension or 170,    -- Stiffness
        friction = config.friction or 26,   -- Damping
        mass = config.mass or 1,
        
        -- Precision
        restThreshold = config.restThreshold or 0.001,
        restVelocityThreshold = config.restVelocityThreshold or 0.001,
        
        atRest = true,
    }, Spring)
end

function Spring:setTarget(target)
    self.target = target
    self.atRest = false
end

function Spring:update(deltaTime)
    if self.atRest then return self.position end
    
    -- Spring force: F = -k * x - d * v
    local displacement = self.position - self.target
    local springForce = -self.tension * displacement
    local damperForce = -self.friction * self.velocity
    
    -- Apply forces
    local acceleration = (springForce + damperForce) / self.mass
    self.velocity = self.velocity + acceleration * deltaTime
    self.position = self.position + self.velocity * deltaTime
    
    -- Check if at rest
    if math.abs(displacement) < self.restThreshold 
        and math.abs(self.velocity) < self.restVelocityThreshold then
        self.position = self.target
        self.velocity = 0
        self.atRest = true
    end
    
    return self.position
end

function Spring:isAtRest()
    return self.atRest
end

Animation.Spring = Spring

-- ============================================================================
-- ANIMATED VALUE (Core animation primitive)
-- ============================================================================

function Animation.new(initialValue, config)
    config = config or {}
    
    local self = setmetatable({
        currentValue = initialValue,
        targetValue = initialValue,
        
        -- Animation type
        animationType = config.type or "tween",  -- "tween", "spring", "keyframe"
        
        -- Tween parameters
        duration = config.duration or 0.3,
        easing = config.easing or Easing.OutQuad,
        delay = config.delay or 0,
        
        -- Spring parameters (if type == "spring")
        spring = nil,
        
        -- State
        startValue = initialValue,
        startTime = nil,
        isAnimating = false,
        connection = nil,
        
        -- Callbacks
        onUpdate = config.onUpdate,
        onComplete = config.onComplete,
        
        -- Composition
        children = {},
    }, Animation)
    
    if self.animationType == "spring" then
        self.spring = Spring.new(initialValue, config.spring or {})
    end
    
    return self
end

function Animation:to(targetValue, config)
    config = config or {}
    
    self.targetValue = targetValue
    self.startValue = self.currentValue
    self.startTime = os.clock() + (config.delay or self.delay)
    self.duration = config.duration or self.duration
    self.easing = config.easing or self.easing
    
    if self.animationType == "spring" then
        self.spring:setTarget(targetValue)
    end
    
    self.isAnimating = true
    
    if not self.connection then
        self:_startAnimation()
    end
    
    return self
end

function Animation:_startAnimation()
    self.connection = RunService.Heartbeat:Connect(function(deltaTime)
        self:_update(deltaTime)
    end)
end

function Animation:_update(deltaTime)
    if not self.isAnimating then return end
    
    local now = os.clock()
    
    if now < self.startTime then return end  -- Delay not finished
    
    if self.animationType == "spring" then
        -- Spring animation
        self.currentValue = self.spring:update(deltaTime)
        
        if self.spring:isAtRest() then
            self.isAnimating = false
            if self.onComplete then
                self.onComplete(self.currentValue)
            end
        end
    else
        -- Tween animation
        local elapsed = now - self.startTime
        local progress = math.min(elapsed / self.duration, 1)
        local easedProgress = self.easing(progress)
        
        self.currentValue = self.startValue + (self.targetValue - self.startValue) * easedProgress
        
        if progress >= 1 then
            self.currentValue = self.targetValue
            self.isAnimating = false
            if self.onComplete then
                self.onComplete(self.currentValue)
            end
        end
    end
    
    if self.onUpdate then
        self.onUpdate(self.currentValue)
    end
    
    -- Update children
    for _, child in ipairs(self.children) do
        child:_update(deltaTime)
    end
    
    -- Stop connection if done
    if not self.isAnimating and #self.children == 0 then
        self:stop()
    end
end

function Animation:stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.isAnimating = false
end

function Animation:getValue()
    return self.currentValue
end

-- ============================================================================
-- KEYFRAME ANIMATIONS (Multi-step animations with intermediate values)
-- ============================================================================

function Animation.keyframe(instance, propertyName, keyframes, config)
    config = config or {}
    
    -- Keyframes format: { { time = 0, value = ... }, { time = 0.5, value = ... }, { time = 1, value = ... } }
    -- time is normalized 0-1
    
    table.sort(keyframes, function(a, b) return a.time < b.time end)
    
    local anim = Animation.new(keyframes[1].value, config)
    anim.animationType = "keyframe"
    anim.keyframes = keyframes
    anim.propertyName = propertyName
    anim.instance = instance
    
    anim._updateKeyframe = function(progress)
        -- Find current keyframe segment
        local prevFrame, nextFrame
        for i = 1, #keyframes do
            if keyframes[i].time <= progress then
                prevFrame = keyframes[i]
                nextFrame = keyframes[i + 1]
            else
                break
            end
        end
        
        if not nextFrame then
            return prevFrame.value
        end
        
        -- Interpolate between keyframes
        local segmentProgress = (progress - prevFrame.time) / (nextFrame.time - prevFrame.time)
        local easedProgress = anim.easing(segmentProgress)
        
        local prevVal = prevFrame.value
        local nextVal = nextFrame.value
        
        -- Type-specific interpolation
        if typeof(prevVal) == "UDim2" then
            return UDim2.new(
                prevVal.X.Scale + (nextVal.X.Scale - prevVal.X.Scale) * easedProgress,
                prevVal.X.Offset + (nextVal.X.Offset - prevVal.X.Offset) * easedProgress,
                prevVal.Y.Scale + (nextVal.Y.Scale - prevVal.Y.Scale) * easedProgress,
                prevVal.Y.Offset + (nextVal.Y.Offset - prevVal.Y.Offset) * easedProgress
            )
        elseif typeof(prevVal) == "Color3" then
            return Color3.new(
                prevVal.R + (nextVal.R - prevVal.R) * easedProgress,
                prevVal.G + (nextVal.G - prevVal.G) * easedProgress,
                prevVal.B + (nextVal.B - prevVal.B) * easedProgress
            )
        elseif typeof(prevVal) == "Vector3" then
            return Vector3.new(
                prevVal.X + (nextVal.X - prevVal.X) * easedProgress,
                prevVal.Y + (nextVal.Y - prevVal.Y) * easedProgress,
                prevVal.Z + (nextVal.Z - prevVal.Z) * easedProgress
            )
        elseif type(prevVal) == "number" then
            return prevVal + (nextVal - prevVal) * easedProgress
        end
        
        return nextVal
    end
    
    anim.onUpdate = function(value)
        -- value is actually progress for keyframe animations
        if anim.instance and anim.propertyName and anim._updateKeyframe then
            anim.instance[anim.propertyName] = anim._updateKeyframe(value)
        end
    end
    
    -- Start animation
    anim.startValue = 0
    anim.targetValue = 1
    anim:to(1, config)
    
    return anim
end

-- ============================================================================
-- PATH ANIMATIONS (Bezier curves, circular paths)
-- ============================================================================

local PathAnimation = {}

-- Cubic Bezier curve interpolation
function PathAnimation.bezier(p0, p1, p2, p3, t)
    local mt = 1 - t
    return p0 * mt * mt * mt 
         + p1 * 3 * mt * mt * t
         + p2 * 3 * mt * t * t
         + p3 * t * t * t
end

function Animation.animateAlongBezier(instance, controlPoints, config)
    config = config or {}
    
    -- controlPoints = { start, control1, control2, end }
    local keyframes = {}
    local steps = config.steps or 20
    
    for i = 0, steps do
        local t = i / steps
        local pos = PathAnimation.bezier(
            controlPoints[1],
            controlPoints[2],
            controlPoints[3],
            controlPoints[4],
            t
        )
        table.insert(keyframes, { time = t, value = pos })
    end
    
    return Animation.keyframe(instance, "Position", keyframes, config)
end

function Animation.animateAlongCircle(instance, center, radius, startAngle, endAngle, config)
    config = config or {}
    
    local keyframes = {}
    local steps = config.steps or 20
    
    for i = 0, steps do
        local t = i / steps
        local angle = math.rad(startAngle + (endAngle - startAngle) * t)
        local x = center.X.Offset + radius * math.cos(angle)
        local y = center.Y.Offset + radius * math.sin(angle)
        
        local pos = UDim2.new(center.X.Scale, x, center.Y.Scale, y)
        table.insert(keyframes, { time = t, value = pos })
    end
    
    return Animation.keyframe(instance, "Position", keyframes, config)
end

-- ============================================================================
-- COMPOSITE ANIMATIONS (parallel, sequence, stagger)
-- ============================================================================

function Animation:parallel(...)
    local animations = {...}
    for _, anim in ipairs(animations) do
        table.insert(self.children, anim)
        anim:to(anim.targetValue)
    end
    return self
end

function Animation:sequence(...)
    local animations = {...}
    local totalDelay = 0
    
    for _, anim in ipairs(animations) do
        anim.delay = totalDelay
        totalDelay = totalDelay + anim.duration
        table.insert(self.children, anim)
    end
    
    for _, anim in ipairs(animations) do
        anim:to(anim.targetValue)
    end
    
    return self
end

function Animation:stagger(animations, staggerDelay)
    staggerDelay = staggerDelay or 0.05
    local delay = 0
    
    for _, anim in ipairs(animations) do
        anim.delay = delay
        delay = delay + staggerDelay
        table.insert(self.children, anim)
        anim:to(anim.targetValue)
    end
    
    return self
end

-- ============================================================================
-- ANIMATION TIMELINE (Complex choreographed animations)
-- ============================================================================

local Timeline = {}
Timeline.__index = Timeline

function Animation.createTimeline()
    return setmetatable({
        tracks = {},
        duration = 0,
        isPlaying = false,
        startTime = nil,
        connection = nil,
    }, Timeline)
end

function Timeline:add(animation, startTime)
    table.insert(self.tracks, {
        anim = animation,
        startTime = startTime or 0,
    })
    
    local endTime = startTime + animation.duration
    if endTime > self.duration then
        self.duration = endTime
    end
    
    return self
end

function Timeline:play()
    self.isPlaying = true
    self.startTime = os.clock()
    
    self.connection = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - self.startTime
        
        for _, track in ipairs(self.tracks) do
            local trackElapsed = elapsed - track.startTime
            if trackElapsed >= 0 and trackElapsed <= track.anim.duration then
                if not track.started then
                    track.anim:to(track.anim.targetValue)
                    track.started = true
                end
            end
        end
        
        if elapsed >= self.duration then
            self:stop()
        end
    end)
    
    return self
end

function Timeline:stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.isPlaying = false
end

Animation.Timeline = Timeline

-- ============================================================================
-- GESTURE ANIMATIONS (Touch/drag interactions)
-- ============================================================================

local Gesture = {}
Gesture.__index = Gesture

function Animation.createGestureHandler(instance)
    local self = setmetatable({
        instance = instance,
        isDragging = false,
        startPos = nil,
        originalPos = nil,
        connections = {},
        
        -- Callbacks
        onSwipeLeft = nil,
        onSwipeRight = nil,
        onSwipeUp = nil,
        onSwipeDown = nil,
        onDragStart = nil,
        onDragEnd = nil,
        onDrag = nil,
        
        -- Config
        swipeThreshold = 50,
        dragEnabled = false,
        swipeEnabled = true,
    }, Gesture)
    
    -- Input detection
    self.connections.inputBegan = instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_handleInputBegan(input)
        end
    end)
    
    self.connections.inputChanged = instance.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseMovement then
            self:_handleInputChanged(input)
        end
    end)
    
    self.connections.inputEnded = instance.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_handleInputEnded(input)
        end
    end)
    
    return self
end

function Gesture:_handleInputBegan(input)
    self.isDragging = true
    self.startPos = Vector2.new(input.Position.X, input.Position.Y)
    self.originalPos = self.instance.Position
    
    if self.onDragStart then
        self.onDragStart(self.startPos)
    end
end

function Gesture:_handleInputChanged(input)
    if not self.isDragging then return end
    
    local currentPos = Vector2.new(input.Position.X, input.Position.Y)
    local delta = currentPos - self.startPos
    
    if self.dragEnabled then
        self.instance.Position = self.originalPos + UDim2.new(0, delta.X, 0, delta.Y)
        
        if self.onDrag then
            self.onDrag(delta)
        end
    end
end

function Gesture:_handleInputEnded(input)
    if not self.isDragging then return end
    
    local endPos = Vector2.new(input.Position.X, input.Position.Y)
    local delta = endPos - self.startPos
    
    self.isDragging = false
    
    if self.onDragEnd then
        self.onDragEnd(delta)
    end
    
    -- Detect swipe gestures
    if self.swipeEnabled then
        if math.abs(delta.X) > math.abs(delta.Y) then
            -- Horizontal swipe
            if delta.X > self.swipeThreshold and self.onSwipeRight then
                self.onSwipeRight(delta)
            elseif delta.X < -self.swipeThreshold and self.onSwipeLeft then
                self.onSwipeLeft(delta)
            end
        else
            -- Vertical swipe
            if delta.Y > self.swipeThreshold and self.onSwipeDown then
                self.onSwipeDown(delta)
            elseif delta.Y < -self.swipeThreshold and self.onSwipeUp then
                self.onSwipeUp(delta)
            end
        end
    end
    
    -- Spring back if dragging was enabled
    if self.dragEnabled then
        Animation.animateUDim2(self.instance, "Position", self.originalPos, {
            type = "spring",
            spring = { tension = 200, friction = 20 }
        })
    end
end

function Gesture:destroy()
    for _, conn in pairs(self.connections) do
        conn:Disconnect()
    end
    self.connections = {}
end

Animation.Gesture = Gesture

-- ============================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Batch property updates to reduce render cycles
local PropertyBatch = {}
PropertyBatch.__index = PropertyBatch

function Animation.createPropertyBatch()
    return setmetatable({
        pending = {},
        scheduled = false,
    }, PropertyBatch)
end

function PropertyBatch:set(instance, property, value)
    if not self.pending[instance] then
        self.pending[instance] = {}
    end
    self.pending[instance][property] = value
    
    if not self.scheduled then
        self.scheduled = true
        RunService.Heartbeat:Wait()
        self:flush()
    end
end

function PropertyBatch:flush()
    for instance, props in pairs(self.pending) do
        for property, value in pairs(props) do
            instance[property] = value
        end
    end
    self.pending = {}
    self.scheduled = false
end

Animation.PropertyBatch = PropertyBatch

-- Animation pool to reduce garbage collection
local AnimationPool = {}
AnimationPool.__index = AnimationPool

function Animation.createPool(size)
    local pool = setmetatable({
        available = {},
        size = size or 20,
    }, AnimationPool)
    
    -- Pre-allocate animations
    for i = 1, pool.size do
        table.insert(pool.available, Animation.new(0))
    end
    
    return pool
end

function AnimationPool:acquire(initialValue, config)
    local anim = table.remove(self.available)
    if not anim then
        anim = Animation.new(initialValue, config)
    else
        anim.currentValue = initialValue
        anim.targetValue = initialValue
        anim.isAnimating = false
        -- Reapply config
        if config then
            anim.duration = config.duration or anim.duration
            anim.easing = config.easing or anim.easing
            anim.delay = config.delay or 0
        end
    end
    return anim
end

function AnimationPool:release(anim)
    anim:stop()
    if #self.available < self.size then
        table.insert(self.available, anim)
    end
end

Animation.Pool = AnimationPool

-- ============================================================================
-- PROPERTY ANIMATORS (Instance property helpers)
-- ============================================================================

function Animation.animateProperty(instance, propertyName, targetValue, config)
    config = config or {}
    
    local currentValue = instance[propertyName]
    
    -- Handle different types
    local anim
    if typeof(currentValue) == "UDim2" then
        anim = Animation.animateUDim2(instance, propertyName, targetValue, config)
    elseif typeof(currentValue) == "Color3" then
        anim = Animation.animateColor3(instance, propertyName, targetValue, config)
    elseif typeof(currentValue) == "Vector3" then
        anim = Animation.animateVector3(instance, propertyName, targetValue, config)
    elseif type(currentValue) == "number" then
        anim = Animation.new(currentValue, config)
        anim.onUpdate = function(value)
            instance[propertyName] = value
        end
        anim:to(targetValue, config)
    end
    
    return anim
end

function Animation.animateUDim2(instance, propertyName, targetValue, config)
    local current = instance[propertyName]
    
    local xScaleAnim = Animation.new(current.X.Scale, config)
    local xOffsetAnim = Animation.new(current.X.Offset, config)
    local yScaleAnim = Animation.new(current.Y.Scale, config)
    local yOffsetAnim = Animation.new(current.Y.Offset, config)
    
    local function update()
        instance[propertyName] = UDim2.new(
            xScaleAnim:getValue(),
            xOffsetAnim:getValue(),
            yScaleAnim:getValue(),
            yOffsetAnim:getValue()
        )
    end
    
    xScaleAnim.onUpdate = update
    xOffsetAnim.onUpdate = update
    yScaleAnim.onUpdate = update
    yOffsetAnim.onUpdate = update
    
    xScaleAnim:to(targetValue.X.Scale, config)
    xOffsetAnim:to(targetValue.X.Offset, config)
    yScaleAnim:to(targetValue.Y.Scale, config)
    yOffsetAnim:to(targetValue.Y.Offset, config)
    
    return xScaleAnim  -- Return one for control
end

function Animation.animateColor3(instance, propertyName, targetValue, config)
    local current = instance[propertyName]
    
    local rAnim = Animation.new(current.R, config)
    local gAnim = Animation.new(current.G, config)
    local bAnim = Animation.new(current.B, config)
    
    local function update()
        instance[propertyName] = Color3.new(
            rAnim:getValue(),
            gAnim:getValue(),
            bAnim:getValue()
        )
    end
    
    rAnim.onUpdate = update
    gAnim.onUpdate = update
    bAnim.onUpdate = update
    
    rAnim:to(targetValue.R, config)
    gAnim:to(targetValue.G, config)
    bAnim:to(targetValue.B, config)
    
    return rAnim
end

function Animation.animateVector3(instance, propertyName, targetValue, config)
    local current = instance[propertyName]
    
    local xAnim = Animation.new(current.X, config)
    local yAnim = Animation.new(current.Y, config)
    local zAnim = Animation.new(current.Z, config)
    
    local function update()
        instance[propertyName] = Vector3.new(
            xAnim:getValue(),
            yAnim:getValue(),
            zAnim:getValue()
        )
    end
    
    xAnim.onUpdate = update
    yAnim.onUpdate = update
    zAnim.onUpdate = update
    
    xAnim:to(targetValue.X, config)
    yAnim:to(targetValue.Y, config)
    yAnim:to(targetValue.Z, config)
    
    return xAnim
end

-- ============================================================================
-- PRESETS (Common animation patterns)
-- ============================================================================

Animation.Presets = {
    -- Fade
    fadeIn = function(instance, config)
        return Animation.animateProperty(instance, "BackgroundTransparency", 0, config or {
            duration = 0.3,
            easing = Easing.OutQuad
        })
    end,
    
    fadeOut = function(instance, config)
        return Animation.animateProperty(instance, "BackgroundTransparency", 1, config or {
            duration = 0.3,
            easing = Easing.OutQuad
        })
    end,
    
    -- Scale
    scaleIn = function(instance, targetSize, config)
        instance.Size = UDim2.new(0, 0, 0, 0)
        instance.AnchorPoint = Vector2.new(0.5, 0.5)
        return Animation.animateUDim2(instance, "Size", targetSize, config or {
            type = "spring",
            spring = {tension = 200, friction = 20}
        })
    end,
    
    scaleOut = function(instance, config)
        return Animation.animateUDim2(instance, "Size", UDim2.new(0, 0, 0, 0), config or {
            duration = 0.2,
            easing = Easing.InBack
        })
    end,
    
    -- Slide
    slideIn = function(instance, direction, config)
        local viewport = instance.Parent.AbsoluteSize
        local offsets = {
            left = UDim2.new(0, -viewport.X, 0, 0),
            right = UDim2.new(0, viewport.X, 0, 0),
            up = UDim2.new(0, 0, 0, -viewport.Y),
            down = UDim2.new(0, 0, 0, viewport.Y)
        }
        
        local originalPos = instance.Position
        instance.Position = originalPos + offsets[direction]
        
        return Animation.animateUDim2(instance, "Position", originalPos, config or {
            type = "spring",
            spring = {tension = 180, friction = 24}
        })
    end,
    
    -- Bounce
    bounce = function(instance, config)
        return Animation.animateProperty(instance, "Position", instance.Position + UDim2.new(0, 0, 0, -20), {
            duration = 0.4,
            easing = Easing.OutBounce
        })
    end,
    
    -- Shake (proper oscillation with decreasing amplitude)
    shake = function(instance, config)
        config = config or {}
        local original = instance.Position
        local intensity = config.intensity or 10
        local duration = config.duration or 0.4
        local oscillations = config.oscillations or 4
        
        local keyframes = {}
        for i = 0, oscillations do
            local t = i / oscillations
            local amplitude = intensity * (1 - t)  -- Decrease amplitude over time
            local direction = (i % 2 == 0) and 1 or -1
            table.insert(keyframes, {
                time = t,
                value = original + UDim2.new(0, amplitude * direction, 0, 0)
            })
        end
        table.insert(keyframes, { time = 1, value = original })
        
        return Animation.keyframe(instance, "Position", keyframes, {
            duration = duration,
            easing = Easing.Linear
        })
    end,
    
    -- Pulse (scale up and down)
    pulse = function(instance, config)
        config = config or {}
        local originalSize = instance.Size
        local scale = config.scale or 1.1
        local duration = config.duration or 0.3
        
        local targetSize = UDim2.new(
            originalSize.X.Scale * scale,
            originalSize.X.Offset * scale,
            originalSize.Y.Scale * scale,
            originalSize.Y.Offset * scale
        )
        
        local keyframes = {
            { time = 0, value = originalSize },
            { time = 0.5, value = targetSize },
            { time = 1, value = originalSize }
        }
        
        return Animation.keyframe(instance, "Size", keyframes, {
            duration = duration,
            easing = Easing.InOutQuad
        })
    end,
    
    -- Rotate (2D rotation)
    rotate = function(instance, degrees, config)
        config = config or {}
        local originalRotation = instance.Rotation
        local targetRotation = originalRotation + degrees
        
        return Animation.animateProperty(instance, "Rotation", targetRotation, config or {
            duration = 0.5,
            easing = Easing.OutQuad
        })
    end,
    
    -- Spin (continuous rotation)
    spin = function(instance, config)
        config = config or {}
        local rotations = config.rotations or 1
        local duration = config.duration or 1
        
        local keyframes = {}
        local steps = 8
        for i = 0, steps do
            local t = i / steps
            table.insert(keyframes, {
                time = t,
                value = 360 * rotations * t
            })
        end
        
        return Animation.keyframe(instance, "Rotation", keyframes, {
            duration = duration,
            easing = Easing.Linear
        })
    end,
    
    -- Wave (smooth wave motion)
    wave = function(instance, config)
        config = config or {}
        local original = instance.Position
        local amplitude = config.amplitude or 20
        local frequency = config.frequency or 2
        local duration = config.duration or 2
        
        local keyframes = {}
        local steps = 30
        for i = 0, steps do
            local t = i / steps
            local offset = amplitude * math.sin(t * frequency * 2 * math.pi)
            table.insert(keyframes, {
                time = t,
                value = original + UDim2.new(0, 0, 0, offset)
            })
        end
        
        return Animation.keyframe(instance, "Position", keyframes, {
            duration = duration,
            easing = Easing.Linear
        })
    end,
    
    -- Glow (pulsing transparency for glow effect)
    glow = function(instance, config)
        config = config or {}
        local minTransparency = config.minTransparency or 0
        local maxTransparency = config.maxTransparency or 0.5
        local duration = config.duration or 1
        
        local keyframes = {
            { time = 0, value = minTransparency },
            { time = 0.5, value = maxTransparency },
            { time = 1, value = minTransparency }
        }
        
        return Animation.keyframe(instance, "BackgroundTransparency", keyframes, {
            duration = duration,
            easing = Easing.InOutSine
        })
    end,
}

return Animation
