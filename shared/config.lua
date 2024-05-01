Config = {

    Framework = "esx", -- Choose your framework: 'esx' or 'qb'
    Database = "oxmysql", -- Specify your database technology: 'ghmattimysql', 'oxmysql', or 'mysql-async' (check fxmanifest.lua when you change it!)

    developermode = false, -- Enable or disable print outputs to the console: true enables, false disables

    maxlvl = 50, -- Maximum level a player can achieve
    neededxp = 1000, -- Amount of XP required to level up

    translation = {
        title1 = "CRAFTING",
        title2 = "SYSTEM",
        categories = "Categories",
        level = "Level",
        search = "Search",
        itemsneeded = "Items Needed:",
        crafttime = "Craft Time",
        craftcount = "Craft Count",
        craft = "CRAFT",
        craftingqueue = "Crafting Queue",
        craftingqueuedesc = "Items that you are currently crafting",
        crafted = "Crafted!",
        opencrafting = "Open Crafting Table"
    },

    props = { -- Define crafting benches and their locations.
        {
            propnum = "prop_tool_bench02",
            coords = vector3(2705.4919, 2776.6221, 37.8780 - 0.94),
            heading = 121.6513
        },
    },

    categories = { -- Define categories of craftable items. Add as many categories as needed.
        {
            label = "Weapons",
            id = "weapons"
        },
        {
            label = "Ammunation",
            id = "ammunation"
        },
    },

    items = { -- Define craftable items. Add items under appropriate categories.
        -- Example entry for a craftable item:
        -- {
        --     id_item = 1,
        --     category = "weapons",
        --     type = "Pistol",
        --     label = "Pistol",
        --     time = 10, -- Time in seconds required to craft the item
        --     level = 0, -- Player level required to craft the item
        --     count = 1, -- Number of items produced per crafting operation
        --     respname = "weapon_pistol",
        --     desc = "Type: Handgun<br>Manufacturer: Hawk & Little<br>Model: Standard Pistol<br>Category: Firearm",
        --     required_items = { -- List of materials required to craft the item
        --         {item = "metal", label = "Metal", count = 10},
        --         {item = "spring", label = "Spring", count = 1},
        --         {item = "nail", label = "Nail", count = 5},
        --         {item = "iron", label = "Iron", count = 6},
        --         {item = "magazynek", label = "Magazine", count = 1}
        --     }
        -- }
        -- Begin definition of actual items:
        {
            id_item = 1,
            category = "weapons",
            type = "Pistol",
            label = "Pistol",
            time = 1,
            level = 0,
            count = 1,
            respname = "weapon_pistol",
            desc = "Type: Handgun<br>Manufacturer: Hawk & Little<br>Model: Standard Pistol<br>Category: Firearm",
            required_items = {
                {item = "spring", label = "Spring", count = 1},
                {item = "nail", label = "Nail", count = 5},
            }
        },
        {
            id_item = 2,
            category = "weapons",
            type = "Pistol",
            label = "Pistol2",
            time = 150,
            level = 0,
            count = 5,
            respname = "weapon_pistol",
            desc = "Type: Handgun<br>Manufacturer: Hawk & Little<br>Model: Standard Pistol<br>Category: Firearm",
            required_items = {
                {item = "spring", label = "Spring", count = 1},
                {item = "nail", label = "Nail", count = 5},
            }
        },
        -- Additional items can be added following the example structure.
        {
            id_item = 3,
            category = "weapons",
            type = "Weapon",
            label = "Vintage Pistol",
            time = 20,
            level = 4,
            count = 1,
            respname = "weapon_vintagepistol",
            desc = "Category: Pistol<br>Manufacturer: Hawk & Little",
            required_items = {
                {item = "metal", label = "Metal", count = 15},
                {item = "spring", label = "Spring", count = 1},
                {item = "nail", label = "Nail", count = 10},
                {item = "iron", label = "Iron", count = 8},
            }
        },
        {
            id_item = 4,
            category = "ammunation",
            type = "TEST",
            label = "TEST",
            time = 150,
            level = 0,
            count = 5,
            respname = "weapon_pistol",
            desc = "Type: Handgun<br>Manufacturer: Hawk & Little<br>Model: Standard Pistol<br>Category: Firearm",
            required_items = {
                {item = "spring", label = "Spring", count = 1},
                {item = "nail", label = "Nail", count = 5},
            }
        },
        -- Continue adding more items as needed.
    }
}
