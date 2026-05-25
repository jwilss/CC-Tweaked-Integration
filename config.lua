--========================================================--
--  config.lua  |  Dashboard Configuration
--========================================================--

local config = {}

------------------------------------------------------------
-- Update Rate (seconds)
------------------------------------------------------------
config.updateInterval = 1.0   -- How often the dashboard refreshes

------------------------------------------------------------
-- Items to Track (Displayed in the main item list)
------------------------------------------------------------
config.trackedItems = {
    {
        name = "allthemodium:unobtainium_ingot",
        label = "Unobtainium Ingots"
    },
    {
        name = "allthemodium:vibranium_ingot",
        label = "Vibranium Ingots"
    },
    {
        name = "allthemodium:allthemodium_ingot",
        label = "Allthemodium Ingots"
    },
    {
        name = "minecraft:netherite_ingot",
        label = "Netherite Ingots"
    },
    {
        name = "minecraft:diamond",
        label = "Diamonds"
    }
}

------------------------------------------------------------
-- Smithing Template Warnings
-- When count <= threshold, a warning appears
------------------------------------------------------------
config.warningItems = {
    {
        name = "allthemodium:unobtainium_upgrade_smithing_template",
        label = "Unobtainium Templates",
        threshold = 2
    },
    {
        name = "allthemodium:vibranium_upgrade_smithing_template",
        label = "Vibranium Templates",
        threshold = 2
    },
    {
        name = "allthemodium:allthemodium_upgrade_smithing_template",
        label = "Allthemodium Templates",
        threshold = 2
    },
    {
        name = "minecraft:netherite_upgrade_smithing_template",
        label = "Netherite Templates",
        threshold = 2
    }
}

------------------------------------------------------------
-- UI Settings
------------------------------------------------------------

config.ui = {
    titleColor = colors.cyan,
    textColor = colors.white,
    warningColor = colors.orange,
    criticalColor = colors.red,
    barBackground = colors.gray,
    barFill = colors.green,
    barFillMid = colors.yellow,
    barFillLow = colors.red,
    sectionSpacing = 1,
    textScale = 0.5
}

------------------------------------------------------------
-- Section Titles
------------------------------------------------------------
config.sections = {
    power = "POWER BANK",
    items = "MATERIAL STOCKS",
    warnings = "WARNINGS",
    crafting = "ACTIVE CRAFTING"
}

return config
