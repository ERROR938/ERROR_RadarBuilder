local radars = {}

local function InitAllProps(r)
    for k,v in pairs(r) do
        ESX.Game.SpawnObject("prop_cctv_pole_01a", vec3(v.position.x, v.position.y, v.position.z-7), function(ent)
            print(ent)
            radars[k].ent = ent
        end)
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    ESX.PLayerData = playerData
    ESX.TriggerServerCallback("ERROR_RadarBuilder:GetRadars", function(radarss)
        TriggerEvent("ERROR_RadarBuilder:UpdateRadars", radarss)
        InitAllProps(radarss)
    end)
end)

RegisterNetEvent("esx:setJob", function(job)
    ESX.PLayerData.job = job
end)

local function IsPlayerAllowed()
    if (not ESX.PlayerData.job) then return false end
    for k,v in pairs(Config.Jobs) do
        if (ESX.PLayerData.job.name == v) then return true end
    end
    return false
end

local function SearchClosestRadar()
    local last_dst = 20000
    local dst, t_pos, r_id
    local pos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(radars) do
        t_pos = vec3(v.position.x, v.position.y, v.position.z)
        dst = #(pos - t_pos)
        if (#(pos - t_pos) < last_dst) then 
            last_dst = dst
            r_id = v.id
        end
    end
    return r_id, dst
end

lib.registerContext({
    id = 'radar_menu',
    title = _U('radars'),
    options = {
        {
            title = _U('create_radar'),
            description = '',
            onSelect = function(args)
                local radar = {}
                local input = lib.inputDialog('', {
                    { type = 'input', label = _U('r_name'), placeholder = _U('rph')},
                    {type = 'number', label = _U('max_vit'), placeholder = 130, min = 1},
                    { type = 'number', label = _U('flash_dst'), placeholder = 10, min = 1},
                })
                if (not input) then
                    ESX.ShowNotification(_U('creation_aborded'), "error")
                    return false 
                end
                radar.name = input[1]
                radar.mph = input[2]
                radar.heading = GetEntityRotation(PlayerPedId())
                radar.view = input[3]
                radar.position = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("ERROR_RadarBuilder:CreateRadar", radar)
                radar = {}
            end
        },
    },
})

RegisterCommand(Config.CommandName, function(_, args)
    lib.showContext("radar_menu")
end)

RegisterNetEvent("ERROR_RadarBuilder:UpdateRadars", function(list)
    for k,v in pairs(radars) do
        DeleteEntity(radars[k].ent)
    end
    radars = list
    InitAllProps(radars)
end)

if (Config.Debug) then
    RegisterCommand("loadradars", function()
        ESX.TriggerServerCallback("ERROR_RadarBuilder:GetRadars", function(radars)
            TriggerEvent("ERROR_RadarBuilder:UpdateRadars", radars)
        end)
    end)
end

CreateThread(function()
    local msec
    local las_veh
    while (function()
        msec = 1000
        local playerPed = PlayerPedId()
        if (not IsPedInAnyVehicle(playerPed)) then return true end
        local r_id, r_dst = SearchClosestRadar()
        if (not r_id) then return true end
        if (r_dst > Config.LoadZone) then return true end
        msec = 0
        
        local point = vec3(radars[r_id].position.x, radars[r_id].position.y, radars[r_id].position.z)
        local rotation = vec3(radars[r_id].heading.x, radars[r_id].heading.y, radars[r_id].heading.z)
        local distance = ToFloat(radars[r_id].view)
        local hit, endCoords, surfaceNormal, entityHit = RaycastFromPoint(point, rotation, distance)
        if hit then
            if entityHit and entityHit > 0 then
                local vit = GetEntitySpeed(entityHit) * 3.6
                if ((vit > radars[r_id].mph) and not (entityHit == las_veh)) then
                    local driver = GetPedInVehicleSeat(entityHit, -1)
                    if (IsPedAPlayer(driver)) then
                        ESX.ShowNotification(("📸 : Vous avez été flashé à %s km/h au lieu de %s km/h."):format(math.floor(vit), radars[r_id].mph))
                    end
                    las_veh = entityHit
                    SetTimeout(5000, function()
                        las_veh = nil
                    end)
                end
            end
        end
        return true
    end) () do
        Wait(msec)
    end
end)