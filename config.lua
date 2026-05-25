--========================================================--
--  config.lua  |  BAER Industrial (ASCII‑Safe)
--========================================================--

local config = {}

------------------------------------------------------------
-- UI Theme (Industrial ASCII)
------------------------------------------------------------
config.ui = {
    scale            = 0.5,

    backgroundColor  = colors.black,
    textColor        = colors.white,

    sectionBackground = colors.yellow,
    sectionText       = colors.black,

    warnBackground   = colors.red,
    warnText         = colors.white,

    bootBackground   = colors.black,
    bootText         = colors.yellow,
    bootDelay        = 0.03,

    warnPulseSpeed   = 0.5
}

------------------------------------------------------------
-- Section Titles
------------------------------------------------------------
config.sections = {
    power    = "[ POWER STATUS ]",
    items    = "[ STORAGE ITEMS ]",
    warnings = "[ WARNINGS ]",
    crafting = "[ CRAFTING JOBS ]"
}

------------------------------------------------------------
-- Update Interval
------------------------------------------------------------
config.updateInterval = 1.0

------------------------------------------------------------
-- Tracked Items
------------------------------------------------------------
config.trackedItems = {
    { name = "minecraft:netherite_upgrade_smithing_template", label = "Netherite Template" },
    { name = "allthemodium:allthemodium_upgrade_smithing_template", label = "Allthemodium Template" },
    { name = "allthemodium:vibranium_upgrade_smithing_template",   label = "Vibranium Template" },
    { name = "allthemodium:unobtainium_upgrade_smithing_template", label = "Unobtainium Template" },
}

------------------------------------------------------------
-- Warning Items
------------------------------------------------------------
config.warningItems = {
    {
        name      = "minecraft:netherite_upgrade_smithing_template",
        label     = "Netherite Template",
        threshold = 1
    },
    {
        name      = "allthemodium:allthemodium_upgrade_smithing_template",
        label     = "Allthemodium Template",
        threshold = 1
    },
    {
        name      = "allthemodium:vibranium_upgrade_smithing_template",
        label     = "Vibranium Template",
        threshold = 1
    },
    {
        name      = "allthemodium:unobtainium_upgrade_smithing_template",
        label     = "Unobtainium Template",
        threshold = 1
    }
}

return config
