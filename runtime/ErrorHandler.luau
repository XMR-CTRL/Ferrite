local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

-- Error logging with stack traces
local errorLog = {}
local maxLogSize = 100

function ErrorHandler.log(error, stackTrace)
    local entry = {
        error = error,
        stackTrace = stackTrace,
        timestamp = tick(),
    }
    
    table.insert(errorLog, entry)
    
    -- Keep log size manageable
    if #errorLog > maxLogSize then
        table.remove(errorLog, 1)
    end
    
    -- Log to console
    warn("ERROR: " .. tostring(error))
    if stackTrace then
        warn("Stack trace:\n" .. tostring(stackTrace))
    end
end

function ErrorHandler.getRecentErrors(count)
    count = count or 10
    local recent = {}
    local startIdx = math.max(1, #errorLog - count + 1)
    for i = startIdx, #errorLog do
        table.insert(recent, errorLog[i])
    end
    return recent
end

function ErrorHandler.clearLog()
    errorLog = {}
end

function ErrorHandler.createErrorBoundary(props)
    local fallback = props.fallback
    local children = props.children or {}
    
    -- Try to render children with error catching
    local success, result = pcall(function()
        return children[1]
    end)
    
    if success then
        return result
    else
        ErrorHandler.log(result, debug.traceback())
        return fallback or {}
    end
end

-- Crash reporting integration
function ErrorHandler.enableCrashReporting(endpoint)
    ErrorHandler.crashEndpoint = endpoint
    ErrorHandler.crashReportingEnabled = true
end

function ErrorHandler.reportCrash(error, context)
    if not ErrorHandler.crashReportingEnabled then
        return
    end
    
    local http = game:GetService("HttpService")
    
    spawn(function()
        local success = pcall(function()
            http:PostAsync(ErrorHandler.crashEndpoint, http:JSONEncode({
                error = error,
                context = context,
                timestamp = tick(),
                placeId = game.PlaceId,
                jobId = game.JobId,
            }), Enum.HttpContentType.ApplicationJson)
        end)
        
        if not success then
            warn("Failed to report crash to endpoint")
        end
    end)
end

return ErrorHandler
