local radars = {}

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    MySQL.query("SELECT * FROM radars", function(res)
        for k,v in pairs(res) do
            v.position = json.decode(v.position)
            v.heading = json.decode(v.heading)
            radars[v.id] = v
        end
    end)
end)

RegisterNetEvent("ERROR_RadarBuilder:CreateRadar", function(data)
    local radar = MySQL.query.await("INSERT INTO radars (`position`, `heading`, `view`, `mph`, `name`) VALUES (?, ?, ?, ?, ?)", {json.encode(data.position), json.encode(data.heading), data.view, data.mph, data.name})
    data.id = radar.insertId
    radars[radar.insertId] = data
    TriggerClientEvent("ERROR_RadarBuilder:UpdateRadars", -1, radars)
end)

ESX.RegisterServerCallback("ERROR_RadarBuilder:GetRadars", function(source, cb) 
    cb(radars)
end)

RegisterNetEvent("ERROR_RadarBuilder:EditRadarData", function(id, key, val)
    if (key ~= "delete") then
        local req = ("UPDATE radars SET `%s` = ? WHERE id = ?"):format(key)
        MySQL.query(req, {val, id})
        radars[id][key] = val
    else
        MySQL.query("DELETE FROM radars WHERE `id` = ?", {id})
        radars[id] = nil
    end
    TriggerClientEvent("ERROR_RadarBuilder:UpdateRadars", -1, radars)
end)

ESX.RegisterUsableItem("coyote", function(source)
    TriggerClientEvent("ERROR_RadarBuilder:Displaycoyote", source)
end)