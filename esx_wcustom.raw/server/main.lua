ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Vehicles = nil

RegisterServerEvent('esx_wcustom:buyMod')
AddEventHandler('esx_wcustom:buyMod', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	price = tonumber(price)

	if Config.IsMechanicJobOnly then

		local societyAccount = nil
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_wcustom', function(account)
			societyAccount = account
		end)
		if price < societyAccount.money then
			TriggerClientEvent('esx_wcustom:installMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('purchased'))
			societyAccount.removeMoney(price)
		else
			TriggerClientEvent('esx_wcustom:cancelInstallMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
		end

	else

		if price < xPlayer.getMoney() then
			TriggerClientEvent('esx_wcustom:installMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('purchased'))
			xPlayer.removeMoney(price)
		else
			TriggerClientEvent('esx_wcustom:cancelInstallMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
		end

	end
end)

RegisterServerEvent('esx_wcustom:refreshOwnedVehicle')
AddEventHandler('esx_wcustom:refreshOwnedVehicle', function(myCar)
	MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)

ESX.RegisterServerCallback('esx_wcustom:getVehiclesPrices', function(source, cb)
	if Vehicles == nil then
		MySQL.Async.fetchAll('SELECT * FROM vehiclesaddon', {}, function(result)
			local vehicles = {}

			for i=1, #result, 1 do
				table.insert(vehicles, {
					model = result[i].model,
					price = result[i].price
				})
			end

			Vehicles = vehicles
			cb(Vehicles)
		end)
	else
		cb(Vehicles)
	end
end)