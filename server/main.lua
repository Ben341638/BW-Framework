-- Main Server File for BW Framework

-- Initialize the framework
BW.ServerCallbacks = {}
BW.Testing = {}

-- Initialize the database
CreateThread(function()
    if BW.DB.Initialize() then
        print("^2[BW Framework] Database initialized successfully.^0")
    else
        print("^1[BW Framework] Failed to initialize database.^0")
    end
end)

-- Player Joined Event
AddEventHandler('playerJoining', function()
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    local name = GetPlayerName(src)
    
    if not license then
        DropPlayer(src, "Could not find license identifier. Please restart FiveM.")
        return
    end
    
    -- Check if player exists in database
    BW.DB.GetPlayer(license, function(result)
        if result then
            -- Player exists, load their data
            BW.Player.Load(src, license, function(player)
                if player then
                    print("^2[BW Framework] Player " .. name .. " loaded successfully.^0")
                else
                    print("^1[BW Framework] Failed to load player " .. name .. ".^0")
                end
            end)
        else
            -- Player doesn't exist, create new player
            BW.Player.Create(src, license, license, name, function(player)
                if player then
                    print("^2[BW Framework] New player " .. name .. " created successfully.^0")
                else
                    print("^1[BW Framework] Failed to create new player " .. name .. ".^0")
                end
            end)
        end
    end)
end)

-- Player Dropped Event
AddEventHandler('playerDropped', function(reason)
    local src = source
    local player = BW.Player.Get(src)
    
    if player then
        -- Save player data
        player.Functions.Save()
        
        -- Remove player from memory
        BW.Players[src] = nil
        
        print("^2[BW Framework] Player " .. GetPlayerName(src) .. " saved and removed from memory.^0")
    end
end)

-- Register Server Callback
RegisterServerEvent('bw:Server:TriggerCallback')
AddEventHandler('bw:Server:TriggerCallback', function(name, ...)
    local src = source
    BW.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('bw:Client:CallbackResponse', src, name, ...)
    end, ...)
end)

-- Create Server Callback
BW.Functions.CreateCallback = function(name, cb)
    BW.ServerCallbacks[name] = cb
end

-- Trigger Server Callback
BW.Functions.TriggerCallback = function(name, source, cb, ...)
    if BW.ServerCallbacks[name] then
        BW.ServerCallbacks[name](source, cb, ...)
    else
        print("^1[BW Framework] Server callback " .. name .. " does not exist.^0")
    end
end

-- Add Command to Get Framework Object (for development)
RegisterCommand('getfw', function(source, args, rawCommand)
    if source == 0 then
        local fw = {
            Players = BW.Players,
            Player = BW.Player,
            Functions = BW.Functions,
            Config = BW.Config,
            Shared = BW.Shared,
            ServerCallbacks = BW.ServerCallbacks
        }
        print(json.encode(fw, {indent = true}))
    end
end, true)

-- Save all players periodically
CreateThread(function()
    while true do
        Wait(900000) -- 15 minutes
        BW.Player.SaveAll()
        print("^2[BW Framework] All players saved.^0")
    end
end)

-- Register some basic callbacks
BW.Functions.CreateCallback('bw:GetPlayerData', function(source, cb)
    local player = BW.Player.Get(source)
    if player then
        cb(player.PlayerData)
    else
        cb(nil)
    end
end)

BW.Functions.CreateCallback('bw:GetOtherPlayerData', function(source, cb, target)
    local player = BW.Player.Get(target)
    if player then
        cb(player.PlayerData)
    else
        cb(nil)
    end
end)

BW.Functions.CreateCallback('bw:GetConfig', function(source, cb)
    cb(Config)
end)

-- Print initialization message
print("^2[BW Framework] Server initialized successfully.^0")
print("^3[BW Framework] Version: 1.0.0^0")
print("^3[BW Framework] Created by BW Framework Team^0")