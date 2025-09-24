-- Commands System for BW Framework
BW.Commands = {}
BW.CommandsSuggestions = {}

-- Register a command
function BW.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    -- Default values
    help = help or ""
    arguments = arguments or {}
    argsrequired = argsrequired or false
    permission = permission or "user"
    
    -- Register command with the server
    RegisterCommand(name, function(source, args, rawCommand)
        -- Check if source is console
        if source == 0 then
            -- Console can execute any command
            callback(source, args, rawCommand)
            return
        end
        
        -- Check player permission
        local Player = BW.Player.GetPlayer(source)
        if not Player then return end
        
        local hasPermission = false
        if permission == "user" then
            hasPermission = true
        elseif permission == "admin" then
            if Player.metadata.admin then
                hasPermission = true
            end
        end
        
        if not hasPermission then
            TriggerClientEvent('BW:Client:Notify', source, "You don't have permission to use this command", "error")
            return
        end
        
        -- Check if required arguments are provided
        if argsrequired and #args < #arguments then
            TriggerClientEvent('BW:Client:Notify', source, "Not enough arguments provided", "error")
            local syntax = "/"..name
            for i=1, #arguments do
                syntax = syntax .. " [" .. arguments[i].name .. "]"
            end
            TriggerClientEvent('BW:Client:Notify', source, "Syntax: " .. syntax, "error")
            return
        end
        
        -- Execute command callback
        callback(source, args, rawCommand)
    end, false)
    
    -- Add command suggestion
    local params = {}
    for i=1, #arguments do
        table.insert(params, {
            name = arguments[i].name,
            help = arguments[i].help or ""
        })
    end
    
    TriggerClientEvent('chat:addSuggestion', -1, '/' .. name, help, params)
    table.insert(BW.CommandsSuggestions, {
        name = name,
        help = help,
        params = params
    })
end

-- Remove a command
function BW.Commands.Remove(name)
    -- Remove command suggestion
    TriggerClientEvent('chat:removeSuggestion', -1, '/' .. name)
    
    -- Find and remove from suggestions table
    for i=1, #BW.CommandsSuggestions do
        if BW.CommandsSuggestions[i].name == name then
            table.remove(BW.CommandsSuggestions, i)
            break
        end
    end
end

-- Refresh command suggestions for a player
function BW.Commands.RefreshSuggestions(source)
    for i=1, #BW.CommandsSuggestions do
        TriggerClientEvent('chat:addSuggestion', source, '/' .. BW.CommandsSuggestions[i].name, BW.CommandsSuggestions[i].help, BW.CommandsSuggestions[i].params)
    end
end

-- Register default commands
Citizen.CreateThread(function()
    -- Help command
    BW.Commands.Add("help", "Show available commands", {}, false, function(source, args, rawCommand)
        TriggerClientEvent('BW:Client:Notify', source, "Available commands:", "primary")
        for i=1, #BW.CommandsSuggestions do
            TriggerClientEvent('BW:Client:Notify', source, "/" .. BW.CommandsSuggestions[i].name .. " - " .. BW.CommandsSuggestions[i].help, "primary")
        end
    end)
    
    -- ID command
    BW.Commands.Add("id", "Show your server ID", {}, false, function(source, args, rawCommand)
        TriggerClientEvent('BW:Client:Notify', source, "Your ID: " .. source, "primary")
    end)
    
    -- Admin commands
    BW.Commands.Add("setadmin", "Set admin status for a player", {
        {name = "id", help = "Player ID"},
        {name = "level", help = "Admin level (1-5)"}
    }, true, function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        local level = tonumber(args[2])
        
        if not targetId or not level then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid arguments", "error")
            return
        end
        
        if level < 1 or level > 5 then
            TriggerClientEvent('BW:Client:Notify', source, "Admin level must be between 1 and 5", "error")
            return
        end
        
        local targetPlayer = BW.Player.GetPlayer(targetId)
        if not targetPlayer then
            TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
            return
        end
        
        BW.Player.SetMetaData(targetId, "admin", level)
        TriggerClientEvent('BW:Client:Notify', source, "Set admin level " .. level .. " for " .. targetPlayer.name, "success")
        TriggerClientEvent('BW:Client:Notify', targetId, "You are now admin level " .. level, "success")
    end, "admin")
    
    -- Teleport command
    BW.Commands.Add("tp", "Teleport to coordinates or player", {
        {name = "x/id", help = "X coordinate or player ID"},
        {name = "y", help = "Y coordinate (optional)"},
        {name = "z", help = "Z coordinate (optional)"}
    }, true, function(source, args, rawCommand)
        local x = tonumber(args[1])
        
        if x then
            -- Teleport to coordinates
            if not args[2] or not args[3] then
                TriggerClientEvent('BW:Client:Notify', source, "Missing coordinates", "error")
                return
            end
            
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            
            if not y or not z then
                TriggerClientEvent('BW:Client:Notify', source, "Invalid coordinates", "error")
                return
            end
            
            TriggerClientEvent('BW:Client:Teleport', source, x, y, z)
            TriggerClientEvent('BW:Client:Notify', source, "Teleported to coordinates", "success")
        else
            -- Teleport to player
            local targetId = tonumber(args[1])
            if not targetId then
                TriggerClientEvent('BW:Client:Notify', source, "Invalid player ID", "error")
                return
            end
            
            local targetPlayer = BW.Player.GetPlayer(targetId)
            if not targetPlayer then
                TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
                return
            end
            
            TriggerClientEvent('BW:Client:TeleportToPlayer', source, targetId)
            TriggerClientEvent('BW:Client:Notify', source, "Teleported to " .. targetPlayer.name, "success")
        end
    end, "admin")
    
    -- Give money command
    BW.Commands.Add("givemoney", "Give money to a player", {
        {name = "id", help = "Player ID"},
        {name = "type", help = "Money type (cash, bank, crypto)"},
        {name = "amount", help = "Amount to give"}
    }, true, function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        local moneyType = args[2]
        local amount = tonumber(args[3])
        
        if not targetId or not moneyType or not amount then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid arguments", "error")
            return
        end
        
        if moneyType ~= "cash" and moneyType ~= "bank" and moneyType ~= "crypto" then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid money type. Use cash, bank, or crypto", "error")
            return
        end
        
        if amount <= 0 then
            TriggerClientEvent('BW:Client:Notify', source, "Amount must be positive", "error")
            return
        end
        
        local targetPlayer = BW.Player.GetPlayer(targetId)
        if not targetPlayer then
            TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
            return
        end
        
        BW.Player.AddMoney(targetId, moneyType, amount, "Admin command")
        TriggerClientEvent('BW:Client:Notify', source, "Gave " .. amount .. " " .. moneyType .. " to " .. targetPlayer.name, "success")
        TriggerClientEvent('BW:Client:Notify', targetId, "Received " .. amount .. " " .. moneyType .. " from admin", "success")
    end, "admin")
    
    -- Set job command
    BW.Commands.Add("setjob", "Set job for a player", {
        {name = "id", help = "Player ID"},
        {name = "job", help = "Job name"},
        {name = "grade", help = "Job grade"}
    }, true, function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        local job = args[2]
        local grade = tonumber(args[3])
        
        if not targetId or not job or not grade then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid arguments", "error")
            return
        end
        
        local targetPlayer = BW.Player.GetPlayer(targetId)
        if not targetPlayer then
            TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
            return
        end
        
        if not BW.Config.Jobs[job] then
            TriggerClientEvent('BW:Client:Notify', source, "Job not found", "error")
            return
        end
        
        if not BW.Config.Jobs[job].grades[grade] then
            TriggerClientEvent('BW:Client:Notify', source, "Job grade not found", "error")
            return
        end
        
        BW.Player.SetJob(targetId, job, grade)
        TriggerClientEvent('BW:Client:Notify', source, "Set job " .. job .. " (grade " .. grade .. ") for " .. targetPlayer.name, "success")
        TriggerClientEvent('BW:Client:Notify', targetId, "Your job was set to " .. BW.Config.Jobs[job].label .. " (grade " .. grade .. ")", "success")
    end, "admin")
    
    -- Set gang command
    BW.Commands.Add("setgang", "Set gang for a player", {
        {name = "id", help = "Player ID"},
        {name = "gang", help = "Gang name"},
        {name = "grade", help = "Gang grade"}
    }, true, function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        local gang = args[2]
        local grade = tonumber(args[3])
        
        if not targetId or not gang or not grade then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid arguments", "error")
            return
        end
        
        local targetPlayer = BW.Player.GetPlayer(targetId)
        if not targetPlayer then
            TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
            return
        end
        
        if not BW.Config.Gangs[gang] then
            TriggerClientEvent('BW:Client:Notify', source, "Gang not found", "error")
            return
        end
        
        if not BW.Config.Gangs[gang].grades[grade] then
            TriggerClientEvent('BW:Client:Notify', source, "Gang grade not found", "error")
            return
        end
        
        BW.Player.SetGang(targetId, gang, grade)
        TriggerClientEvent('BW:Client:Notify', source, "Set gang " .. gang .. " (grade " .. grade .. ") for " .. targetPlayer.name, "success")
        TriggerClientEvent('BW:Client:Notify', targetId, "Your gang was set to " .. BW.Config.Gangs[gang].label .. " (grade " .. grade .. ")", "success")
    end, "admin")
    
    -- Revive command
    BW.Commands.Add("revive", "Revive a player", {
        {name = "id", help = "Player ID (optional)"}
    }, false, function(source, args, rawCommand)
        local targetId = args[1] and tonumber(args[1]) or source
        
        local targetPlayer = BW.Player.GetPlayer(targetId)
        if not targetPlayer then
            TriggerClientEvent('BW:Client:Notify', source, "Player not found", "error")
            return
        end
        
        BW.Player.SetMetaData(targetId, "isdead", false)
        BW.Player.SetMetaData(targetId, "inlaststand", false)
        TriggerClientEvent('BW:Client:Revive', targetId)
        
        if source == targetId then
            TriggerClientEvent('BW:Client:Notify', source, "You revived yourself", "success")
        else
            TriggerClientEvent('BW:Client:Notify', source, "You revived " .. targetPlayer.name, "success")
            TriggerClientEvent('BW:Client:Notify', targetId, "You were revived by an admin", "success")
        end
    end, "admin")
    
    -- Announce command
    BW.Commands.Add("announce", "Make a server announcement", {
        {name = "message", help = "Announcement message"}
    }, true, function(source, args, rawCommand)
        local message = table.concat(args, " ")
        
        TriggerClientEvent('BW:Client:Announce', -1, message)
        print("^3[SERVER ANNOUNCEMENT] " .. message .. "^0")
    end, "admin")
    
    -- Weather command
    BW.Commands.Add("weather", "Change the weather", {
        {name = "type", help = "Weather type (clear, extrasunny, clouds, overcast, rain, thunder, fog, snow, blizzard, snowlight, xmas)"}
    }, true, function(source, args, rawCommand)
        local weather = args[1]
        
        local validWeathers = {
            "clear", "extrasunny", "clouds", "overcast", "rain", 
            "thunder", "fog", "snow", "blizzard", "snowlight", "xmas"
        }
        
        local isValid = false
        for i=1, #validWeathers do
            if validWeathers[i] == weather then
                isValid = true
                break
            end
        end
        
        if not isValid then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid weather type", "error")
            return
        end
        
        TriggerClientEvent('BW:Client:SetWeather', -1, weather)
        TriggerClientEvent('BW:Client:Notify', source, "Weather set to " .. weather, "success")
    end, "admin")
    
    -- Time command
    BW.Commands.Add("time", "Change the time", {
        {name = "hour", help = "Hour (0-23)"},
        {name = "minute", help = "Minute (0-59)"}
    }, true, function(source, args, rawCommand)
        local hour = tonumber(args[1])
        local minute = tonumber(args[2])
        
        if not hour or not minute then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid arguments", "error")
            return
        end
        
        if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
            TriggerClientEvent('BW:Client:Notify', source, "Invalid time values", "error")
            return
        end
        
        TriggerClientEvent('BW:Client:SetTime', -1, hour, minute)
        TriggerClientEvent('BW:Client:Notify', source, "Time set to " .. hour .. ":" .. (minute < 10 and "0" or "") .. minute, "success")
    end, "admin")
    
    -- Car command
    BW.Commands.Add("car", "Spawn a vehicle", {
        {name = "model", help = "Vehicle model name"}
    }, true, function(source, args, rawCommand)
        local model = args[1]
        
        TriggerClientEvent('BW:Client:SpawnVehicle', source, model)
    end, "admin")
    
    -- Fix command
    BW.Commands.Add("fix", "Fix current vehicle", {}, false, function(source, args, rawCommand)
        TriggerClientEvent('BW:Client:FixVehicle', source)
    end, "admin")
    
    -- DV command (Delete Vehicle)
    BW.Commands.Add("dv", "Delete current or nearby vehicle", {}, false, function(source, args, rawCommand)
        TriggerClientEvent('BW:Client:DeleteVehicle', source)
    end, "admin")
    
    print("^2[BW Framework] Commands initialized successfully.^0")
end)

-- Add event handler for player joining to refresh command suggestions
AddEventHandler('playerJoining', function()
    local src = source
    Citizen.Wait(5000) -- Wait for player to fully load
    BW.Commands.RefreshSuggestions(src)
end)

-- Export functions
exports('AddCommand', function(name, help, arguments, argsrequired, callback, permission)
    BW.Commands.Add(name, help, arguments, argsrequired, callback, permission)
end)

exports('RemoveCommand', function(name)
    BW.Commands.Remove(name)
end)