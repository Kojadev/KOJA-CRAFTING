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
Koja = {}
Koja.Framework = Utils.Functions.GetFramework()
Koja.Utils = Utils.Functions
Koja.Callbacks = {}
Koja.Client = {}

Koja.Client.TriggerServerCallback = function(key, payload, func)
    if not func then
        func = function() end
    end

    Koja.Callbacks[key] = func
    TriggerServerEvent("koja-crafting:Server:HandleCallback", key, payload)
end

RegisterNetEvent("koja-crafting:Client:HandleCallback", function(key, data)
    if Koja.Callbacks[key] then
        Koja.Callbacks[key](data)
        Koja.Callbacks[key] = nil
    end
end)


CreateThread(function()
    while Koja.Framework == nil do
        Koja.Framework = Utils.Functions.GetFramework()
        Wait(15)
    end
end)



local tablesSpawned = false 

Citizen.CreateThread(function()
    if not tablesSpawned then
        local addedModels = {}

        for _, data in ipairs(Config.props) do
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
                        label = Config.translation.opencrafting,
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
                devmode = Config.developermode,
            })
            ConfigLoaded = true
        end
    end
end)

RegisterNetEvent('koja_crafting:open')
AddEventHandler('koja_crafting:open', function()
    Koja.Client.TriggerServerCallback("koja-crafting:getPlayerDetails", {}, function(result)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "show",
            currentXP = result.currentXP,
            categories = Config.categories,
            items = Config.items,
            inventory = result.inventory,
            maxlvl = Config.maxlvl,
            neededxp = Config.neededxp,
            translation = Config.translation,
        })
        print("[DONE] Loaded!")
    end)    
end)

RegisterNUICallback('craftitem', function(data, cb)
    Koja.Client.TriggerServerCallback("koja-crafting:craftitem", data, function(result)
        cb(result)
    end)    
end)

RegisterNUICallback('additem', function(data, cb)
    Koja.Client.TriggerServerCallback("koja-crafting:additem", data, function(result)
        cb(result)
    end)  
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
end)

