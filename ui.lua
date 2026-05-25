--========================================================--
--  ui.lua  |  3‑Column Ores + Raw + Ingots (no flicker)
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
local function matches(str, patterns)
    if not str then return false end
    for _, p in ipairs(patterns) do
        if string.find(str, p) then
            return true
        end
    end
    return false
end

local function collect(patterns)
    local items = ae.listItems()
    local out = {}

    for _, it in ipairs(items) do
        if matches(it.id, patterns) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end

    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

local function drawColumn(x, title, list)
    local y = 1

    -- Header
    mon.setCursorPos(x, y)
    mon.setBackgroundColor(colors.yellow)
    mon.setTextColor(colors.black)
    mon.write(title)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    y = y + 2

    -- Items
    for _, item in ipairs(list) do
        mon.setCursorPos(x, y)
        mon.write(item.name .. ": " .. item.count)
        y = y + 1
    end
end

------------------------------------------------------------
-- Draw
------------------------------------------------------------
function ui.draw()
    -- No mon.clear() → prevents flicker

    local w, h = mon.getSize()
    local colWidth = math.floor(w / 3)

    -- Column X positions
    local col1 = 1
    local col2 = col1 + colWidth
    local col3 = col2 + colWidth

    -- Collect data
    local ores = collect({
        "_ore",
        "ore_",
        "deepslate_.*_ore",
        "nether_.*_ore",
        "end_.*_ore"
    })

    local raw = collect({
        "raw_",
        "_raw"
    })

    local ingots = collect({
        "_ingot",
        "ingot_"
    })

    -- Draw columns
    drawColumn(col1, "[ ORES ]", ores)
    drawColumn(col2, "[ RAW ]", raw)
    drawColumn(col3, "[ INGOTS ]", ingots)
end

return ui
