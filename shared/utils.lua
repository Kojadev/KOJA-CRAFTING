
Utils = {}
Utils.Functions = {}

Utils.Functions.hasResource = function(name)
    return GetResourceState(name):find("start") ~= nil
end

Utils.Functions.GetFramework = function()
    if Config.Framework == "esx" then
        if not Utils.Functions.hasResource("es_extended") then
            print("ES Extended is not installed! The plugin cannot be used with this framework.")
            return false
        end
        return exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "qb" then
        if not Utils.Functions.hasResource("qb-core") then
            print("QBCore is not installed! The plugin cannot be used with this framework.")
            return false
        end
        return exports["qb-core"]:GetCoreObject()
    end
end

