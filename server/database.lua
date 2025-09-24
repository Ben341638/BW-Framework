-- Database Functions for BW Framework

BW.DB = {}

-- Initialize Database Connection
BW.DB.Initialize = function()
    if Config.DatabaseType == "mysql" then
        if GetResourceState('oxmysql') ~= 'started' then
            print("^1[BW Framework] Error: oxmysql resource is not started. Database functionality will not work.^0")
            return false
        end
        
        -- Create necessary tables if they don't exist
        BW.DB.CreateTables()
        return true
    else
        print("^1[BW Framework] Error: Unsupported database type. Only MySQL is currently supported.^0")
        return false
    end
end

-- Create Database Tables
BW.DB.CreateTables = function()
    -- Players Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_players` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `license` varchar(50) DEFAULT NULL,
            `name` varchar(50) DEFAULT NULL,
            `money` text NOT NULL,
            `charinfo` text DEFAULT NULL,
            `job` text NOT NULL,
            `gang` text DEFAULT NULL,
            `position` text NOT NULL,
            `metadata` text NOT NULL,
            `inventory` longtext DEFAULT NULL,
            `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Vehicles Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_vehicles` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `owner` varchar(50) DEFAULT NULL,
            `plate` varchar(12) NOT NULL,
            `model` varchar(50) DEFAULT NULL,
            `mods` longtext DEFAULT NULL,
            `state` tinyint(1) NOT NULL DEFAULT 0,
            `garage` varchar(50) DEFAULT 'pillbox',
            `fuel` int(11) NOT NULL DEFAULT 100,
            `engine` float NOT NULL DEFAULT 1000,
            `body` float NOT NULL DEFAULT 1000,
            PRIMARY KEY (`id`),
            KEY `plate` (`plate`),
            KEY `owner` (`owner`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Apartments Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_apartments` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) DEFAULT NULL,
            `type` varchar(50) DEFAULT NULL,
            `label` varchar(50) DEFAULT NULL,
            `citizenid` varchar(50) DEFAULT NULL,
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Jobs Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_jobs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL,
            `label` varchar(50) NOT NULL,
            `grades` text NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Items Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_items` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL,
            `label` varchar(50) NOT NULL,
            `weight` int(11) NOT NULL DEFAULT 0,
            `type` varchar(50) NOT NULL,
            `image` varchar(50) NOT NULL,
            `unique` tinyint(1) NOT NULL,
            `useable` tinyint(1) NOT NULL,
            `description` text NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Stashes Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_stashes` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `stash` varchar(50) NOT NULL,
            `items` longtext DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Logs Table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `bw_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `type` varchar(50) DEFAULT NULL,
            `source` varchar(50) DEFAULT NULL,
            `message` text DEFAULT NULL,
            `data` text DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    print("^2[BW Framework] Database tables created/verified successfully.^0")
end

-- Execute Query
BW.DB.Execute = function(query, params, cb)
    if Config.DatabaseSync then
        local result = MySQL.query.await(query, params)
        if cb then
            cb(result)
        end
        return result
    else
        MySQL.query(query, params, function(result)
            if cb then
                cb(result)
            end
        end)
    end
end

-- Single Query
BW.DB.QuerySingle = function(query, params, cb)
    if Config.DatabaseSync then
        local result = MySQL.single.await(query, params)
        if cb then
            cb(result)
        end
        return result
    else
        MySQL.single(query, params, function(result)
            if cb then
                cb(result)
            end
        end)
    end
end

-- Insert Query
BW.DB.Insert = function(query, params, cb)
    if Config.DatabaseSync then
        local result = MySQL.insert.await(query, params)
        if cb then
            cb(result)
        end
        return result
    else
        MySQL.insert(query, params, function(result)
            if cb then
                cb(result)
            end
        end)
    end
end

-- Update Query
BW.DB.Update = function(query, params, cb)
    if Config.DatabaseSync then
        local result = MySQL.update.await(query, params)
        if cb then
            cb(result)
        end
        return result
    else
        MySQL.update(query, params, function(result)
            if cb then
                cb(result)
            end
        end)
    end
end

-- Save Player
BW.DB.SavePlayer = function(player, cb)
    if player then
        local playerData = {
            identifier = player.PlayerData.identifier,
            license = player.PlayerData.license,
            name = player.PlayerData.name,
            money = json.encode(player.PlayerData.money),
            charinfo = json.encode(player.PlayerData.charinfo),
            job = json.encode(player.PlayerData.job),
            gang = json.encode(player.PlayerData.gang),
            position = json.encode(player.PlayerData.position),
            metadata = json.encode(player.PlayerData.metadata),
            inventory = json.encode(player.PlayerData.inventory)
        }
        
        BW.DB.Update('UPDATE bw_players SET money = ?, charinfo = ?, job = ?, gang = ?, position = ?, metadata = ?, inventory = ? WHERE identifier = ?', {
            playerData.money,
            playerData.charinfo,
            playerData.job,
            playerData.gang,
            playerData.position,
            playerData.metadata,
            playerData.inventory,
            playerData.identifier
        }, function(result)
            if cb then
                cb(result)
            end
        end)
    end
end

-- Create Player
BW.DB.CreatePlayer = function(data, cb)
    local playerData = {
        identifier = data.identifier,
        license = data.license,
        name = data.name,
        money = json.encode(data.money),
        charinfo = json.encode(data.charinfo),
        job = json.encode(data.job),
        gang = json.encode(data.gang),
        position = json.encode(data.position),
        metadata = json.encode(data.metadata),
        inventory = json.encode(data.inventory)
    }
    
    BW.DB.Insert('INSERT INTO bw_players (identifier, license, name, money, charinfo, job, gang, position, metadata, inventory) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        playerData.identifier,
        playerData.license,
        playerData.name,
        playerData.money,
        playerData.charinfo,
        playerData.job,
        playerData.gang,
        playerData.position,
        playerData.metadata,
        playerData.inventory
    }, function(result)
        if cb then
            cb(result)
        end
    end)
end

-- Get Player
BW.DB.GetPlayer = function(identifier, cb)
    BW.DB.QuerySingle('SELECT * FROM bw_players WHERE identifier = ?', {identifier}, function(result)
        if result then
            result.money = json.decode(result.money)
            result.charinfo = json.decode(result.charinfo)
            result.job = json.decode(result.job)
            result.gang = json.decode(result.gang)
            result.position = json.decode(result.position)
            result.metadata = json.decode(result.metadata)
            result.inventory = json.decode(result.inventory)
        end
        
        if cb then
            cb(result)
        end
    end)
end

-- Get Vehicle
BW.DB.GetVehicle = function(plate, cb)
    BW.DB.QuerySingle('SELECT * FROM bw_vehicles WHERE plate = ?', {plate}, function(result)
        if result then
            result.mods = json.decode(result.mods)
        end
        
        if cb then
            cb(result)
        end
    end)
end

-- Save Vehicle
BW.DB.SaveVehicle = function(plate, props, state, garage, fuel, engine, body, cb)
    BW.DB.Update('UPDATE bw_vehicles SET mods = ?, state = ?, garage = ?, fuel = ?, engine = ?, body = ? WHERE plate = ?', {
        json.encode(props),
        state,
        garage,
        fuel,
        engine,
        body,
        plate
    }, function(result)
        if cb then
            cb(result)
        end
    end)
end

-- Create Vehicle
BW.DB.CreateVehicle = function(owner, plate, model, props, state, garage, fuel, engine, body, cb)
    BW.DB.Insert('INSERT INTO bw_vehicles (owner, plate, model, mods, state, garage, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        owner,
        plate,
        model,
        json.encode(props),
        state,
        garage,
        fuel,
        engine,
        body
    }, function(result)
        if cb then
            cb(result)
        end
    end)
end

-- Log Event
BW.DB.LogEvent = function(type, source, message, data)
    BW.DB.Insert('INSERT INTO bw_logs (type, source, message, data) VALUES (?, ?, ?, ?)', {
        type,
        source,
        message,
        json.encode(data or {})
    })
end