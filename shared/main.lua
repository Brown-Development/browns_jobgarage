function config.Core:Object() 
    return self 
end

function config.garages:Object()
    return self 
end

settings = config.Core:Object() 

garage = config.garages:Object() 

function getCore()
    if settings.framework == 'esx' then 
        return exports['es_extended']:getSharedObject() 
    elseif settings.framework == 'qb-core' then 
        return exports['qb-core']:GetCoreObject()
    end
end

CORE = getCore() 

function getPlayer(source) 
    if settings.framework == 'esx' then 
        return CORE.GetPlayerFromId(source)
    elseif settings.framework == 'qb-core' then 
        return CORE.Functions.GetPlayer(source)
    end
end

function getId(player) 
    if settings.framework == 'esx' then 
        return player.getIdentifier()
    elseif settings.framework == 'qb-core' then 
        return player.PlayerData.citizenid 
    end
end

function getJobData(player) 
    if settings.framework == 'esx' then 
        local data = player.getJob()
        return data.name, data.grade
    elseif settings.framework == 'qb-core' then 
        return player.PlayerData.job.name, player.PlayerData.job.grade.level 
    end
end

function getPlayerName(identifier, player) 
    if settings.framework == 'esx' then 

        local pdata = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {
            identifier 
        })

        return pdata[1].firstname .. " " .. pdata[1].lastname 

    elseif settings.framework == 'qb-core' then 

        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname 
    end
end