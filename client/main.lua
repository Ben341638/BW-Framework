-- Main Client File for BW Framework
BW = {}
BW.PlayerData = {}
BW.Functions = {}
BW.ServerCallbacks = {}
BW.ClientCallbacks = {}
BW.UI = {}
BW.Config = {}
BW.Testing = {}

-- Initialize framework
Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent('BW:Server:PlayerJoined')
            break
        end
        Citizen.Wait(100)
    end
end)

-- Player loaded event handler
RegisterNetEvent('BW:Client:PlayerLoaded')
AddEventHandler('BW:Client:PlayerLoaded', function(PlayerData)
    BW.PlayerData = PlayerData
    
    -- Set player model based on character data
    if BW.PlayerData.charinfo and BW.PlayerData.charinfo.gender then
        local model = BW.PlayerData.charinfo.gender == 0 and 'mp_m_freemode_01' or 'mp_f_freemode_01'
        LoadPlayerModel(model)
    end
    
    -- Set player position
    if BW.PlayerData.position then
        SetEntityCoords(PlayerPedId(), BW.PlayerData.position.x, BW.PlayerData.position.y, BW.PlayerData.position.z)
    end
    
    -- Set player health and armor
    if BW.PlayerData.metadata then
        SetEntityHealth(PlayerPedId(), BW.PlayerData.metadata.health)
        SetPedArmour(PlayerPedId(), BW.PlayerData.metadata.armor)
    end
    
    -- Trigger player loaded event for other resources
    TriggerEvent('BW:Client:OnPlayerLoaded')
    
    -- Start player update thread
    StartPlayerUpdateThread()
end)

-- Update player data
RegisterNetEvent('BW:Client:SetPlayerData')
AddEventHandler('BW:Client:SetPlayerData', function(PlayerData)
    BW.PlayerData = PlayerData
end)

-- Update player money
RegisterNetEvent('BW:Client:UpdateMoney')
AddEventHandler('BW:Client:UpdateMoney', function(moneyType, amount)
    BW.PlayerData.money[moneyType] = amount
end)

-- Update player job
RegisterNetEvent('BW:Client:SetJob')
AddEventHandler('BW:Client:SetJob', function(job)
    BW.PlayerData.job = job
end)

-- Update player gang
RegisterNetEvent('BW:Client:SetGang')
AddEventHandler('BW:Client:SetGang', function(gang)
    BW.PlayerData.gang = gang
end)

-- Update player metadata
RegisterNetEvent('BW:Client:UpdateMetadata')
AddEventHandler('BW:Client:UpdateMetadata', function(metadata)
    BW.PlayerData.metadata = metadata
end)

-- Load player model
function LoadPlayerModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(0)
    end
    
    SetPlayerModel(PlayerId(), GetHashKey(model))
    SetPedDefaultComponentVariation(PlayerPedId())
    SetModelAsNoLongerNeeded(GetHashKey(model))
end

-- Start thread to update player position and other data
function StartPlayerUpdateThread()
    Citizen.CreateThread(function()
        while true do
            if BW.PlayerData and BW.PlayerData.citizenid then
                local position = GetEntityCoords(PlayerPedId())
                local health = GetEntityHealth(PlayerPedId())
                local armor = GetPedArmour(PlayerPedId())
                
                TriggerServerEvent('BW:Server:UpdatePlayerData', {
                    position = {
                        x = position.x,
                        y = position.y,
                        z = position.z
                    },
                    metadata = {
                        health = health,
                        armor = armor
                    }
                })
            end
            Citizen.Wait(10000) -- Update every 10 seconds
        end
    end)
end

-- Callback system
function BW.Functions.TriggerCallback(name, cb, ...)
    BW.ServerCallbacks[name] = cb
    TriggerServerEvent('BW:Server:TriggerCallback', name, ...)
end

RegisterNetEvent('BW:Client:TriggerCallback')
AddEventHandler('BW:Client:TriggerCallback', function(name, ...)
    if BW.ServerCallbacks[name] then
        BW.ServerCallbacks[name](...)
        BW.ServerCallbacks[name] = nil
    end
end)

-- Client callback system
function BW.Functions.CreateCallback(name, cb)
    BW.ClientCallbacks[name] = cb
end

RegisterNetEvent('BW:Client:TriggerClientCallback')
AddEventHandler('BW:Client:TriggerClientCallback', function(name, requestId, ...)
    if BW.ClientCallbacks[name] then
        BW.ClientCallbacks[name](function(...)
            TriggerServerEvent('BW:Server:ClientCallbackResponse', requestId, ...)
        end, ...)
    end
end)

-- Notification system
function BW.Functions.Notify(text, type, length)
    type = type or 'primary'
    length = length or 5000
    
    SendNUIMessage({
        action = 'notification',
        type = type,
        text = text,
        length = length
    })
end

RegisterNetEvent('BW:Client:Notify')
AddEventHandler('BW:Client:Notify', function(text, type, length)
    BW.Functions.Notify(text, type, length)
end)

-- Progress bar
function BW.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if BW.PlayerData.metadata and BW.PlayerData.metadata.isdead and not useWhileDead then
        return
    end
    
    if not name then
        return
    end
    
    SendNUIMessage({
        action = 'progressbar',
        name = name,
        label = label,
        duration = duration
    })
    
    Citizen.CreateThread(function()
        if disableControls then
            DisableControls()
        end
        
        if animation then
            if animation.type == "anim" then
                RequestAnimDict(animation.dict)
                while not HasAnimDictLoaded(animation.dict) do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(PlayerPedId(), animation.dict, animation.anim, 8.0, 1.0, -1, animation.flags or 49, 0, false, false, false)
            elseif animation.type == "scenario" then
                TaskStartScenarioInPlace(PlayerPedId(), animation.scenario, 0, true)
            end
        end
        
        if prop then
            local propModel = GetHashKey(prop.model)
            RequestModel(propModel)
            while not HasModelLoaded(propModel) do
                Citizen.Wait(0)
            end
            local propObj = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(propObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), prop.bone), prop.coords.x, prop.coords.y, prop.coords.z, prop.rotation.x, prop.rotation.y, prop.rotation.z, true, true, false, true, 1, true)
        end
        
        if propTwo then
            local propTwoModel = GetHashKey(propTwo.model)
            RequestModel(propTwoModel)
            while not HasModelLoaded(propTwoModel) do
                Citizen.Wait(0)
            end
            local propTwoObj = CreateObject(propTwoModel, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(propTwoObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), propTwo.bone), propTwo.coords.x, propTwo.coords.y, propTwo.coords.z, propTwo.rotation.x, propTwo.rotation.y, propTwo.rotation.z, true, true, false, true, 1, true)
        end
        
        Citizen.Wait(duration)
        
        if animation then
            ClearPedTasks(PlayerPedId())
        end
        
        if prop then
            DeleteEntity(prop)
        end
        
        if propTwo then
            DeleteEntity(propTwo)
        end
        
        if onFinish then
            onFinish()
        end
    end)
end

function DisableControls()
    Citizen.CreateThread(function()
        while progressActive do
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 32, true) -- W
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 31, true) -- S
            DisableControlAction(0, 30, true) -- D
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 23, true) -- Also 'enter'?
            DisableControlAction(0, 288, true) -- Disable phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- Animations
            DisableControlAction(0, 167, true) -- Job
            DisableControlAction(0, 73, true) -- Disable clearing animation
            DisableControlAction(2, 199, true) -- Disable pause screen
            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle
            DisableControlAction(2, 36, true) -- Disable going stealth
            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
            Citizen.Wait(0)
        end
    end)
end

-- Vehicle functions
function BW.Functions.SpawnVehicle(model, cb, coords, isnetworked)
    local model = GetHashKey(model)
    local coords = coords or GetEntityCoords(PlayerPedId())
    local isnetworked = isnetworked or true
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
    
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(vehicle)
    
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleFuelLevel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(model)
    
    if cb then
        cb(vehicle)
    end
    
    return vehicle
end

function BW.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function BW.Functions.GetVehiclesInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle
    
    for i = 0, 100 do
        rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)
        local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
        
        if vehicle ~= 0 then
            break
        end
        
        offset = offset + 1
    end
    
    return vehicle ~= 0 and vehicle or nil
end

-- Draw 3D text
function BW.Functions.DrawText3D(x, y, z, text)
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

-- Get street name and zone
function BW.Functions.GetStreetLabel()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local zoneName = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
    
    if crossingHash ~= 0 then
        local crossingName = GetStreetNameFromHashKey(crossingHash)
        return streetName .. " & " .. crossingName .. ", " .. zoneName
    else
        return streetName .. ", " .. zoneName
    end
end

-- Export core functions
exports('GetCoreObject', function()
    return BW
end)

-- Load configuration
Citizen.CreateThread(function()
    TriggerServerEvent('BW:Server:GetConfig')
end)

RegisterNetEvent('BW:Client:SetConfig')
AddEventHandler('BW:Client:SetConfig', function(config)
    BW.Config = config
end)

-- Debug mode
if Config and Config.Debug then
    RegisterCommand('bwdebug', function()
        print('BW Framework Debug Info:')
        print('Player Data:', json.encode(BW.PlayerData))
        print('Config:', json.encode(BW.Config))
    end, false)
end