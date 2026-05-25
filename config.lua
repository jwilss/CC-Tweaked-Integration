--========================================================--
--  config.lua  |  Dashboard Configuration
--========================================================--

local config = {}

------------------------------------------------------------
-- UI Settings
------------------------------------------------------------
config.ui = {
    backgroundColor = colors.black,
    textColor = colors.white,
    sectionBackground = colors.gray,
    sectionText = colors.black,
    scale = 0.5
}

------------------------------------------------------------
-- Update interval (seconds)
------------------------------------------------------------
config.updateInterval = 1

------------------------------------------------------------
-- Tracked Items
------------------------------------------------------------
config.trackedItems = {
    { name = "minecraft:diamond", label = "Diamonds" },
    { name = "minecraft:iron_ingot", label = "Iron" },
    { name = "minecraft:gold_ingot", label = "Gold" },
}

------------------------------------------------------------
-- Warning Items
------------------------------------------------------------
config.warningItems = {
    { name = "minecraft:diamond", label = "Diamonds", threshold = 2 },
    { name = "minecraft:iron_ingot", label = "Iron", threshold = 64 },
}

------------------------------------------------------------
-- Section Titles
------------------------------------------------------------
config.sections = {
    power = "POWER",
    items = "ITEMS",
    warnings = "WARNINGS",
    crafting = "CRAFTING"
}

return config
