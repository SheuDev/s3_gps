ESX = nil
bliptable = {}
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterUsableItem("gps", function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer.job.name == Config.Job1 or xPlayer.job.name == Config.Job2 then
        TriggerClientEvent('s3_gps:ac', src)
    end
end)

RegisterServerEvent("s3_gps:server:openGPS")
AddEventHandler("s3_gps:server:openGPS", function(code)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier
    })
    table.insert(bliptable, {firstname = result[1].firstname, lastname = result[1].lastname, src = src, job = xPlayer.job.name, code = code})
end)

RegisterServerEvent("s3_gps:server:closeGPS")
AddEventHandler("s3_gps:server:closeGPS", function()
    local src = source
    for k = 1, #bliptable, 1 do
        TriggerClientEvent("s3_gps:client:removeBlip", bliptable[k].src, tonumber(src))
    end
    for i = 1, #bliptable, 1 do
        if bliptable[i].src == tonumber(src) then
            table.remove(bliptable, i)
            return
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if #bliptable > 0 then
            for i = 1, #bliptable, 1 do
                local player = GetPlayerPed(bliptable[i].src)
                local coord = GetEntityCoords(player)
                for k = 1, #bliptable, 1 do
                    TriggerClientEvent("s3_gps:client:getPlayerInfo", bliptable[k].src, {
                        coord = coord,
                        job = bliptable[i].job,
                        src = tonumber(bliptable[i].src),
                        text = "["..bliptable[i].code.."] "..bliptable[i].firstname.." "..bliptable[i].lastname,
                    })
                end
            end
        end
    end
end)

AddEventHandler("esx:onRemoveInventoryItem", function(source, item, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    TriggerClientEvent("s3_gps:client:closed", src)
	if item == "gps" and count < 1 then
		for k = 1, #bliptable, 1 do
            TriggerClientEvent("s3_gps:client:removeBlip", bliptable[k].src, tonumber(src))
            TriggerClientEvent("s3_gps:client:removeBlip", src, tonumber(bliptable[k].src))
        end
        for i = 1, #bliptable, 1 do
            if bliptable[i].src == src then
                table.remove(bliptable, i)
            end
        end
	end
end)

AddEventHandler("playerDropped", function()
    local src = source
    removeBlip(src)
    removeBlip2(src)
end)

function removeBlip(src)
    for k = 1, #bliptable, 1 do
        TriggerClientEvent("s3_gps:client:removeBlip", bliptable[k].src, tonumber(src))
        return
    end
end

function removeBlip2(src)
    for i = 1, #bliptable, 1 do
        if bliptable[i].src == src then
            table.remove(bliptable, i)
            return
        end
    end
end