local ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, garage in ipairs(Config.Garages) do
            local distance = #(playerCoords - garage.coords)

            if distance < Config.DrawDistance then
                DrawMarker(Config.MarkerType, garage.coords.x, garage.coords.y, garage.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)

                if distance < 1.5 then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to access the garage')

                    if IsControlJustReleased(0, 38) then
                        OpenGarageMenu(garage.name)
                    end
                end
            end
        end
    end
end)

function OpenGarageMenu(garageName)
    local elements = {}

    ESX.TriggerServerCallback('garage:getVehicles', function(vehicles)
        for _, vehicle in ipairs(vehicles) do
            table.insert(elements, { label = vehicle.plate .. ' - ' .. vehicle.vehicle_model, value = vehicle.plate })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
            title = garageName,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            SpawnVehicle(data.current.value, garageName)
        end, function(data, menu)
            menu.close()
        end)
    end, garageName)
end

function SpawnVehicle(plate, garageName)
    ESX.TriggerServerCallback('garage:spawnVehicle', function(spawned)
        if spawned then
            ESX.ShowNotification('Vehicle spawned successfully')
        else
            ESX.ShowNotification('Failed to spawn vehicle')
        end
    end, plate, garageName)
end