local DataFetching = {}
DataFetching.__index = DataFetching

-- Query cache
local queryCache = {}
local cacheConfig = {
    defaultTTL = 300, -- 5 minutes
    maxSize = 100,
}

-- Query client
local QueryClient = {}

function QueryClient.new()
    local self = setmetatable({
        cache = {},
        listeners = {},
    }, QueryClient)
    return self
end

function QueryClient:getQueryData(key)
    local entry = self.cache[key]
    if entry then
        -- Check if cache is still valid
        if tick() - entry.timestamp < (entry.ttl or cacheConfig.defaultTTL) then
            return entry.data
        else
            -- Cache expired
            self.cache[key] = nil
        end
    end
    return nil
end

function QueryClient:setQueryData(key, data, ttl)
    ttl = ttl or cacheConfig.defaultTTL
    
    -- Enforce cache size limit
    if self.cacheSize() >= cacheConfig.maxSize then
        self:evictOldest()
    end
    
    self.cache[key] = {
        data = data,
        timestamp = tick(),
        ttl = ttl,
    }
    
    self:notifyListeners(key, data)
end

function QueryClient:invalidateQuery(key)
    self.cache[key] = nil
    self:notifyListeners(key, nil)
end

function QueryClient:invalidateQueries(keys)
    for _, key in ipairs(keys) do
        self:invalidateQuery(key)
    end
end

function QueryClient:subscribe(key, callback)
    if not self.listeners[key] then
        self.listeners[key] = {}
    end
    table.insert(self.listeners[key], callback)
    
    return function()
        for i, listener in ipairs(self.listeners[key]) do
            if listener == callback then
                table.remove(self.listeners[key], i)
                break
            end
        end
    end
end

function QueryClient:notifyListeners(key, data)
    if self.listeners[key] then
        for _, callback in ipairs(self.listeners[key]) do
            callback(data)
        end
    end
end

function QueryClient:cacheSize()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    return count
end

function QueryClient:evictOldest()
    local oldestKey = nil
    local oldestTime = math.huge
    
    for key, entry in pairs(self.cache) do
        if entry.timestamp < oldestTime then
            oldestTime = entry.timestamp
            oldestKey = key
        end
    end
    
    if oldestKey then
        self.cache[oldestKey] = nil
    end
end

-- Global query client instance
local globalQueryClient = QueryClient.new()

function DataFetching.getQueryClient()
    return globalQueryClient
end

-- useQuery hook
function DataFetching.useQuery(key, fetcher, options)
    options = options or {}
    local staleTime = options.staleTime or 0
    local cacheTime = options.cacheTime or cacheConfig.defaultTTL
    
    local state = {
        data = globalQueryClient:getQueryData(key),
        error = nil,
        isLoading = false,
    }
    
    if not state.data or (tick() - (state.data._timestamp or 0) > staleTime) then
        state.isLoading = true
        
        spawn(function()
            local success, data = pcall(fetcher)
            
            if success then
                data._timestamp = tick()
                globalQueryClient:setQueryData(key, data, cacheTime)
            else
                state.error = data
            end
            
            state.isLoading = false
        end)
    end
    
    return state
end

-- useMutation hook
function DataFetching.useMutation(mutationFn)
    local state = {
        data = nil,
        error = nil,
        isLoading = false,
    }
    
    local function mutate(variables)
        state.isLoading = true
        
        spawn(function()
            local success, data = pcall(mutationFn, variables)
            
            if success then
                state.data = data
            else
                state.error = data
            end
            
            state.isLoading = false
        end)
    end
    
    return {
        data = state.data,
        error = state.error,
        isLoading = state.isLoading,
        mutate = mutate,
    }
end

-- useInfiniteQuery hook for pagination
function DataFetching.useInfiniteQuery(key, fetcher, options)
    options = options or {}
    
    local state = {
        data = {},
        error = nil,
        isLoading = false,
        hasNextPage = true,
    }
    
    local function fetchNextPage()
        if state.isLoading or not state.hasNextPage then
            return
        end
        
        state.isLoading = true
        local pageParam = #state.data + 1
        
        spawn(function()
            local success, data = pcall(fetcher, pageParam)
            
            if success then
                table.insert(state.data, data)
                state.hasNextPage = #data > 0
            else
                state.error = data
            end
            
            state.isLoading = false
        end)
    end
    
    return {
        data = state.data,
        error = state.error,
        isLoading = state.isLoading,
        hasNextPage = state.hasNextPage,
        fetchNextPage = fetchNextPage,
    }
end

-- Prefetching
function DataFetching.prefetchQuery(key, fetcher)
    spawn(function()
        local success, data = pcall(fetcher)
        if success then
            data._timestamp = tick()
            globalQueryClient:setQueryData(key, data)
        end
    end)
end

-- Query invalidation
function DataFetching.invalidateQuery(key)
    globalQueryClient:invalidateQuery(key)
end

function DataFetching.invalidateQueries(keys)
    globalQueryClient:invalidateQueries(keys)
end

-- Cache configuration
function DataFetching.configureCache(config)
    if config.defaultTTL then
        cacheConfig.defaultTTL = config.defaultTTL
    end
    if config.maxSize then
        cacheConfig.maxSize = config.maxSize
    end
end

return DataFetching
