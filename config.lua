--========================================================--
--  config.lua  |  Styled Dashboard Configuration
--========================================================--

local config = {}

------------------------------------------------------------
-- UI Theme
------------------------------------------------------------
config.ui = {
    scale = 0.5,

    -- Main colours
    background = colors.black,
    text       = colors.white,

    -- Section headers
    sectionBg  = colors.blue,
    sectionText = colors.white,

    -- Warning colours
    warnBg     = colors.red,
    warnText   = colors.white,

    -- Boot screen
    bootBg     = colors.black,
    bootText   = colors.cyan,
    bootDelay  = 0.05
}

------------------------------------------------------------
-- Section Titles
------------------------------------------------------------
config.sections = {
    power    = "⚡ POWER STATUS",
    items    = "📦 STORAGE ITEMS",
    warnings = "⚠ WARNINGS",
    crafting = "🛠 CRAFTING JOBS"
}

------------------------------------------------------------
-- Update Interval
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

return config
