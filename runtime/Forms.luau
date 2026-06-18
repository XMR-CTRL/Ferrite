local Forms = {}
Forms.__index = Forms

-- Form validation rules
local ValidationRules = {
    required = function(value)
        return value ~= nil and value ~= "", "This field is required"
    end,
    
    minLength = function(value, min)
        if type(value) == "string" and #value < min then
            return string.format("Minimum length is %d", min)
        end
    end,
    
    maxLength = function(value, max)
        if type(value) == "string" and #value > max then
            return string.format("Maximum length is %d", max)
        end
    end,
    
    pattern = function(value, pattern)
        if type(value) == "string" then
            local match = string.match(value, pattern)
            if not match then
                return "Invalid format"
            end
        end
    end,
    
    email = function(value)
        if type(value) == "string" then
            local match = string.match(value, "^[%w%.+-]+@[%w%.+-]+%.%w+$")
            if not match then
                return "Invalid email address"
            end
        end
    end,
    
    number = function(value)
        if type(value) ~= "number" then
            return "Must be a number"
        end
    end,
    
    min = function(value, min)
        if type(value) == "number" and value < min then
            return string.format("Minimum value is %d", min)
        end
    end,
    
    max = function(value, max)
        if type(value) == "number" and value > max then
            return string.format("Maximum value is %d", max)
        end
    end,
}

function Forms.validate(value, rules)
    local errors = {}
    
    for _, rule in ipairs(rules) do
        local ruleType = rule.type
        local ruleValue = rule.value
        
        if ValidationRules[ruleType] then
            local error = ValidationRules[ruleType](value, ruleValue)
            if error then
                table.insert(errors, error)
            end
        elseif rule.custom then
            local error = rule.custom(value)
            if error then
                table.insert(errors, error)
            end
        end
    end
    
    return #errors == 0, errors
end

-- Form state management
function Forms.createForm(initialValues)
    local form = {
        values = {},
        errors = {},
        touched = {},
        isValid = true,
        listeners = {},
    }
    
    -- Initialize values
    for key, value in pairs(initialValues) do
        form.values[key] = value
    end
    
    function form:setValue(key, value)
        self.values[key] = value
        self.touched[key] = true
        self:notifyListeners()
    end
    
    function form:setValues(newValues)
        for key, value in pairs(newValues) do
            self.values[key] = value
            self.touched[key] = true
        end
        self:notifyListeners()
    end
    
    function form:setError(key, error)
        if error then
            self.errors[key] = error
        else
            self.errors[key] = nil
        end
        self:notifyListeners()
    end
    
    function form:clearErrors()
        self.errors = {}
        self:notifyListeners()
    end
    
    function form:validateField(key, rules)
        local value = self.values[key]
        local isValid, errors = Forms.validate(value, rules)
        
        if isValid then
            self.errors[key] = nil
        else
            self.errors[key] = table.concat(errors, ", ")
        end
        
        self:notifyListeners()
        return isValid
    end
    
    function form:validateAll(validationRules)
        local allValid = true
        
        for key, rules in pairs(validationRules) do
            local isValid = self:validateField(key, rules)
            if not isValid then
                allValid = false
            end
        end
        
        self.isValid = allValid
        return allValid
    end
    
    function form:reset()
        for key, value in pairs(initialValues) do
            self.values[key] = value
        end
        self.errors = {}
        self.touched = {}
        self.isValid = true
        self:notifyListeners()
    end
    
    function form:subscribe(callback)
        table.insert(self.listeners, callback)
        callback(self)
        
        return function()
            for i, listener in ipairs(self.listeners) do
                if listener == callback then
                    table.remove(self.listeners, i)
                    break
                end
            end
        end
    end
    
    function form:notifyListeners()
        for _, listener in ipairs(self.listeners) do
            listener(self)
        end
    end
    
    return form
end

-- Form field hook
function Forms.useField(form, name, initialValue)
    local value = form.values[name] or initialValue
    
    local function setValue(newValue)
        form:setValue(name, newValue)
    end
    
    return value, setValue
end

-- Controlled input component
function Forms.ControlledInput(props)
    local form = props.form
    local name = props.name
    local placeholder = props.placeholder or ""
    local type = props.type or "text"
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.PlaceholderText = placeholder
    input.Text = form.values[name] or ""
    input.ClearTextOnFocus = false
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            form:setValue(name, input.Text)
        end
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        form:setValue(name, input.Text)
    end)
    
    return input
end

-- Form submission
function Forms.useFormSubmit(form, onSubmit)
    return function()
        local isValid = form:validateAll(props.validationRules or {})
        
        if isValid then
            onSubmit(form.values)
        else
            -- Show errors
        end
    end
end

return Forms
