Koja = {}
Koja.Framework = Utils.Functions.GetFramework()
Koja.Utils = Utils.Functions
Koja.Server = {
    MySQL = {
        Async = {},
        Sync = {}
    }
}
Koja.Callbacks = {}
Koja.Server.RegisterServerCallback = function(key, func)
    Koja.Callbacks[key] = func
end

CreateThread(function()
    while Koja.Framework == nil do
        Koja.Framework = Utils.Functions.GetFramework()
        Wait(15)
    end
end)

RegisterNetEvent("koja-crafting:Server:HandleCallback", function(key, payload)
    local src = source
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("koja-crafting:Client:HandleCallback", src, key, cb)
        end)
    end
end)

Koja.Server.GetPlayerBySource = function(source)
    if Config.Framework == "esx" then
        return Koja.Framework.GetPlayerFromId(source)
    elseif Config.Framework == "qb" then
        return Koja.Framework.Functions.GetPlayer(source)
    end
end

local cooldownTriggers = {}

Koja.Server.RegisterServerCallback('koja-crafting:getPlayerDetails', function(source, payload, cb)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    local identifier = nil

    if Config.Framework == "esx" then
        identifier = xPlayer.identifier 
    elseif Config.Framework == "qb" then
        identifier = xPlayer.PlayerData.license
    end

    local items = {}
    local inventory = exports.ox_inventory:GetInventoryItems(source)

    for i, item in pairs(inventory) do
        if item.count > 0 then
            table.insert(items, {
                label = item.label,
                amount = item.count,
                name = item.name,
            })
        end
    end

    local callbackData = {}
    local result = ExecuteSql("SELECT * FROM koja_crafting WHERE playerid = '" .. identifier .. "'")
    if not result or #result == 0 then    
        ExecuteSql("INSERT INTO koja_crafting SET playerid = '" .. identifier .. "', currentXP = '0'")
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

    if type(cb) == 'function' then
        cb(callbackData)
    else
        print("Error: Provided 'cb' is not a function, it is a " .. type(cb))
    end
end)



Koja.Server.RegisterServerCallback('koja-crafting:craftitem', function(source, data, cb)
    local xPlayer = Koja.Server.GetPlayerBySource(source)
    if not data or type(data) ~= 'table' then
        print("Error: Missing or incorrect data for crafting items")
        return
    end

    local inventoryItems = {} 

    for i, item in ipairs(data.requireditemResp or {}) do
        local count = data.requireditemCount[i] or 0
        exports.ox_inventory:RemoveItem(source, item, count)
    end

    if type(cb) == 'function' then
        cb({ inventory = inventoryItems })
    else
        print("Error: Callback function is missing or not a function")
    end
end)


Koja.Server.RegisterServerCallback('koja-crafting:additem', function(source, data, cb)
    local xPlayer = Koja.Server.GetPlayerBySource(source)

    if not data or type(data) ~= 'table' then
        print("Error: Missing or incorrect data for adding items")
        return
    end

    exports.ox_inventory:AddItem(source, data.itemResp, data.itemCount)

    if type(cb) == 'function' then
        cb({success = true}) 
    else
        print("Error: Callback function is missing or not a function")
    end
end)



RegisterNetEvent('koja-crafting:addXP')
AddEventHandler('koja-crafting:addXP', function(source, amount)
    local xPlayer = Koja.Server.GetPlayerBySource(source)

    for k,v in ipairs(GetPlayerIdentifiers(source))do
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
        print("^5[Config_CRAFTING]^7 ID:"..source.." ^8IS PROBABLY CHEATING - CHECK Config LOGS^7")
        SendLog(source, 'PLAYER GOT FLAGGED DUE TO SUSPICIOUS ACTIONS IN RESOURCE ``Config_CRAFTING`` \n Player tried to give himself OVERLIMIT XP" '..xp_toadd..' ','||``'..identifier..' \n'..license..' \n'..discord..'\nName:'..GetPlayerName(source)..'``||', 15548997)
        return
    end
        ExecuteSql("UPDATE koja_crafting SET currentXP = currentXP + '"..xp_toadd.."' WHERE playerid = '"..xPlayer.uid.."'")
        SendLog(source, 'PLAYER REEDEMED '..xp_toadd..'XP ', '||``'..identifier..' \n'..license..' \n'..discord..'\nName:'..GetPlayerName(source)..'``||', 5763719)
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
    if Config.Database == "oxmysql" then
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
    elseif Config.Database == "ghmattimysql" then
        exports.ghmattimysql:execute(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    elseif Config.Database == "mysql-async" then
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

SendLog = function(source, text, title, color)
    local xPlayer = Koja.Server.GetPlayerBySource(source)

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
                ["text"] = os.date() .. " | Koja-SCRIPTS - Logs System",
                ["icon_url"] = WebhookAvatarURL,
            },
        }
    }

    PerformHttpRequest(WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = WebhookUsername, avatar_url = WebhookAvatarURL, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
