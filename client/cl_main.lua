local radars = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    ESX.PLayerData = playerData
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
                })
                if (not input) then
                    ESX.ShowNotification(_U('creation_aborded'), "error")
                    return false 
                end
                radar.name = input[1]
                radar.mph = input[2]
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
    radars = list
end)