local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local PlayerData = {}
local FRAMEWORK = nil

if KOJA.Framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) FRAMEWORK = obj end)
    Citizen.Wait(250)
    if FRAMEWORK == nil then
        FRAMEWORK = exports.es_extended:getSharedObject()
    end

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
    end)


    elseif KOJA.Framework == "qb" then
        Citizen.CreateThread(function()
            while FRAMEWORK == nil do
                TriggerEvent('QBCore:GetObject', function(obj) FRAMEWORK = obj end)
                Citizen.Wait(0)
            end
            PlayerData = FRAMEWORK.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('QBCore:PlayerLoaded')
        AddEventHandler('QBCore:PlayerLoaded', function(xPlayer)
            PlayerData = xPlayer
        end)
    
end

local tablesSpawned = false 

Citizen.CreateThread(function()
    if not tablesSpawned then
        local addedModels = {}

        for _, data in ipairs(KOJA.props) do
            local objectHash = GetHashKey(data.propnum)

            RequestModel(objectHash)
            while not HasModelLoaded(objectHash) do
                Citizen.Wait(0)
            end

            local existingObjects = GetGamePool("CObject")
            for _, object in pairs(existingObjects) do
                local objCoords = GetEntityCoords(object)
                if Vdist(objCoords.x, objCoords.y, objCoords.z, data.coords.x, data.coords.y, data.coords.z) < 5.0 then
                    DeleteObject(object)
                end
            end

            local craftingTable = CreateObject(objectHash, data.coords.x, data.coords.y, data.coords.z, true, true, true)
            SetEntityHeading(craftingTable, data.heading)
            SetEntityAsMissionEntity(craftingTable, true, true)
            SetModelAsNoLongerNeeded(objectHash)
            FreezeEntityPosition(craftingTable, true)

            if not addedModels[data.propnum] then
                exports.ox_target:addModel(data.propnum, {
                    {
                        event = "koja_crafting:open",
                        icon = "fa-solid fa-screwdriver-wrench",
                        label = KOJA.translation.opencrafting,
                    }
                })
                addedModels[data.propnum] = true
            end
        end
        tablesSpawned = true 
    end
end)



Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(500)
        
        if not ConfigLoaded then
            SendNUIMessage({
                type = 'LoadConfig',
                devmode = KOJA.developermode,
            })
            ConfigLoaded = true
        end
    end
end)

RegisterNetEvent('koja_crafting:open')
AddEventHandler('koja_crafting:open', function()
	FRAMEWORK.TriggerServerCallback("koja-crafting:getPlayerDetails", function(result)
		SetNuiFocus(true,true)
		SendNUIMessage({
			type = "show",
            currentXP = result.currentXP,
			categories = KOJA.categories,
			items = KOJA.items,
			inventory = result.inventory,
            maxlvl = KOJA.maxlvl,
            neededxp = KOJA.neededxp,
            translation = KOJA.translation,
		})	
        log("^2Loaded^0", "done")
	end)
end)

RegisterNUICallback('craftitem', function(data, cb)
    log('Crafting: ^1' .. json.encode(data) .. '^0', 'done')
    ESX.TriggerServerCallback("koja-crafting:craftitem", function(result)
        cb(result)
	end, data)
end)

RegisterNUICallback('additem', function(data, cb)
    ESX.TriggerServerCallback("koja-crafting:additem", function(result)
        cb(result)
	end, data)
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
end)

function log(message, logType)
    local logTypes = {
        info = "^5[KOJA_CRAFTING]^0 ^4[INFO]^0 ",
        done = "^5[KOJA_CRAFTING]^0 ^2[DONE]^0 ",
        err = "^5[KOJA_CRAFTING]^0 ^1[ERROR]^0 ",
        warning = "^5[KOJA_CRAFTING]^0 ^3[WARNING]^0 ",
    }

    if KOJA.developermode then
        local logFormat = logTypes[logType]
        print(logFormat and logFormat .. message or message)
    end
    
end
