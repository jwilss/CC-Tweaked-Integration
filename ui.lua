--========================================================--
--  ui.lua  |  Ores + Ingots + Energy (minimal + stable) 3
--========================================================--

local ui = {}
local mon
local ae = require("ae")

------------------------------------------------------------
-- Init
------------------------------------------------------------
function ui.init(m)
    mon = m
    mon.setTextScale(0.5)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.clear()
end

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function header(text, y)
    mon.setCursorPos(1, y)
    mon.setBackgroundColor(colors.yellow)
    mon.setTextColor(colors.black)

    local w = mon.getSize()
    mon.write(text .. string.rep("=", w - #text))

    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    return y + 1
end

local function matches(str, patterns)
    if not str then return false end
    for _, p in ipairs(patterns) do
        if string.find(str, p) then
            return true
        end
    end
    return false
end

local function getOres()
    local items = ae.listItems()
    local out = {}

    local orePatterns = {
        "_ore",
        "ore_",
        "deepslate_.*_ore",
        "nether_.*_ore",
        "end_.*_ore"
    }

    for _, it in ipairs(items) do
        if matches(it.id, orePatterns) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end

    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

local function getIngots()
    local items = ae.listItems()
    local out = {}

    local ingotPatterns = {
        "_ingot",
        "ingot_"
    }

    for _, it in ipairs(items) do
        if matches(it.id, ingotPatterns) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end

    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

------------------------------------------------------------
-- Draw
------------------------------------------------------------
function ui.draw()
    mon.clear()
    local y = 1

    -- ENERGY (placeholder)
    y = header("[ ENERGY ]", y)
    mon.setCursorPos(1, y)
    mon.write("Stored: N/A")
    y = y + 1
    mon.setCursorPos(1, y)
    mon.write("Capacity: N/A")
    y = y + 2

    -- ORES
    y = header("[ ORES ]", y)
    for _, o in ipairs(getOres()) do
        mon.setCursorPos(1, y)
        mon.write(o.name .. ": " .. o.count)
        y = y + 1
    end
    y = y + 1

    -- INGOTS
    y = header("[ INGOTS ]", y)
    for _, i in ipairs(getIngots()) do
        mon.setCursorPos(1, y)
        mon.write(i.name .. ": " .. i.count)
        y = y + 1
    end
end

return ui
