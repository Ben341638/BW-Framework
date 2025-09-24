BW = {}
BW.Functions = {}
BW.PlayerData = {}
BW.Config = Config
BW.Shared = {}

-- Utility Functions
function BW.Functions.Print(message)
    if BW.Config.Debug then
        print(string.format("[BW Framework] %s", message))
    end
end

function BW.Functions.Debug(message)
    if BW.Config.Debug then
        print(string.format("[BW Debug] %s", message))
    end
end

function BW.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity)
    return vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

function BW.Functions.Round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10^numDecimalPlaces
        return math.floor((value * power) + 0.5) / power
    else
        return math.floor(value + 0.5)
    end
end

function BW.Functions.SplitStr(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    
    table.insert(result, string.sub(str, from))
    return result
end

function BW.Functions.FirstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function BW.Functions.MathRound(value, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

function BW.Functions.GetClosestPlayer(coords)
    local closestPlayers = BW.Functions.GetPlayersFromCoords(coords)
    local closestDistance = -1
    local closestPlayer = -1
    
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() and closestPlayers[i] ~= -1 then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(coords - pos)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

function BW.Functions.GetPlayersFromCoords(coords, distance)
    local players = GetActivePlayers()
    local ped = PlayerPedId()
    local playerCoords = coords or GetEntityCoords(ped)
    local distance = distance or 5
    local closePlayers = {}
    
    for i = 1, #players, 1 do
        local targetPed = GetPlayerPed(players[i])
        local targetCoords = GetEntityCoords(targetPed)
        local targetdistance = #(playerCoords - targetCoords)
        
        if targetdistance <= distance then
            table.insert(closePlayers, players[i])
        end
    end
    
    return closePlayers
end

function BW.Functions.GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}

        for extraId = 0, 12 do
            if DoesExtraExist(vehicle, extraId) then
                extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId) and 1 or 0
            end
        end

        return {
            model = GetEntityModel(vehicle),
            plate = GetVehicleNumberPlateText(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            bodyHealth = BW.Functions.Round(GetVehicleBodyHealth(vehicle), 1),
            engineHealth = BW.Functions.Round(GetVehicleEngineHealth(vehicle), 1),
            tankHealth = BW.Functions.Round(GetVehiclePetrolTankHealth(vehicle), 1),
            fuelLevel = BW.Functions.Round(GetVehicleFuelLevel(vehicle), 1),
            dirtLevel = BW.Functions.Round(GetVehicleDirtLevel(vehicle), 1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleLivery(vehicle)
        }
    else
        return nil
    end
end

function BW.Functions.SetVehicleProperties(vehicle, props)
    if DoesEntityExist(vehicle) then
        SetVehicleModKit(vehicle, 0)

        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end

        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end

        if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end

        if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end

        if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end

        if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end

        if props.color1 then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, props.color1, color2)
        end

        if props.color2 then
            local color1, color2 = GetVehicleColours(vehicle)
            SetVehicleColours(vehicle, color1, props.color2)
        end

        if props.pearlescentColor then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end

        if props.wheelColor then
            local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
            SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
        end

        if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end

        if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end

        if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end

        if props.extras then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end

        if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, true)
        end

        if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end

        if props.modSpoilers then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end

        if props.modFrontBumper then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end

        if props.modRearBumper then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end

        if props.modSideSkirt then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end

        if props.modExhaust then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end

        if props.modFrame then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end

        if props.modGrille then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end

        if props.modHood then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end

        if props.modFender then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end

        if props.modRightFender then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end

        if props.modRoof then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end

        if props.modEngine then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end

        if props.modBrakes then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end

        if props.modTransmission then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end

        if props.modHorns then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end

        if props.modSuspension then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end

        if props.modArmor then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end

        if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end

        if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end

        if props.modFrontWheels then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
        end

        if props.modBackWheels then
            SetVehicleMod(vehicle, 24, props.modBackWheels, false)
        end

        if props.modPlateHolder then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end

        if props.modVanityPlate then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end

        if props.modTrimA then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end

        if props.modOrnaments then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end

        if props.modDashboard then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end

        if props.modDial then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end

        if props.modDoorSpeaker then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end

        if props.modSeats then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end

        if props.modSteeringWheel then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end

        if props.modShifterLeavers then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end

        if props.modAPlate then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end

        if props.modSpeakers then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end

        if props.modTrunk then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end

        if props.modHydrolic then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end

        if props.modEngineBlock then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end

        if props.modAirFilter then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end

        if props.modStruts then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end

        if props.modArchCover then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end

        if props.modAerials then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end

        if props.modTrimB then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end

        if props.modTank then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end

        if props.modWindows then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end

        if props.modLivery then
            SetVehicleLivery(vehicle, props.modLivery)
        end
    end
end