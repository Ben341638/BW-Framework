-- Player Management for BW Framework

BW.Players = {}
BW.Player = {}

-- Create a new player
function BW.Player.Create(source, identifier, license, name, callback)
    local self = {}
    self.Functions = {}
    self.PlayerData = {
        source = source,
        identifier = identifier,
        license = license,
        name = name,
        money = {
            cash = Config.StartingCash,
            bank = Config.StartingBank,
            crypto = 0
        },
        charinfo = {
            firstname = "John",
            lastname = "Doe",
            birthdate = "1990-01-01",
            gender = 0,
            nationality = "USA",
            phone = "555-" .. math.random(1000, 9999),
        },
        job = {
            name = "unemployed",
            label = "Unemployed",
            payment = 50,
            grade = {
                name = "Unemployed",
                level = 0
            }
        },
        gang = {
            name = "none",
            label = "No Gang",
            grade = 0
        },
        position = Config.DefaultSpawn,
        metadata = {
            hunger = 100,
            thirst = 100,
            stress = 0,
            isdead = false,
            inlaststand = false,
            armor = 0,
            ishandcuffed = false,
            injail = 0,
            jailitems = {},
            status = {},
            phone = {},
            fitbit = {},
            commandbinds = {},
            bloodtype = "A+",
            dealerrep = 0,
            craftingrep = 0,
            attachmentcraftingrep = 0,
            currentapartment = nil,
            jobrep = {
                trucker = 0,
                taxi = 0,
                tow = 0,
                hotdog = 0,
            },
            callsign = "NO CALLSIGN",
            fingerprint = BW.Player.CreateFingerprint(),
            walletid = BW.Player.CreateWalletId(),
            criminalrecord = {
                hasRecord = false,
                date = nil
            },
            licences = {
                driver = true,
                business = false,
                weapon = false
            },
            inside = {
                house = nil,
                apartment = {
                    apartmentType = nil,
                    apartmentId = nil,
                }
            },
        },
        inventory = {}
    }
    
    -- Player Functions
    self.Functions.UpdatePlayerData = function()
        TriggerClientEvent("bw:Player:SetPlayerData", self.PlayerData.source, self.PlayerData)
        
        if BW.Players[self.PlayerData.source] then
            BW.Players[self.PlayerData.source] = self
        end
    end
    
    self.Functions.SetJob = function(job, grade)
        local job = job:lower()
        local grade = tostring(grade) or '0'
        
        if Config.Jobs[job] then
            self.PlayerData.job.name = job
            self.PlayerData.job.label = Config.Jobs[job].label
            self.PlayerData.job.payment = Config.Jobs[job].grades[grade].payment
            self.PlayerData.job.grade = {
                name = Config.Jobs[job].grades[grade].name,
                level = tonumber(grade)
            }
            
            self.Functions.UpdatePlayerData()
            TriggerClientEvent("bw:Player:SetJob", self.PlayerData.source, self.PlayerData.job)
            return true
        end
        
        return false
    end
    
    self.Functions.SetGang = function(gang, grade)
        local gang = gang:lower()
        local grade = tostring(grade) or '0'
        
        if Config.Gangs and Config.Gangs[gang] then
            self.PlayerData.gang.name = gang
            self.PlayerData.gang.label = Config.Gangs[gang].label
            self.PlayerData.gang.grade = tonumber(grade)
            
            self.Functions.UpdatePlayerData()
            TriggerClientEvent("bw:Player:SetGang", self.PlayerData.source, self.PlayerData.gang)
            return true
        end
        
        return false
    end
    
    self.Functions.SetPosition = function(position)
        self.PlayerData.position = position
        self.Functions.UpdatePlayerData()
    end
    
    self.Functions.AddMoney = function(moneytype, amount, reason)
        reason = reason or "unknown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        
        if amount < 0 then
            return false
        end
        
        if self.PlayerData.money[moneytype] then
            self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount
            self.Functions.UpdatePlayerData()
            TriggerClientEvent("bw:Player:SetMoney", self.PlayerData.source, self.PlayerData.money)
            BW.DB.LogEvent("money", self.PlayerData.source, "added_money", {
                moneytype = moneytype,
                amount = amount,
                reason = reason,
                balance = self.PlayerData.money[moneytype]
            })
            return true
        end
        
        return false
    end
    
    self.Functions.RemoveMoney = function(moneytype, amount, reason)
        reason = reason or "unknown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        
        if amount < 0 then
            return false
        end
        
        if self.PlayerData.money[moneytype] then
            if self.PlayerData.money[moneytype] >= amount then
                self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
                self.Functions.UpdatePlayerData()
                TriggerClientEvent("bw:Player:SetMoney", self.PlayerData.source, self.PlayerData.money)
                BW.DB.LogEvent("money", self.PlayerData.source, "removed_money", {
                    moneytype = moneytype,
                    amount = amount,
                    reason = reason,
                    balance = self.PlayerData.money[moneytype]
                })
                return true
            end
        end
        
        return false
    end
    
    self.Functions.SetMoney = function(moneytype, amount, reason)
        reason = reason or "unknown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        
        if amount < 0 then
            return false
        end
        
        if self.PlayerData.money[moneytype] then
            self.PlayerData.money[moneytype] = amount
            self.Functions.UpdatePlayerData()
            TriggerClientEvent("bw:Player:SetMoney", self.PlayerData.source, self.PlayerData.money)
            BW.DB.LogEvent("money", self.PlayerData.source, "set_money", {
                moneytype = moneytype,
                amount = amount,
                reason = reason,
                balance = self.PlayerData.money[moneytype]
            })
            return true
        end
        
        return false
    end
    
    self.Functions.GetMoney = function(moneytype)
        if moneytype then
            local moneytype = moneytype:lower()
            return self.PlayerData.money[moneytype]
        end
        
        return self.PlayerData.money
    end
    
    self.Functions.SetMetaData = function(meta, val)
        if meta and val then
            if self.PlayerData.metadata[meta] ~= nil then
                self.PlayerData.metadata[meta] = val
                self.Functions.UpdatePlayerData()
                return true
            end
        end
        
        return false
    end
    
    self.Functions.GetMetaData = function(meta)
        if meta then
            return self.PlayerData.metadata[meta]
        end
        
        return self.PlayerData.metadata
    end
    
    self.Functions.AddItem = function(item, amount, slot, info)
        -- This would be implemented with an inventory system
        -- For now, just a placeholder
        return true
    end
    
    self.Functions.RemoveItem = function(item, amount, slot)
        -- This would be implemented with an inventory system
        -- For now, just a placeholder
        return true
    end
    
    self.Functions.GetItemByName = function(item)
        -- This would be implemented with an inventory system
        -- For now, just a placeholder
        return nil
    end
    
    self.Functions.GetItemsByName = function(item)
        -- This would be implemented with an inventory system
        -- For now, just a placeholder
        return {}
    end
    
    self.Functions.Save = function()
        BW.DB.SavePlayer(self)
    end
    
    BW.Players[self.PlayerData.source] = self
    
    -- Create the player in the database
    BW.DB.CreatePlayer(self.PlayerData, function(result)
        if callback then
            callback(self)
        end
    end)
    
    return self
end

-- Get a player by source
function BW.Player.Get(source)
    if BW.Players[source] then
        return BW.Players[source]
    end
    
    return nil
end

-- Get all players
function BW.Player.GetAll()
    return BW.Players
end

-- Save all players
function BW.Player.SaveAll()
    for _, player in pairs(BW.Players) do
        player.Functions.Save()
    end
end

-- Create a fingerprint
function BW.Player.CreateFingerprint()
    local fingerprint = "BW"
    for i = 1, 8 do
        fingerprint = fingerprint .. math.random(0, 9)
    end
    return fingerprint
end

-- Create a wallet ID
function BW.Player.CreateWalletId()
    local walletId = "BW-"
    for i = 1, 4 do
        walletId = walletId .. string.char(math.random(65, 90))
    end
    walletId = walletId .. "-"
    for i = 1, 4 do
        walletId = walletId .. math.random(0, 9)
    end
    return walletId
end

-- Load a player from the database
function BW.Player.Load(source, identifier, callback)
    BW.DB.GetPlayer(identifier, function(result)
        if result then
            local self = {}
            self.Functions = {}
            self.PlayerData = result
            self.PlayerData.source = source
            
            -- Add all the same functions as in Create
            -- This would be a duplicate of the functions above
            -- For brevity, we'll assume they're added here
            
            BW.Players[source] = self
            
            if callback then
                callback(self)
            end
        else
            if callback then
                callback(nil)
            end
        end
    end)
end