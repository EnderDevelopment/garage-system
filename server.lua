local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('garage:getVehicles', function(source, cb, garageName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchAll('SELECT * FROM garage_vehicles WHERE owner = @owner AND garage_name = @garage_name AND stored = TRUE', {
        ['@owner'] = identifier,
        ['@garage_name'] = garageName
    }, function(result)
        local vehicles = {}

        for _, row in ipairs(result) do
            table.insert(vehicles, { plate = row.plate, vehicle_model = row.vehicle_model })
        end

        cb(vehicles)
    end)
end)

ESX.RegisterServerCallback('garage:spawnVehicle', function(source, cb, plate, garageName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM garage_vehicles WHERE plate = @plate AND owner = @owner AND garage_name = @garage_name AND stored = TRUE', {
        ['@plate'] = plate,
        ['@owner'] = identifier,
        ['@garage_name'] = garageName
    }, function(count)
        if count > 0 then
            MySQL.Async.execute('UPDATE garage_vehicles SET stored = FALSE WHERE plate = @plate AND owner = @owner AND garage_name = @garage_name', {
                ['@plate'] = plate,
                ['@owner'] = identifier,
                ['@garage_name'] = garageName
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('garage:storeVehicle')
AddEventHandler('garage:storeVehicle', function(plate, garageName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.execute('UPDATE garage_vehicles SET stored = TRUE WHERE plate = @plate AND owner = @owner AND garage_name = @garage_name', {
        ['@plate'] = plate,
        ['@owner'] = identifier,
        ['@garage_name'] = garageName
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', source, 'Vehicle stored successfully')
        else
            TriggerClientEvent('esx:showNotification', source, 'Failed to store vehicle')
        end
    end)
end)