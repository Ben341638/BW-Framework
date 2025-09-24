-- Resource Management for BW Framework

BW.Resources = {}
BW.ResourceCallbacks = {}

-- Initialize Resources
BW.Resources.Initialize = function()
    BW.Resources.List = {}
    BW.Resources.LoadedCount = 0
    
    -- Get all resources
    local numResources = GetNumResources()
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        if GetResourceState(resource) == "started" then
            BW.Resources.List[resource] = {
                name = resource,
                version = GetResourceMetadata(resource, "version") or "unknown",
                author = GetResourceMetadata(resource, "author") or "unknown",
                description = GetResourceMetadata(resource, "description") or "No description",
                dependencies = {},
                isFramework = resource == GetCurrentResourceName()
            }
            
            -- Check for dependencies
            local numDependencies = GetNumResourceMetadata(resource, "dependency")
            for j = 0, numDependencies - 1 do
                local dependency = GetResourceMetadata(resource, "dependency", j)
                BW.Resources.List[resource].dependencies[dependency] = true
            end
            
            BW.Resources.LoadedCount = BW.Resources.LoadedCount + 1
        end
    end
    
    print("^2[BW Framework] Loaded " .. BW.Resources.LoadedCount .. " resources.^0")
    return true
end

-- Get Resource
BW.Resources.Get = function(resource)
    if BW.Resources.List[resource] then
        return BW.Resources.List[resource]
    end
    
    return nil
end

-- Get All Resources
BW.Resources.GetAll = function()
    return BW.Resources.List
end

-- Check if Resource is Started
BW.Resources.IsStarted = function(resource)
    return GetResourceState(resource) == "started"
end

-- Register Resource Callback
BW.Resources.RegisterCallback = function(resource, name, cb)
    if not BW.ResourceCallbacks[resource] then
        BW.ResourceCallbacks[resource] = {}
    end
    
    BW.ResourceCallbacks[resource][name] = cb
    print("^2[BW Framework] Registered callback " .. name .. " for resource " .. resource .. ".^0")
end

-- Trigger Resource Callback
BW.Resources.TriggerCallback = function(resource, name, source, cb, ...)
    if BW.ResourceCallbacks[resource] and BW.ResourceCallbacks[resource][name] then
        BW.ResourceCallbacks[resource][name](source, cb, ...)
    else
        print("^1[BW Framework] Resource callback " .. name .. " for resource " .. resource .. " does not exist.^0")
        if cb then
            cb(nil)
        end
    end
end

-- Export Resource Functions
BW.Resources.ExportFunctions = function()
    -- Export core functions to other resources
    exports('GetCoreObject', function()
        return BW
    end)
    
    exports('GetPlayerData', function(source)
        local player = BW.Player.Get(source)
        if player then
            return player.PlayerData
        end
        return nil
    end)
    
    exports('GetConfig', function()
        return Config
    end)
    
    exports('RegisterCallback', function(resource, name, cb)
        BW.Resources.RegisterCallback(resource, name, cb)
    end)
    
    exports('TriggerCallback', function(resource, name, source, cb, ...)
        BW.Resources.TriggerCallback(resource, name, source, cb, ...)
    end)
    
    print("^2[BW Framework] Exported core functions.^0")
end

-- Initialize Resources
CreateThread(function()
    if BW.Resources.Initialize() then
        BW.Resources.ExportFunctions()
    end
end)