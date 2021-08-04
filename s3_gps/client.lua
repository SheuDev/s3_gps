ESX = nil
gps = false
blips = {}

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

RegisterNetEvent('s3:gps:client:Used')
AddEventHandler('s3:gps:client:Used', function()
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
                ESX.ShowNotification("GPS'te görünmesini istediğiniz kodunuzu giriniz!")
                DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 30)
                while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0)
                    TriggerEvent('m3:invUseable', false)
                    Wait(0)
                end
                if (GetOnscreenKeyboardResult()) then
                    code = GetOnscreenKeyboardResult()
                    TriggerEvent('m3:invUseable', true)
                end
                if code == '' then
                    ESX.ShowNotification("GPS kodunuz boş olamaz!")
                else
                    gps = true
                    TriggerServerEvent('s3:gps:server:openGPS', code)
                    ESX.ShowNotification("GPS'iniz açıldı!")
                    Citizen.Wait(100)
                end
            else
                ESX.ShowNotification("GPS'iniz zaten açık!")
            end
        elseif data.current.value == 'gpsoff' then
            if gps then
                gps = false
                TriggerServerEvent('s3:gps:server:closeGPS')
                ESX.ShowNotification("GPS'iniz kapatıldı!")
            else
                ESX.ShowNotification("GPS'iniz zaten kapalı!")
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

RegisterNetEvent("s3_gps:client:getPlayerInfo")
AddEventHandler("s3_gps:client:getPlayerInfo", function(table)
    local veh = nil
    local move = nil
    local heli = nil
    if GetPlayerServerId(PlayerId()) ~= table.src then
        if DoesBlipExist(blips[table.src]) then
            RemoveBlip(blips[table.src])
        end
        if IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(table.src)), true) then
            veh = true
        else
            veh = false
        end
        if IsVehicleSirenOn(GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(table.src)), true)) then
            move = true
        else
            move = false
        end
        if IsPedInFlyingVehicle(GetPlayerPed(GetPlayerFromServerId(table.src))) then
            heli = true
        else
            heli = false
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

RegisterNetEvent("s3_gps:client:removeBlip")
AddEventHandler("s3_gps:client:removeBlip", function(src)
    local blip = blips[src]
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
        blips[src] = nil
    end
end)