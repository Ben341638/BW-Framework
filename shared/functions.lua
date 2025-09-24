-- Shared Functions for BW Framework

-- Item Functions
BW.Functions.CreateUseableItem = function(item, cb)
    BW.Shared.UsableItems[item] = cb
end

BW.Functions.CanUseItem = function(item)
    return BW.Shared.UsableItems[item] ~= nil
end

BW.Functions.UseItem = function(source, item)
    local useItem = BW.Shared.UsableItems[item.name]
    if useItem then
        useItem(source, item)
    end
end

-- Callback System
BW.Functions.CreateCallback = function(name, cb)
    BW.ServerCallbacks[name] = cb
end

BW.Functions.TriggerCallback = function(name, cb, ...)
    BW.ServerCallbacks[name] = cb
    TriggerServerEvent('bw:Server:TriggerCallback', name, ...)
end

-- Notification System
BW.Functions.Notify = function(text, type, length)
    if type == nil then type = 'primary' end
    if length == nil then length = 5000 end
    
    SendNUIMessage({
        action = 'notification',
        type = type,
        text = text,
        length = length
    })
end

-- Progressbar
BW.Functions.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if GetResourceState('progressbar') ~= 'started' then return end
    
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
    }, function(cancelled)
        if not cancelled then
            if onFinish then
                onFinish()
            end
        else
            if onCancel then
                onCancel()
            end
        end
    end)
end

-- Spawn Vehicle
BW.Functions.SpawnVehicle = function(model, cb, coords, isnetworked)
    local model = GetHashKey(model)
    local ped = PlayerPedId()
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    local isnetworked = isnetworked == nil and true or isnetworked
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    
    if cb then
        cb(veh)
    end
    
    return veh
end

-- Delete Vehicle
BW.Functions.DeleteVehicle = function(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

-- Get Vehicle in Direction
BW.Functions.GetVehicleInDirection = function()
    local ped = PlayerPedId()
    local coordA = GetEntityCoords(ped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 10, ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- Draw 3D Text
BW.Functions.DrawText3D = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Get Street Name
BW.Functions.GetStreetLabel = function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossing = GetStreetNameFromHashKey(crossingHash)
    
    if crossing ~= nil and crossing ~= "" then
        return streetName .. " | " .. crossing
    else
        return streetName
    end
end

-- Get Zone Name
BW.Functions.GetZoneName = function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local zoneHash = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneName = GetLabelText(zoneHash)
    
    return zoneName
end

-- Format Money
BW.Functions.FormatMoney = function(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Has Item
BW.Functions.HasItem = function(items, amount)
    local isTable = type(items) == 'table'
    local isArray = isTable and table.type(items) == 'array' or false
    local totalItems = #items
    local count = 0
    local kvIndex = 2
    
    if isTable and not isArray then
        totalItems = 0
        for _ in pairs(items) do totalItems += 1 end
        kvIndex = 1
    end
    
    if isTable then
        for k, v in pairs(items) do
            local itemKV = {k, v}
            local item = BW.Functions.GetPlayerData().items[itemKV[kvIndex]]
            
            if item and ((amount and item.amount >= amount) or (not amount and item.amount > 0)) then
                count += 1
            end
        end
        
        if count == totalItems then
            return true
        end
    else
        local item = BW.Functions.GetPlayerData().items[items]
        
        if item and ((amount and item.amount >= amount) or (not amount and item.amount > 0)) then
            return true
        end
    end
    
    return false
end