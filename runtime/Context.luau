local Context = {}
Context.__index = Context

-- Context stack for nested providers
local contextStack = {}

function Context.new(defaultValue)
    return setmetatable({
        defaultValue = defaultValue,
        currentValue = defaultValue,
    }, Context)
end

function Context:Provider(props)
    local children = props.children or {}
    local value = props.value or self.defaultValue
    
    -- Push current context value to stack
    table.insert(contextStack, {
        context = self,
        value = self.currentValue,
    })
    
    -- Set new context value
    self.currentValue = value
    
    -- Render children
    local result = children[1] or {}
    
    -- Pop context value from stack
    local stackEntry = table.remove(contextStack)
    if stackEntry then
        stackEntry.context.currentValue = stackEntry.value
    end
    
    return result
end

function Context:Consumer(props)
    local children = props.children or {}
    
    -- Find current context value in stack
    local currentValue = self.defaultValue
    for i = #contextStack, 1, -1 do
        local entry = contextStack[i]
        if entry.context == self then
            currentValue = entry.value
            break
        end
    end
    
    -- Call children with context value
    if type(children[1]) == "function" then
        return children[1](currentValue)
    end
    
    return children[1] or {}
end

function Context.useContext(context)
    -- Find current context value in stack
    local currentValue = context.defaultValue
    for i = #contextStack, 1, -1 do
        local entry = contextStack[i]
        if entry.context == context then
            currentValue = entry.value
            break
        end
    end
    
    return currentValue
end

return Context
