Config = {}

-- Core Settings
Config.ServerName = "BW Framework Server"
Config.Debug = false
Config.DefaultSpawn = vector4(195.17, -933.77, 29.7, 144.5)

-- Database Settings
Config.DatabaseType = "mysql" -- mysql or sqlite
Config.DatabaseName = "bw_framework"
Config.DatabaseSync = true -- Set to true for synchronous database operations

-- Player Settings
Config.StartingCash = 500
Config.StartingBank = 5000
Config.MaxCharacters = 5
Config.IdentifierType = "license" -- license, steam, discord, etc.
Config.RespawnTime = 300 -- seconds
Config.PaycheckInterval = 30 -- minutes
Config.PaycheckAmount = 150

-- Inventory Settings
Config.MaxInventorySlots = 40
Config.MaxInventoryWeight = 100
Config.ItemWeights = {
    ["water"] = 0.5,
    ["bread"] = 0.5,
    ["phone"] = 1.0,
    ["weapon_pistol"] = 3.0,
}

-- Vehicle Settings
Config.FuelUsage = 0.3 -- Fuel usage per distance unit
Config.ElectricVehicleFuelUsage = 0.1
Config.VehicleDegradation = true

-- Job Settings
Config.Jobs = {
    ["unemployed"] = {
        label = "Unemployed",
        defaultDuty = true,
        grades = {
            [0] = {
                name = "Unemployed",
                payment = 50
            },
        },
    },
    ["police"] = {
        label = "Police Department",
        defaultDuty = false,
        grades = {
            [0] = {
                name = "Cadet",
                payment = 150
            },
            [1] = {
                name = "Officer",
                payment = 200
            },
            [2] = {
                name = "Sergeant",
                payment = 250
            },
            [3] = {
                name = "Lieutenant",
                payment = 300
            },
            [4] = {
                name = "Chief",
                payment = 400
            },
        },
    },
    ["ambulance"] = {
        label = "Emergency Medical Services",
        defaultDuty = false,
        grades = {
            [0] = {
                name = "EMT",
                payment = 150
            },
            [1] = {
                name = "Paramedic",
                payment = 200
            },
            [2] = {
                name = "Doctor",
                payment = 250
            },
            [3] = {
                name = "Surgeon",
                payment = 300
            },
            [4] = {
                name = "Chief of Medicine",
                payment = 400
            },
        },
    },
    ["mechanic"] = {
        label = "Mechanic",
        defaultDuty = false,
        grades = {
            [0] = {
                name = "Apprentice",
                payment = 150
            },
            [1] = {
                name = "Mechanic",
                payment = 200
            },
            [2] = {
                name = "Senior Mechanic",
                payment = 250
            },
            [3] = {
                name = "Manager",
                payment = 300
            },
            [4] = {
                name = "Owner",
                payment = 400
            },
        },
    },
}

-- Phone Settings
Config.PhoneModel = "prop_npc_phone"
Config.PhoneApps = {
    "phone",
    "messages",
    "contacts",
    "twitter",
    "bank",
    "camera",
    "settings",
    "gallery",
}

-- Crime Settings
Config.PoliceRequired = {
    ["storerobbery"] = 2,
    ["bankrobbery"] = 4,
    ["jewelryrobbery"] = 3,
    ["houserobbery"] = 1,
}

-- Voice Settings
Config.VoiceEnabled = true
Config.VoiceRanges = {
    [1] = 2.0, -- Whisper
    [2] = 5.0, -- Normal
    [3] = 12.0, -- Shout
}

-- Doorlock Settings
Config.DoorlockSystem = "ox" -- ox, esx, custom

-- Dispatch Settings
Config.DispatchSystem = "custom" -- ps-dispatch, cd-dispatch, custom

-- Framework Compatibility
Config.CompatibilityMode = false -- Set to true for ESX/QB compatibility
Config.CompatibilityFramework = "none" -- esx, qb, none