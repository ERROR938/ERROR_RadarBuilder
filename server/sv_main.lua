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

RegisterNetEvent('ERROR_RadarBuilder:sendBill', function(playerId, sharedAccountName, label, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	amount = ESX.Math.Round(amount)

	if amount > 0 and xTarget then
		if string.match(sharedAccountName, "society_") then
			TriggerEvent('esx_addonaccount:getSharedAccount', sharedAccountName, function(account)
				if account then
					MySQL.insert('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {xTarget.identifier, xPlayer.identifier, 'society', sharedAccountName, label, amount},
					function(rowsChanged)
						xTarget.showNotification(_U('received_invoice'))
					end)
				else
					print(("[^2ERROR^7] Player ^5%s^7 Attempted to Send bill from invalid society - ^5%s^7"):format(xPlayer.source, sharedAccountName))
				end
			end)
		else
			MySQL.insert('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {xTarget.identifier, xPlayer.identifier, 'player', xPlayer.identifier, label, amount},
			function(rowsChanged)
				xTarget.showNotification(_U('received_invoice'))
			end)
		end
	end
end)