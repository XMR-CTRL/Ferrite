local Animations = {}
Animations.__index = Animations

-- Physics-based animation system
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Easing functions
local Easing = {
    Linear = function(t)
        return t
    end,
    
    EaseInQuad = function(t)
        return t * t
    end,
    
    EaseOutQuad = function(t)
        return t * (2 - t)
    end,
    
    EaseInOutQuad = function(t)
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
    end,
    
    EaseInCubic = function(t)
        return t * t * t
    end,
    
    EaseOutCubic = function(t)
        return (t - 1) * (t - 1) * (t - 1) + 1
    end,
    
    EaseInOutCubic = function(t)
        return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
    end,
    
    Spring = function(t, stiffness, damping)
        -- Simplified spring physics
        local frequency = math.sqrt(stiffness)
        local decay = damping
        return (1 - math.exp(-decay * t)) * math.cos(frequency * t)
    end,
}

function Animations.tween(instance, properties, duration, easing)
    easing = easing or Easing.Linear
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    
    return tween
end

function Animations.spring(instance, properties, stiffness, damping)
    stiffness = stiffness or 100
    damping = damping or 10
    
    local startTime = tick()
    local initialProps = {}
    
    for prop, _ in pairs(properties) do
        initialProps[prop] = instance[prop]
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local t = math.min(elapsed / 0.5, 1) -- 0.5 second default duration
        
        local springValue = Easing.Spring(t, stiffness, damping)
        
        for prop, targetValue in pairs(properties) do
            if type(initialProps[prop]) == "number" then
                instance[prop] = initialProps[prop] + (targetValue - initialProps[prop]) * springValue
            elseif typeof(initialProps[prop]) == "UDim2" then
                instance[prop] = UDim2.new(
                    initialProps[prop].X.Scale + (targetValue.X.Scale - initialProps[prop].X.Scale) * springValue,
                    initialProps[prop].X.Offset + (targetValue.X.Offset - initialProps[prop].X.Offset) * springValue,
                    initialProps[prop].Y.Scale + (targetValue.Y.Scale - initialProps[prop].Y.Scale) * springValue,
                    initialProps[prop].Y.Offset + (targetValue.Y.Offset - initialProps[prop].Y.Offset) * springValue
                )
            elseif typeof(initialProps[prop]) == "Color3" then
                instance[prop] = Color3.new(
                    initialProps[prop].R + (targetValue.R - initialProps[prop].R) * springValue,
                    initialProps[prop].G + (targetValue.G - initialProps[prop].G) * springValue,
                    initialProps[prop].B + (targetValue.B - initialProps[prop].B) * springValue
                )
            end
        end
        
        if t >= 1 then
            connection:Disconnect()
        end
    end)
    
    return connection
end

-- Gesture recognition
function Animations.addSwipeGesture(instance, onSwipe, threshold)
    threshold = threshold or 50
    
    local startPos = Vector2.new()
    local isDragging = false
    
    instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startPos = input.Position
            isDragging = true
        end
    end)
    
    instance.InputEnded:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local endPos = input.Position
            local delta = endPos - startPos
            
            if math.abs(delta.X) > threshold then
                local direction = delta.X > 0 and "right" or "left"
                onSwipe(direction, delta)
            elseif math.abs(delta.Y) > threshold then
                local direction = delta.Y > 0 and "down" or "up"
                onSwipe(direction, delta)
            end
            
            isDragging = false
        end
    end)
end

-- Animation sequences
function Animations.sequence(animations)
    local currentDelay = 0
    
    for i, anim in ipairs(animations) do
        spawn(function()
            wait(currentDelay + (anim.delay or 0))
            anim.fn()
        end)
        
        currentDelay = currentDelay + (anim.duration or 0.3)
    end
end

-- Parallel animations
function Animations.parallel(animations)
    for _, anim in ipairs(animations) do
        spawn(function()
            wait(anim.delay or 0)
            anim.fn()
        end)
    end
end

-- Staggered animations for lists
function Animations.stagger(items, animFn, staggerDelay)
    staggerDelay = staggerDelay or 0.05
    
    for i, item in ipairs(items) do
        spawn(function()
            wait(i * staggerDelay)
            animFn(item, i)
        end)
    end
end

return Animations
