AddEventHandler('onResourceStart', function(resourceName) 
    if resourceName == GetCurrentResourceName() then 
        exports.oxmysql:execute([[
            CREATE TABLE IF NOT EXISTS `takehome_vehicles` (
                `player` VARCHAR(255) DEFAULT NULL,
                `job` VARCHAR(255) DEFAULT NULL,
                `model` VARCHAR(255) DEFAULT NULL,
                `label` VARCHAR(255) DEFAULT NULL
            )
        ]])

        exports.oxmysql:execute([[
            CREATE TABLE IF NOT EXISTS `job_garages` (
                `player` VARCHAR(255) DEFAULT NULL,
                `job` VARCHAR(255) DEFAULT NULL,
                `label` VARCHAR(255) DEFAULT NULL,
                `props` LONGTEXT DEFAULT NULL,
                `plate` VARCHAR(255) DEFAULT NULL
            )
        ]])

        if settings.framework == 'esx' then 
            exports.oxmysql:execute([[
                ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `takehome` VARCHAR(255) DEFAULT NULL
            ]])
        elseif settings.framework == 'qb-core' then 
            exports.oxmysql:execute([[
                ALTER TABLE `player_vehicles` ADD COLUMN IF NOT EXISTS `takehome` VARCHAR(255) DEFAULT NULL
            ]])
        end

    end 

end)

lib.callback.register('browns:jg:server:GetJobInfo', function(source) -- getting the players job and grade

    local ply = getPlayer(source)

    local job, grade = getJobData(ply)

    return job, grade
end)

lib.callback.register('browns:jg:server:GetPlayers', function(source, jobname) -- getting players for takehome system

    local players = {}

    local ply = getPlayer(source)


    local job, selfGrade = getJobData(ply)


    if job ~= jobname then 
        return false, 'You cant access this, your dont have the job'
    end

    if not garage[job].takehome.grades[tostring(selfGrade)] then 
        return false, 'You cant access this, your not a high enough rank'
    end

    for _, id in ipairs(GetPlayers()) do 
        local player = getPlayer(id) or getPlayer(tonumber(id))

        local pjob, pgrade = getJobData(player)

        if pjob == job then 

            local pid = getId(player)

            local playerName = getPlayerName(pid, player)

            table.insert(players, {
                id = id, 
                name = playerName,
                job = pjob
            })

        end

    end
    
    return true, players
end)

lib.callback.register('browns:jg:server:IssueTakeHome', function(source, model, label, player, job)
    local ply = getPlayer(player) or getPlayer(tonumber(player))

    if not ply then return false, 'The Player is not online' end

    local id = getId(ply)

    local continue = true 

    local exists = MySQL.query.await('SELECT * FROM takehome_vehicles WHERE player = ?', {
        id
    })

    if exists[1] then 
        for i = 1, #exists do 
            local data = exists[i] 
            if data.model == model then 
                continue = false
                break 
            end
        end
    end

    if not continue then 
        return false, 'This person already has issued' .. " " .. label .. " " .. 'that they have not taken out yet' 
    end
    
    local promise = MySQL.insert.await('INSERT INTO takehome_vehicles (player, job, model, label) VALUES (?, ?, ?, ?)', {
        id, job, model, label
    })

    return true, 'You issued a' .. " " .. label
end)

lib.callback.register('browns:jg:sever:ViewTHV', function(source, jobname)
    local ply = getPlayer(source)
    local id = getId(ply)

    local job, _ = getJobData(ply)

    if job ~= jobname then 
        return false, 'You can not access this, you dont have the job'
    end

    local exists = MySQL.query.await('SELECT * FROM takehome_vehicles WHERE player = ?', {
        id
    })

    if not exists[1] then 
        return false, 'You have no issued take home vehicles'
    end

    local results = {}

    for i = 1, #exists do 
        local data = exists[i]
        if data.job == job then 
            table.insert(results, {
                model = data.model, 
                label = data.label
            })
        end
    end

    return true, results
end)

RegisterNetEvent('browns:jg:server:SaveVehicle', function(props, model, job)

    local ply = getPlayer(source)
    local id = getId(ply)
    local license = GetPlayerIdentifierByType(source, 'license')

    if settings.framework == 'esx' then 
        local promise = MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, takehome) VALUES (?, ?, ?, ?, ?)', {
            id, props.plate, json.encode(props), 'car', job
        })
    elseif settings.framework == 'qb-core' then 
        local promise = MySQL.insert.await('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, fuel, engine, body, state, depotprice, takehome) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            license, id, model, props.model, json.encode(props), props.plate, 100, 1000, 1000, 1, 0, job
        })
    end

end)

RegisterNetEvent('browns:jg:server:RemoveVehicle', function(model)
    local ply = getPlayer(source)
    local id = getId(ply)

    exports.oxmysql:execute('DELETE FROM takehome_vehicles WHERE player = ? AND model = ?', {
        id, model
    })
end)

lib.callback.register('browns:jg:server:WipeVehicles', function(source, player, job)
    local ply = getPlayer(player) or getPlayer(tonumber(player))

    if not ply then return false end 

    local id = getId(ply)

    if settings.framework == 'esx' then 
        exports.oxmysql:execute('DELETE FROM owned_vehicles WHERE owner = ? AND takehome = ?', {
            id, job
        })
    elseif settings.framework == 'qb-core' then 
        exports.oxmysql:execute('DELETE FROM player_vehicles WHERE citizenid = ? AND takehome = ?', {
            id, job
        })
    end
    
    return true
end)

RegisterNetEvent('browns:jg:server:StoreVehicle', function(props, label, job)
    local ply = getPlayer(source)
    local id = getId(ply)

    local promise = MySQL.insert.await('INSERT INTO job_garages (player, job, label, props, plate) VALUES (?, ?, ?, ?, ?)', {
        id, job, label, json.encode(props), props.plate
    })
end)

lib.callback.register('browns:jg:server:PullVehicle', function(source, job)
    local ply = getPlayer(source)
    local id = getId(ply)

    local stored = MySQL.query.await('SELECT * FROM job_garages WHERE player = ? AND job = ?', {
        id, job
    })

    if not stored[1] then return false, 'You have no Job vehicles stored' end  

    return stored
end)

RegisterNetEvent('browns:jg:server:CacheVeh', function(plate)
    local ply = getPlayer(source)
    local id = getId(ply)

    exports.oxmysql:execute('DELETE FROM job_garages WHERE player = ? AND plate = ?', {
        id, plate
    })

end)

lib.callback.register('browns:jg:server:IsOwned', function(source, plate)

    local owned = nil

    if settings.framework == 'esx' then 
        owned = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
            plate
        })

    elseif settings.framework == 'qb-core' then 
        owned = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {
            plate
        })
    end

    if owned[1] then return false, 'You can not store owned vehicles' end

    
    return true
end)
