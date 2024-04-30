local FRAMEWORK = nil
if KOJA.Framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) FRAMEWORK = obj end)
elseif KOJA.Framework == "qb" then
    TriggerEvent('QBCore:GetObject', function(obj) FRAMEWORK = obj end)
elseif KOJA.Framework == "newesx" then
    FRAMEWORK = exports['es_extended']:getSharedObject()
end

local cooldownTriggers = {}


FRAMEWORK.RegisterServerCallback('koja-crafting:getPlayerDetails', function(source, cb)
    local xPlayer = nil
    if KOJA.Framework == 'esx' then
        xPlayer = FRAMEWORK.GetPlayerFromId(source)
    elseif KOJA.Framework == 'qb' then
        xPlayer = FRAMEWORK.Functions.GetPlayer(source)
    end
    local items     = {}
    local inventory = exports.ox_inventory:GetInventoryItems(source)
    for i, item in pairs(inventory) do
        if item.count > 0 then
            table.insert(items, {
                label     = item.label,
                amount    = item.count,
                name      = item.name,
            })
        end
    end
    local callbackData = {}
    local result = ExecuteSql("SELECT * FROM koja_crafting WHERE playerid = '"..xPlayer.uid.."'")
    if result[1] == nil then    
        ExecuteSql("INSERT INTO koja_crafting SET playerid = '"..xPlayer.uid.."', currentXP = '0'")
        callbackData = {
            currentXP = 0,
            inventory = items
        }
    else
        callbackData = {
            currentXP = result[1].currentXP,
            inventory = items
        }
    end
    cb(callbackData)
end)

FRAMEWORK.RegisterServerCallback('koja-crafting:craftitem', function(source, cb, data)
    local src = source
    local xPlayer = nil
    if KOJA.Framework == 'esx' then
        xPlayer = FRAMEWORK.GetPlayerFromId(src)
    elseif KOJA.Framework == 'qb' then
        xPlayer = FRAMEWORK.Functions.GetPlayer(src)
    end

    for i, item in ipairs(data.requireditemResp) do
        local count = data.requireditemCount[i]
        exports.ox_inventory:RemoveItem(src, item, count)
    end

    cb({
        inventory = inventoryItems 
    })
end)

FRAMEWORK.RegisterServerCallback('koja-crafting:additem', function(source, cb, data)
    local src = source
    local xPlayer = nil
    if KOJA.Framework == 'esx' then
        xPlayer = FRAMEWORK.GetPlayerFromId(src)
    elseif KOJA.Framework == 'qb' then
        xPlayer = FRAMEWORK.Functions.GetPlayer(src)
    end

    exports.ox_inventory:AddItem(src, data.itemResp, data.itemCount)
end)



RegisterNetEvent('koja-crafting:addXP')
AddEventHandler('koja-crafting:addXP', function(src, amount)
    local xPlayer = nil
    if KOJA.Framework == 'esx' then
        xPlayer = FRAMEWORK.GetPlayerFromId(src)
    elseif KOJA.Framework == 'qb' then
        xPlayer = FRAMEWORK.Functions.GetPlayer(src)
    end

    for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
           license = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
           identifier = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
           discord = v
        end
     end
    local xp_toadd = tonumber(amount)
    if xp_toadd >= 500 then
        print("^5[KOJA_CRAFTING]^7 ID:"..src.." ^8IS PROBABLY CHEATING - CHECK KOJA LOGS^7")
        SendLog(src, 'PLAYER GOT FLAGGED DUE TO SUSPICIOUS ACTIONS IN RESOURCE ``KOJA_CRAFTING`` \n Player tried to give himself OVERLIMIT XP" '..xp_toadd..' ','||``'..identifier..' \n'..license..' \n'..discord..'\nName:'..GetPlayerName(src)..'``||', 15548997)
        return
    end
     ExecuteSql("UPDATE koja_crafting SET currentXP = currentXP + '"..xp_toadd.."' WHERE playerid = '"..xPlayer.uid.."'")
     SendLog(src, 'PLAYER REEDEMED '..xp_toadd..'XP ', '||``'..identifier..' \n'..license..' \n'..discord..'\nName:'..GetPlayerName(src)..'``||', 5763719)
      
end)

function checkInventory(eq, itemList)
    local result = {}

    for k, required in ipairs(itemList) do
        local itemFound = false

        for k, item in ipairs(eq) do
            if item.item == required.items and item.count >= required.count then
                itemFound = true
                break
            end
        end

        table.insert(result, { item = required.items, isAvailable = itemFound })
    end

    return result
end

function ExecuteSql(query)
    local IsBusy = true
    local result = nil
    if KOJA.Database == "oxmysql" then
       if MySQL == nil then
          exports.oxmysql:execute(query, function(data)
          result = data
          IsBusy = false
          end)
       else
          MySQL.query(query, {}, function(data)
          result = data
          IsBusy = false
          end)
       end
    elseif KOJA.Database == "ghmattimysql" then
       exports.ghmattimysql:execute(query, {}, function(data)
       result = data
       IsBusy = false
       end)
    elseif KOJA.Database == "mysql-async" then
       MySQL.Async.fetchAll(query, {}, function(data)
       result = data
       IsBusy = false
       end)
    end
    while IsBusy do
       Citizen.Wait(0)
    end
    return result
 end

print(WebhookSupportURL)

SendLog = function(source, text, title, color)
    local _source = source
    local xPlayer = nil
    if KOJA.Framework == 'esx' then
        xPlayer = GetPlayerFromId(_source)
    elseif KOJA.Framework == 'qb' then
        xPlayer = GetPlayer(_source)
    end

    local embed = {
       {
          ["avatar_url"] = WebhookAvatarURL,
          ["username"] = WebhookUsername,
          ["author"] = {
             ["name"] = WebhookUsername .. " | CLICK FOR SUPPORT",
             ["url"] = WebhookSupportURL,
             ["icon_url"] = WebhookAvatarURL,
          },
          ["color"] = color,
          ["title"] = title,
          ["description"] = text,
          ["type"]= "rich",
          ["footer"] = {
             ["text"] = os.date() .. " | KOJA-SCRIPTS - Logs System",
             ["icon_url"] = WebhookAvatarURL,
          },
       }
    }

    PerformHttpRequest(WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = WebhookUsername, avatar_url = WebhookAvatarURL, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
