--========================================================--
--  config.lua  |  BAER Industrial ASCII Config
--========================================================--

local config = {}

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
    bootDelay        = 0.02,
    warnPulseSpeed   = 0.4
}

config.sections = {
    power    = "[ POWER ]",
    storage  = "[ STORAGE ]",
    machines = "[ MACHINES ]",
    farms    = "[ FARMS ]",
    warnings = "[ WARNINGS ]"
}

config.updateInterval = 0.5

config.warningItems = {
    { name="minecraft:netherite_upgrade_smithing_template", label="Netherite", threshold=1 },
    { name="allthemodium:allthemodium_upgrade_smithing_template", label="Allthemodium", threshold=1 },
    { name="allthemodium:vibranium_upgrade_smithing_template", label="Vibranium", threshold=1 },
    { name="allthemodium:unobtainium_upgrade_smithing_template", label="Unobtainium", threshold=1 }
}

return config
