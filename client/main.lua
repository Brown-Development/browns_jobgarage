local Camera = nil 
local Vehicle = nil 
local CamSet = false 
local vehicles = {} 
local thisModel = nil
local PrimaryMat = 'Metallic' 
local SecondaryMat = 'Metallic' 
local thisJob = nil 
local Cache = {} 
local ControlSlide = false 
local doSlide = false
local SaveThis = false
local NuiOpen = false
local Busy = false 

local Materials = { 
    ['Classic'] = 0,
    ['Metallic'] = 1,
    ['Pearl'] = 2,
    ['Matte'] = 3,
    ['Metal'] = 4,
    ['Chrome'] = 5
}

local JobEvent = OnJobUpdate()
local LoadEvent = OnPlayerLoaded()

RegisterNetEvent(LoadEvent)
AddEventHandler(LoadEvent, function(xPlayer)

    Citizen.Wait(5000)

    if settings.framework == 'esx' then CORE.PlayerData = xPlayer end

    Citizen.CreateThread(function()
        local job = false 

        repeat 
    
            job = lib.callback.await('browns:jg:server:AwaitJobMessage', false) 
    
        until job ~= false
    
        thisJob = job 
    
        if garage[job] then SyncMarkers(thisJob) end
    end)

end)

RegisterNetEvent(JobEvent)
AddEventHandler(JobEvent, function(data)

    thisJob = data.name 

    if garage[thisJob] then SyncMarkers(thisJob) end

end)

AddEventHandler('onResourceStop', function() 
    if Vehicle then DeleteEntity(Vehicle) end 

    ClearCache()

    SetEntityVisible(cache.ped, true, true) 
    SetEntityInvincible(cache.ped, false) 

end)

AddEventHandler('onResourceStart', function()

    local job = false 

    if cache.ped then 

        Citizen.CreateThread(function()
            repeat 
        
                job = lib.callback.await('browns:jg:server:AwaitJobMessage', false) 
    
            until job ~= false
    
            thisJob = job 
    
            if garage[job] then SyncMarkers(thisJob) end
        end)

    end

end)

Citizen.CreateThread(function()
    for k, v in pairs(garage) do 
        if type(v) ~= 'function' then 
            local model = GetHashKey(v.takehome.locations.ped.model)
            if IsModelInCdimage(model) then 
                RequestModel(model)
                while not HasModelLoaded(model) do 
                    Citizen.Wait(0)
                end
                local ped = CreatePed(0, model, table.unpack({v.takehome.locations.ped.coords}), false, false)
                while not DoesEntityExist(ped) do 
                    Citizen.Wait(0)
                end
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
            else
                print('Can not load ped model:', v.takehome.locations.ped.model, "Job:", k)
            end
        end
    end
end)

function SyncMarkers(job)
    lib.zones.box({
        coords = garage[job].location.coords,
        size = vec3(2, 2, 2),
        rotation = 0,
        onEnter = function()
            if thisJob == job then 
                lib.showTextUI('[E] - Open Job Garage', {
                    position = 'right-center',
                    icon = {'fas', 'warehouse'},
                    iconColor = '#FFFFFF',
                    iconAnimation = 'bounce',
                    style = { 
                        borderRadius = 10,
                        backgroundColor = '#000000',
                        color = '#FFFFFF'
                    }
                })
            end
            Citizen.CreateThread(function()
                Citizen.Wait(200) 
                while thisJob == job do 
                    Citizen.Wait(0)
                    local bool, str = lib.isTextUIOpen() 
                    if bool and str == '[E] - Open Job Garage' then 
                        if IsControlJustPressed(0, 46) then 
                            lib.hideTextUI()
                            OpenMenu(job) 
                            break 
                        end
                    else
                        break 
                    end
                end
            end)
        end,
        onExit = function()
            local bool, str = lib.isTextUIOpen() 
            if bool and str == '[E] - Open Job Garage' then 
                lib.hideTextUI()
            end
        end
    })
    if garage[job].takehome.enable then 
        lib.zones.box({
            coords = garage[job].takehome.locations.menu,
            size = vec3(2, 2, 2),
            rotation = 0,
            onEnter = function()
                if thisJob == job then 
                    lib.showTextUI('[E] - Issue Take Home Vehicle', {
                        position = 'right-center',
                        icon = {'fas', 'car'},
                        iconColor = '#FFFFFF',
                        iconAnimation = 'bounce',
                        style = { 
                            borderRadius = 10,
                            backgroundColor = '#000000',
                            color = '#FFFFFF'
                        }
                    })
                end
                Citizen.CreateThread(function()
                    Citizen.Wait(200) 
                    while thisJob == job do 
                        Citizen.Wait(0)
                        local bool, str = lib.isTextUIOpen() 
                        if bool and str == '[E] - Issue Take Home Vehicle' then 
                            if IsControlJustPressed(0, 46) then 
                                lib.hideTextUI()
                                OpenThMenu(job) 
                                break 
                            end
                        else
                            break 
                        end
                    end
                end)
            end,
            onExit = function()
                local bool, str = lib.isTextUIOpen() 
                if bool and str == '[E] - Issue Take Home Vehicle' then 
                    lib.hideTextUI()
                end
            end
        })
        local x, y, z, hh = table.unpack(garage[job].takehome.locations.ped.coords)
        lib.zones.box({
            coords = vec3(x, y, z),
            size = vec3(3, 3, 3),
            rotation = 0,
            onEnter = function()
                if thisJob == job then 
                    lib.showTextUI('[E] - View Issued Takehome Vehicles', {
                        position = 'right-center',
                        icon = {'fas', 'car'},
                        iconColor = '#FFFFFF',
                        iconAnimation = 'bounce',
                        style = { 
                            borderRadius = 10,
                            backgroundColor = '#000000',
                            color = '#FFFFFF'
                        }
                    })
                end
                Citizen.CreateThread(function()
                    Citizen.Wait(200) 
                    while thisJob == job do 
                        Citizen.Wait(0)
                        local bool, str = lib.isTextUIOpen() 
                        if bool and str == '[E] - View Issued Takehome Vehicles' then 
                            if IsControlJustPressed(0, 46) then 
                                lib.hideTextUI()
                                ViewThMenu(job) 
                                break 
                            end
                        else
                            break 
                        end
                    end
                end)
            end,
            onExit = function()
                local bool, str = lib.isTextUIOpen() 
                if bool and str == '[E] - View Issued Takehome Vehicles' then 
                    lib.hideTextUI()
                end
            end
        })
    end
    if garage[job].garage.enable then 
        lib.zones.box({
            coords = garage[job].garage.store,
            size = vec3(4, 4, 4),
            rotation = 0,
            onEnter = function()
                if IsPedInAnyVehicle(cache.ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(cache.ped, false), -1) == cache.ped then 
                    if thisJob == job then 
                        lib.showTextUI('[E] - Store Job Vehicle', {
                            position = 'right-center',
                            icon = {'fas', 'car'},
                            iconColor = '#FFFFFF',
                            iconAnimation = 'bounce',
                            style = { 
                                borderRadius = 10,
                                backgroundColor = '#000000',
                                color = '#FFFFFF'
                            }
                        })
                    end
                    Citizen.CreateThread(function()
                        Citizen.Wait(200) 
                        while thisJob == job do 
                            Citizen.Wait(0)
                            local bool, str = lib.isTextUIOpen() 
                            if bool and str == '[E] - Store Job Vehicle' then 
                                if IsControlJustPressed(0, 46) then 
                                    lib.hideTextUI()
                                    StoreVehicle(job)
                                    break 
                                end
                            else
                                break 
                            end
                        end
                    end)
                end
            end,
            onExit = function()
                local bool, str = lib.isTextUIOpen() 
                if bool and str == '[E] - Store Job Vehicle' then 
                    lib.hideTextUI()
                end
            end
        })
        lib.zones.sphere({
            coords = garage[job].garage.pull,
            radius = 2,
            onEnter = function()
                if not IsPedInAnyVehicle(cache.ped, false) then 
                    if thisJob == job then 
                        lib.showTextUI('[E] - Retrieve Job Vehicle', {
                            position = 'right-center',
                            icon = {'fas', 'car'},
                            iconColor = '#FFFFFF',
                            iconAnimation = 'bounce',
                            style = { 
                                borderRadius = 10,
                                backgroundColor = '#000000',
                                color = '#FFFFFF'
                            }
                        })
                    end
                    Citizen.CreateThread(function()
                        Citizen.Wait(200) 
                        while thisJob == job do 
                            Citizen.Wait(0)
                            local bool, str = lib.isTextUIOpen() 
                            if bool and str == '[E] - Retrieve Job Vehicle' then 
                                if IsControlJustPressed(0, 46) then 
                                    lib.hideTextUI()
                                    PullVehicle(job)
                                    break 
                                end
                            else
                                break 
                            end
                        end
                    end)
                end
            end,
            onExit = function()
                local bool, str = lib.isTextUIOpen() 
                if bool and str == '[E] - Retrieve Job Vehicle' then 
                    lib.hideTextUI()
                end
            end
        })
    end
    Citizen.CreateThread(function()
        while thisJob == job do 
            Citizen.Wait(0)
            DrawMarker(36, table.unpack({garage[job].location.coords}), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, garage[job].markerColors[1], garage[job].markerColors[2], garage[job].markerColors[3], 200, true, false, 2, true, nil, nil, false)
            if garage[job].takehome.enable then
                DrawMarker(30, table.unpack({garage[job].takehome.locations.menu}), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, garage[job].markerColors[1], garage[job].markerColors[2], garage[job].markerColors[3], 200, true, false, 2, true, nil, nil, false)
            end
            if garage[job].garage.enable then 
                DrawMarker(24, table.unpack({garage[job].garage.store}), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, garage[job].markerColors[1], garage[job].markerColors[2], garage[job].markerColors[3], 200, true, false, 2, true, nil, nil, false)
                DrawMarker(1, table.unpack({garage[job].garage.pull}), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, garage[job].markerColors[1], garage[job].markerColors[2], garage[job].markerColors[3], 200, false, false, 2, false, nil, nil, false)
            end
        end
    end)
end

function StoreVehicle(name)

    local vehName = nil

    local job, grade = lib.callback.await('browns:jg:server:GetJobInfo', false)

    if job ~= name then settings.notify('Job Garage', 'You cant access this', 'error', 5000) return end  

    local veh = GetVehiclePedIsIn(cache.ped, false)

    local props = lib.getVehicleProperties(veh)

    local bool, err = lib.callback.await('browns:jg:server:IsOwned', false, props.plate)

    if not bool then settings.notify('Job Garage', err, 'error', 5000) return end 

    for _, v in ipairs(garage[name].vehicles) do 
        local model = GetHashKey(v.model)
        if IsModelInCdimage(model) then 
            if model == props.model then 
                vehName = v.label 
                break 
            end
        end
    end

    if not vehName then settings.notify('Job Garage', 'You can only store job related vehicles', 'error', 5000) return end

    DeleteEntity(veh)

    TriggerServerEvent('browns:jg:server:StoreVehicle', props, vehName, name)

    settings.notify('Job Garage', 'You stored the vehicle', 'success', 5000)
end

function PullVehicle(name)

    local job, grade = lib.callback.await('browns:jg:server:GetJobInfo', false)

    if job ~= name then settings.notify('Job Garage', 'You cant access this', 'error', 5000) return end  

    local data, err = lib.callback.await('browns:jg:server:PullVehicle', false, name)

    if not data then settings.notify('Job Garage', err, 'error', 5000) return end  

    local options = {}

    for i = 1, #data do 
        local _data = data[i]
        table.insert(options, {
            title = _data.label,
            description = 'Pull out' .. " " .. _data.label,
            onSelect = function()
                local props = json.decode(_data.props)

                if IsModelInCdimage(props.model) then 
                    RequestModel(props.model)

                    while not HasModelLoaded(props.model) do 
                        Citizen.Wait(0)
                    end

                    local veh = CreateVehicle(props.model, table.unpack({garage[name].garage.spawn}), true, false)

                    while not DoesEntityExist(veh) do 
                        Citizen.Wait(0)
                    end

                    lib.setVehicleProperties(veh, props)

                    SetPedIntoVehicle(cache.ped, veh, -1)

                    SetVehicleEngineOn(veh, true, false, false)

                    settings.givekeys(veh, props.plate)

                    settings.notify('Job Garage', 'You took out the vehicle', 'success', 5000)

                    TriggerServerEvent('browns:jg:server:CacheVeh', props.plate)

                else
                    settings.notify('Job Garage', 'This vehicle does not exist in the server', 'error', 5000)
                end
            end
        })
    end

    lib.registerContext({
        id = 'browns_jobgarage_garaged',
        title = 'Select Vehicle to take out',
        options = options
    })

    lib.showContext('browns_jobgarage_garaged')

end

function OpenMenu(name) 

    if not Busy then 
        Busy = true 
        
        local job, grade = lib.callback.await('browns:jg:server:GetJobInfo', false) 
    
    
        if job ~= name then 
            settings.notify('Job Garage', 'You can not access this', 'error', 5000)
            Busy = false
            return
        end
    
        thisJob = job 
    
        for k, v in ipairs(garage[job].vehicles) do 
            if grade >= v.grade then 
                table.insert(vehicles, { 
                    model = v.model,
                    label = v.label
                })
            end
        end
    
        local Trash = {}
    
        SendNUIMessage({
            type = 'progress'
        })
    
        for i, v in ipairs(vehicles) do 
            local model = GetHashKey(v.model)
            if IsModelInCdimage(model) then 
                SendNUIMessage({
                    type = 'loading',
                    veh = v.label
                })
                RequestModel(model)
                while not HasModelLoaded(model) do 
                    Citizen.Wait(0)
                    if config.debug then 
                        print('Loading Vehicle:' .. " " .. v.label, "Model:" .. " " .. v.model)
                    end
                end
            else
                print('Cant Load Vehicle (Not in CD Image):', v.label, v.model)
                table.insert(Trash, {
                    vehicle = i
                })
            end
        end
    
        SendNUIMessage({
            type = 'hide_progress'
        })
    
        for _, trash in ipairs(Trash) do 
            table.remove(vehicles, trash.vehicle)
        end
    
        if not vehicles[1] then
            settings.notify('Job Garage', 'There are no vehicles that you can access', 'error', 5000)
            Busy = false
            return 
        end
    
        SetNuiFocus(true, true)
    
        local displayVeh = vehicles[1].model 
    
        CycleVehicle(displayVeh, job)
    
        SetEntityVisible(cache.ped, false, false) 
        SetEntityInvincible(cache.ped, true) 
    end

end

function OpenThMenu(name)
    local bool, result = lib.callback.await('browns:jg:server:GetPlayers', false, name) 

    if not bool then 
        settings.notify('Job Garage', result, 'error', 5000)
        return 
    end

    local options = {}
    for i = 1, #result do 
        local data = result[i]
        table.insert(options, {
            title = "[" .. tostring(data.id) .. "]" .. " " .. data.name,
            description = 'Manage Employees Take Home Vehicles',
            onSelect = function()
                lib.registerContext({
                    id = 'browns_jobgarage_plyoptions2',
                    title = "[" .. tostring(data.id) .. "]" .. " " .. data.name,
                    menu = 'browns_jobgarage_plyoptions',
                    options = {
                        {
                            title = 'Issue Vehicle',
                            description = 'Issue this employee a take home vehicle',
                            onSelect = function()
                                local options_2 = {}
                                for k, v in pairs(garage[data.job].vehicles) do 
                                    table.insert(options_2, {
                                        title = v.label,
                                        description = 'Issue' .. " " .. v.label .. " to" .. " " .. data.name,
                                        onSelect = function() 
                                            local bool, msg = lib.callback.await('browns:jg:server:IssueTakeHome', false, v.model, v.label, data.id, data.job)
                                            if not bool then 
                                                settings.notify('Job Garage', msg, 'error', 5000)
                                            else
                                                settings.notify('Job Garage', msg, 'success', 5000)
                                            end
                                        end
                                    })
                                end
                                lib.registerContext({
                                    id = 'browns_jobgarage_vehoptions',
                                    title = 'Select the vehicle to issue',
                                    menu = 'browns_jobgarage_plyoptions2',
                                    options = options_2
                                })
                                lib.showContext('browns_jobgarage_vehoptions')
                            end
                        },
                        {
                            title = 'Remove All Vehicles',
                            description = 'Remove all of employees take home vehicles',
                            onSelect = function()
                                local bool = lib.callback.await('browns:jg:server:WipeVehicles', false, data.id, data.job)
                                if bool then 
                                    settings.notify('Job Garage', 'Vehicle removals completed, The player can no longer store their take home vehicles and if they are already out they will be gone after next restart.', 'success', 20000)
                                else
                                    settings.notify('Job Garage', 'The person is not online, they must be only for you to do this!', 'error', 5000)
                                end
                            end
                        }
                    }
                })
                lib.showContext('browns_jobgarage_plyoptions2')
            end
        })
    end
    lib.registerContext({
        id = 'browns_jobgarage_plyoptions',
        title = 'Choose Employee',
        options = options
    })
    lib.showContext('browns_jobgarage_plyoptions')
end

function ViewThMenu(name)
    local bool, result = lib.callback.await('browns:jg:sever:ViewTHV', false, name)
    
    if not bool then 
        settings.notify('Job Garage', result, 'error', 5000)
    end

    if not result[1] then return end

    local myTh = {}

    for i = 1, #result do 
        local data = result[i] 
        table.insert(myTh, {
            title = data.label,
            description = 'Click to take this vehicle',
            onSelect = function()

                TriggerServerEvent('browns:jg:server:RemoveVehicle', data.model)

                if garage[name].customize.cosmetic or garage[name].customize.performance then 

                    SendNUIMessage({ 
                        type = 'customs',
                        cosmetic = garage[name].customize.cosmetic,
                        performance = garage[name].customize.performance,
                    })

                    thisModel = data.model 

                    
                    local model = GetHashKey(data.model)

                    if not IsModelInCdimage(model) then 
                        settings.notify('Job Garage', 'This vehicle is no longer in the server', 'error', 5000)
                        return 
                    end

                    SetNuiFocus(true, true)

                    SendNUIMessage({
                        type = 'progress'
                    })
                
                    RequestModel(model)

                    SendNUIMessage({
                        type = 'loading',
                        veh = data.label
                    })

                    while not HasModelLoaded(model) do 
                        Citizen.Wait(0)
                    end

                    SendNUIMessage({
                        type = 'hide_progress'
                    })

                    Vehicle = CreateVehicle(model, table.unpack({garage[name].location.displayCoords}), garage[name].location.displayHeading, false, false)

                    while not DoesEntityExist(Vehicle) do 
                        Citizen.Wait(0)
                    end

                    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, 6.0, 0.0))

                    local h = GetEntityHeading(Vehicle)

                    local oppH = h + 180.0 
                    if oppH > 360.0 then
                        oppH = oppH - 360.0
                    end

                    SetEntityCoords(cache.ped, x, y, z)

                    SetEntityHeading(cache.ped, oppH)

                    SetEntityVisible(cache.ped, false, false)

                    SetEntityInvincible(cache.ped, true)

                    Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
                    RenderScriptCams(true, true, 500)
            
                    SetCamCoord(Camera, x, y, z + 0.5) 
                    SetCamRot(Camera, table.unpack({GetEntityRotation(cache.ped)}), 2) 

                    SaveThis = true

                    NuiOpen = true 


                    SendNUIMessage({
                        type = 'takehome'
                    })

                    SetNuiFocus(true, true)
                else

                    local model = GetHashKey(data.model)

                    if not IsModelInCdimage(model) then 
                        settings.notify('Job Garage', 'This vehicle is no longer in the server', 'error', 5000)
                        return 
                    end


                    SendNUIMessage({
                        type = 'progress'
                    })

                    RequestModel(model)

                    SendNUIMessage({
                        type = 'loading',
                        veh = data.label
                    })

                    while not HasModelLoaded(model) do 
                        Citizen.Wait(0)
                    end

                    SendNUIMessage({
                        type = 'hide_progress'
                    })


                    local veh = CreateVehicle(model, table.unpack({garage[name].location.displayCoords}), garage[name].location.displayHeading, true, false)

                    while not DoesEntityExist(veh) do 
                        Citizen.Wait(0)
                    end

                    local props = lib.getVehicleProperties(veh)

                    SetPedIntoVehicle(cache.ped, veh, -1)

                    SetVehicleEngineOn(veh, true, false, false)

                    settings.notify('Job Garage', 'you took out the vehicle', 'success', 5000)

                    TriggerServerEvent('browns:jg:server:SaveVehicle', props, data.model, name)

                    Citizen.Wait(5000)

                end
            end

        })
    end

    lib.registerContext({
        id = 'browns_jobgarage_takehome',
        title = 'Select Take Home Vehicle',
        options = myTh
    })
    lib.showContext('browns_jobgarage_takehome')
end

function CycleVehicle(model, job) 
    
    thisModel = model 
    
    local hash = GetHashKey(model)

    RequestModel(hash)

    while not HasModelLoaded(hash) do 
        Citizen.Wait(0)
    end 

    Vehicle = CreateVehicle(hash, table.unpack({garage[job].location.displayCoords}), garage[job].location.displayHeading, false, false)

    while not DoesEntityExist(Vehicle) do 
        Citizen.Wait(0)
    end

    table.insert(Cache, {
        vehicle = Vehicle
    })

    SetVehicleEngineOn(Vehicle, false, true, true)

    FreezeEntityPosition(Vehicle, true)

    SetEntityInvincible(Vehicle, true)

    if not CamSet then 
        CamSet = true

        local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, 6.0, 0.0)) 
        local heading = GetEntityHeading(Vehicle)

        local oppH = heading + 180.0 
        if oppH > 360.0 then
            oppH = oppH - 360.0
        end

        local clone = ClonePed(cache.ped, false, false, false) 

        while not DoesEntityExist(clone) do 
            Citizen.Wait(0)
        end

        SetEntityVisible(clone, false, false) 

        SetEntityCoords(clone, x, y, z) 

        SetEntityHeading(clone, oppH) 

        FreezeEntityPosition(clone, true)
        SetEntityCollision(clone, false, false)
        SetEntityInvincible(clone, true)
        SetBlockingOfNonTemporaryEvents(clone, true)

        Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        RenderScriptCams(true, true, 500)

        local a, b, c = table.unpack(GetEntityCoords(clone)) 
        SetCamCoord(Camera, a, b, c + 0.5) 
        SetCamRot(Camera, table.unpack({GetEntityRotation(clone)}), 2) 

        DeleteEntity(clone) 
        
    end

    SetVehicleModKit(Vehicle, 0) 

    local vData = GetVehicleData(Vehicle) 

    SendNUIMessage({ 
        type = 'data',
        data = GetVehicleData(Vehicle)
    })

    SendNUIMessage({ 
        type = 'customs',
        cosmetic = garage[job].customize.cosmetic,
        performance = garage[job].customize.performance,
    })

    if not NuiOpen then 

        NuiOpen = true 


        for i = 1, #vehicles do 
            local data = vehicles[i]
            if data.model ~= nil then 
                SendNUIMessage({ 
                    type = 'vehicles',
                    model = data.model,
                    label = data.label,
                    job = job,
                    count = #vehicles
                })
            end
        end

        SetNuiFocus(true, true)

    end

    if not ControlSlide then 

        local this = Vehicle

        Citizen.CreateThread(function() 
            while this and this == Vehicle and not ControlSlide do 
                Citizen.Wait(0)
                local h = GetEntityHeading(Vehicle)
                SetEntityHeading(Vehicle, h + 1.0) 
            end
        end)

    end

end

RegisterNUICallback('ChangeVehicle', function(data) 
    DeleteEntity(Vehicle) 
    CycleVehicle(data.model, data.job) 
end)

function GetVehicleData(vehicle) 
    local VehData = {}

    VehData['engine'] = GetNumVehicleMods(vehicle, 11)
    VehData['armor'] = GetNumVehicleMods(vehicle, 16)
    VehData['suspen'] = GetNumVehicleMods(vehicle, 15)
    VehData['turbo'] = 1
    VehData['gear'] = GetNumVehicleMods(vehicle, 13)
    VehData['wheel'] = GetNumVehicleMods(vehicle, 23)
    VehData['xenon'] = 1
    VehData['brakes'] = GetNumVehicleMods(vehicle, 12)
    VehData['tints'] = 7
    VehData['livery'] = GetVehicleLiveryCount(vehicle)

    return VehData

end
    
RegisterNUICallback('ChangeExtra', function(data) 
    if DoesExtraExist(Vehicle, tonumber(data.extra)) then 
        if data.toggle then 
            SetVehicleExtra(Vehicle, tonumber(data.extra), 0)
        else
            SetVehicleExtra(Vehicle, tonumber(data.extra), 1)
        end
    end
end)

RegisterNUICallback('ChangeMod', function(data) 
    if data.mod == 'engine' then 
        SetVehicleMod(Vehicle, 11, data.int, false)
    end
    if data.mod == 'armor' then 
        SetVehicleMod(Vehicle, 16, data.int, false)
    end
    if data.mod == 'suspen' then 
        SetVehicleMod(Vehicle, 15, data.int, false)
    end
    if data.mod == 'turbo' then 
        if tonumber(data.int) == 1 then 
            ToggleVehicleMod(Vehicle, 18, true)
        elseif tonumber(data.int) == 0 then 
            ToggleVehicleMod(Vehicle, 18, false)
        end
    end
    if data.mod == 'gear' then 
        SetVehicleMod(Vehicle, 13, data.int, false)
    end
    if data.mod == 'wheel' then 
        SetVehicleMod(Vehicle, 23, data.int, false)
    end
    if data.mod == 'xenon' then 
        if tonumber(data.int) == 1 then 
            ToggleVehicleMod(Vehicle, 22, true)
        elseif tonumber(data.int) == 0 then 
            ToggleVehicleMod(Vehicle, 22, false)
        end
    end
    if data.mod == 'steer' then 
        SetVehicleMod(Vehicle, 33, data.int, false)
    end
    if data.mod == 'brakes' then 
        SetVehicleMod(Vehicle, 12, data.int, false)
    end
    if data.mod == 'tints' then 
        SetVehicleWindowTint(Vehicle, data.int)
    end
    if data.mod == 'livery' then
        SetVehicleLivery(Vehicle, data.int)
    end
end)

RegisterNUICallback('ChangeMaterial', function(data) 
    if data.type == 'primary' then 
        PrimaryMat = data.material 
    end

    if data.type == 'secondary' then 
        SecondaryMat = data.material 
    end
end)

RegisterNUICallback('ChangeColor', function(data) 

    if data.type == 'primary' then 
        SetVehicleModColor_1(Vehicle, Materials[PrimaryMat], data.rgb, 0)
    end

    if data.type == 'secondary' then 
        SetVehicleModColor_2(Vehicle, Materials[SecondaryMat], data.rgb, 0)
    end

end)

RegisterNUICallback('Close', function() 
    Busy = false
    NuiOpen = false
    SetEntityVisible(cache.ped, true, true)
    SetEntityInvincible(cache.ped, false)

    DeleteEntity(Vehicle)

    SetNuiFocus(false, false)

    RenderScriptCams(false, true, 500)
    DestroyCam(Camera, false)

    ResetAll()
    ClearCache()
end)

RegisterNUICallback('Continue', function() 
    Busy = false
    NuiOpen = false
    local props = lib.getVehicleProperties(Vehicle) 

    DeleteEntity(Vehicle) 

    SetNuiFocus(false, false) 

    local model = GetHashKey(thisModel) 

    RequestModel(model)

    while not HasModelLoaded(model) do 
        Citizen.Wait(0)
    end

    local veh = CreateVehicle(model, table.unpack({garage[thisJob].location.spawnCoords}), true, false)

    while not DoesEntityExist(veh) do 
        Citizen.Wait(0)
    end

    lib.setVehicleProperties(veh, props)

    SetEntityVisible(cache.ped, true, true)
    SetEntityInvincible(cache.ped, false)

    SetPedIntoVehicle(cache.ped, veh, -1)

    SetVehicleEngineOn(veh, true, false, false) 

    RenderScriptCams(false, true, 500)

    DestroyCam(Camera, false) 

    settings.givekeys(veh, GetVehicleNumberPlateText(veh)) 

    if SaveThis then 
        SaveThis = false
        TriggerServerEvent('browns:jg:server:SaveVehicle', props, thisModel, thisJob)
    end

    ResetAll() 

    ClearCache() 

    settings.notify('Job Garage', 'You took out the vehicle', 'success', 5000) 

    Citizen.Wait(5000)

end)

function ResetAll() 
    CamSet = false
    Camera = nil
    Vehicle = nil
    vehicles = {}
    thisModel = nil
    PrimaryMat = 'Metallic'
    SecondaryMat = 'Metallic'
end

function ClearCache()
    for _, v in ipairs(Cache) do 
        if DoesEntityExist(v.vehicle) then 
            DeleteEntity(v.vehicle)
        end
    end

    Cache = {}
end

RegisterNUICallback('ControlSlide', function(data)
    ControlSlide = data.toggle 
end)

RegisterNUICallback('Slide', function(data)

    doSlide = data.toggle

    if data.type == '+' then 
        while doSlide and data.type == '+' do 
            Citizen.Wait(0)
            SetEntityHeading(Vehicle, GetEntityHeading(Vehicle) + 5.0)
        end
    end

    if data.type == '-' then 
        while doSlide and data.type == '-' do 
            Citizen.Wait(0)
            SetEntityHeading(Vehicle, GetEntityHeading(Vehicle) - 5.0)
        end
    end
end)
