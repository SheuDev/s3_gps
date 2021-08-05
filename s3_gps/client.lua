ESX, gps, blips = nil, false, {}
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

RegisterNetEvent('s3:gps:client:use')
AddEventHandler('s3:gps:client:use', function()
    local elements = {}
	table.insert(elements, {label = 'GPS Aç', value = 'gpson'})
	table.insert(elements, {label = 'GPS Kapat', value = 'gpsoff'})
    ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gps', {
		title    = 'GPS',
		align    = 'right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'gpson' then
			if not gps then
                ESX.UI.Menu.CloseAll()
                ESX.ShowNotification("Enter your code that you want to appear on the GPS!")
                DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 30)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0)
                    Wait(0)
                end
                if (GetOnscreenKeyboardResult()) then
                    code = GetOnscreenKeyboardResult()
                end
                if code == '' then
                    ESX.ShowNotification("Your GPS code cannot be blank!")
                else
                    gps = true
                    TriggerServerEvent('s3:gps:server:openGPS', code)
                    ESX.ShowNotification("Your GPS is turned on!")
                    Citizen.Wait(100)
                end
            else
                ESX.ShowNotification("Your GPS is turned on!")
            end
        elseif data.current.value == 'gpsoff' then
            if gps then
                gps = false
                TriggerServerEvent('s3:gps:server:closeGPS')
                ESX.ShowNotification("Your GPS is turned off!")
            else
                ESX.ShowNotification("Your GPS is already turned off!")
            end
		end
	end, function(data, menu)
		menu.close()
	end)
end)

RegisterNetEvent('s3:gps:client:closed')
AddEventHandler('s3:gps:client:closed', function()
    gps = false
end)

RegisterNetEvent("s3:gps:client:getPlayerInfo")
AddEventHandler("s3:gps:client:getPlayerInfo", function(table)
    local veh = IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(table.src)), true)
    local move = IsVehicleSirenOn(GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(table.src)), true))
    local heli = IsPedInFlyingVehicle(GetPlayerPed(GetPlayerFromServerId(table.src)))
    if GetPlayerServerId(PlayerId()) ~= table.src then
        if DoesBlipExist(blips[table.src]) then
            RemoveBlip(blips[table.src])
        end
        blips[table.src] = AddBlipForCoord(table.coord.x, table.coord.y, table.coord.z)
        if not move and not veh and not heli then
            SetBlipSprite(blips[table.src], 373)
        elseif veh and not heli and not move then
            SetBlipSprite(blips[table.src], 373)
        elseif move and veh and not heli then
            SetBlipSprite(blips[table.src], 42)
        elseif heli and not move and veh then
            SetBlipSprite(blips[table.src], 15)
        end
        if not move and not veh and not heli then
            SetBlipColour(blips[table.src], 63)
        elseif veh and not heli and not move then
            SetBlipColour(blips[table.src], 63)
        elseif move and veh and not heli then
            SetBlipColour(blips[table.src], 0)
        elseif heli and not move and veh then
            SetBlipColour(blips[table.src], 0)
        end
        SetBlipScale(blips[table.src], 0.7)
        SetBlipAsShortRange(blips[table.src], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(table.text)
        EndTextCommandSetBlipName(blips[table.src])
    end
end)

RegisterNetEvent("s3:gps:client:removeBlip")
AddEventHandler("s3:gps:client:removeBlip", function(src)
    local blip = blips[src]
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
        blips[src] = nil
    end
end)
