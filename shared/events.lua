-- Shared Events for BW Framework

-- Register shared events
BW.Events = {
    -- Player Events
    playerLoaded = "bw:Player:PlayerLoaded",
    playerLogout = "bw:Player:PlayerLogout",
    setJob = "bw:Player:SetJob",
    setGang = "bw:Player:SetGang",
    setMoney = "bw:Player:SetMoney",
    setMetadata = "bw:Player:SetMetadata",
    
    -- Inventory Events
    itemAdded = "bw:Inventory:ItemAdded",
    itemRemoved = "bw:Inventory:ItemRemoved",
    itemUsed = "bw:Inventory:ItemUsed",
    
    -- Vehicle Events
    vehicleSpawned = "bw:Vehicle:VehicleSpawned",
    vehicleLocked = "bw:Vehicle:VehicleLocked",
    vehicleStored = "bw:Vehicle:VehicleStored",
    
    -- Job Events
    jobDutyChange = "bw:Job:DutyChange",
    
    -- Utility Events
    notify = "bw:Utility:Notify",
    progressbar = "bw:Utility:Progressbar",
    
    -- Callback Events
    triggerCallback = "bw:Server:TriggerCallback",
    callbackResponse = "bw:Client:CallbackResponse",
}

-- Register shared callbacks
BW.ServerCallbacks = {}