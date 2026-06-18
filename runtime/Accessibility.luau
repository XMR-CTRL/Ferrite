local Accessibility = {}
Accessibility.__index = Accessibility

-- ARIA properties storage
local ariaProperties = {}

function Accessibility.setAriaProperty(instance, property, value)
    if not ariaProperties[instance] then
        ariaProperties[instance] = {}
    end
    ariaProperties[instance][property] = value
    
    -- Set as attribute on instance
    instance:SetAttribute("aria-" .. property, tostring(value))
end

function Accessibility.getAriaProperty(instance, property)
    if ariaProperties[instance] then
        return ariaProperties[instance][property]
    end
    return nil
end

-- Keyboard navigation
local focusableElements = {}
local currentFocusIndex = 1

function Accessibility.registerFocusable(instance, index)
    focusableElements[index] = instance
    instance:SetAttribute("tabindex", tostring(index))
end

function Accessibility.unregisterFocusable(index)
    focusableElements[index] = nil
end

function Accessibility.focusNext()
    local nextIndex = currentFocusIndex + 1
    while nextIndex <= #focusableElements do
        local element = focusableElements[nextIndex]
        if element and element.Visible then
            element:CaptureFocus()
            currentFocusIndex = nextIndex
            return
        end
        nextIndex = nextIndex + 1
    end
end

function Accessibility.focusPrevious()
    local prevIndex = currentFocusIndex - 1
    while prevIndex >= 1 do
        local element = focusableElements[prevIndex]
        if element and element.Visible then
            element:CaptureFocus()
            currentFocusIndex = prevIndex
            return
        end
        prevIndex = prevIndex - 1
    end
end

function Accessibility.focusFirst()
    for i, element in pairs(focusableElements) do
        if element and element.Visible then
            element:CaptureFocus()
            currentFocusIndex = i
            return
        end
    end
end

function Accessibility.focusLast()
    for i = #focusableElements, 1, -1 do
        local element = focusableElements[i]
        if element and element.Visible then
            element:CaptureFocus()
            currentFocusIndex = i
            return
        end
    end
end

-- Screen reader announcements
local announcementQueue = {}
local isAnnouncing = false

function Accessibility.announce(message, priority)
    priority = priority or "polite"
    
    table.insert(announcementQueue, {
        message = message,
        priority = priority,
    })
    
    if not isAnnouncing then
        Accessibility.processAnnouncements()
    end
end

function Accessibility.processAnnouncements()
    isAnnouncing = true
    
    while #announcementQueue > 0 do
        local announcement = table.remove(announcementQueue, 1)
        
        -- Create a temporary TextLabel for screen reader
        local screenGui = game:GetService("CoreGui"):FindFirstChild("AccessibilityAnnouncements")
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "AccessibilityAnnouncements"
            screenGui.Parent = game:GetService("CoreGui")
        end
        
        local label = Instance.new("TextLabel")
        label.Name = "Announcement"
        label.Size = UDim2.new(0, 1, 0, 1)
        label.Position = UDim2.new(0, -1000, 0, -1000)
        label.Text = announcement.message
        label.TextSize = 1
        label.BackgroundTransparency = 1
        label.Parent = screenGui
        
        -- Wait for screen reader to pick it up
        wait(0.1)
        label:Destroy()
    end
    
    isAnnouncing = false
end

-- Focus trap for modals
local focusTrapStack = {}

function Accessibility.trapFocus(rootInstance)
    table.insert(focusTrapStack, rootInstance)
end

function Accessibility.releaseFocus()
    table.remove(focusTrapStack)
end

function Accessibility.isFocusTrapped()
    return #focusTrapStack > 0
end

-- Live regions for dynamic content
function Accessibility.createLiveRegion(instance, politeness)
    politeness = politeness or "polite"
    Accessibility.setAriaProperty(instance, "live", politeness)
end

function Accessibility.updateLiveRegion(instance, content)
    Accessibility.setAriaProperty(instance, "label", content)
    Accessibility.announce(content, "polite")
end

-- Role management
function Accessibility.setRole(instance, role)
    Accessibility.setAriaProperty(instance, "role", role)
end

function Accessibility.getRole(instance)
    return Accessibility.getAriaProperty(instance, "role")
end

-- Label management
function Accessibility.setLabel(instance, label)
    Accessibility.setAriaProperty(instance, "label", label)
end

function Accessibility.setLabelledBy(instance, labelId)
    Accessibility.setAriaProperty(instance, "labelledby", labelId)
end

function Accessibility.setDescribedBy(instance, descriptionId)
    Accessibility.setAriaProperty(instance, "describedby", descriptionId)
end

-- Keyboard event handling
local UserInputService = game:GetService("UserInputService")

function Accessibility.setupKeyboardNavigation(rootInstance)
    rootInstance.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Tab then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                Accessibility.focusPrevious()
            else
                Accessibility.focusNext()
            end
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if Accessibility.isFocusTrapped() then
                Accessibility.releaseFocus()
            end
        end
    end)
end

return Accessibility
