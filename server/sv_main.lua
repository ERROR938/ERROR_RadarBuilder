local radars = {}

RegisterNetEvent("ERROR_RadarBuilder:CreateRadar", function(data)
    local radar = MySQL.query.await("INSERT INTO radars (`position`, `mph`, `name`) VALUES (?, ?, ?)", {json.encode(data.position), data.mph, data.name})
    data.id = radar.insertId
    radars[radar.insertId] = data
    TriggerClientEvent("ERROR_RadarBuilder:UpdateRadars", -1, radars)
end)