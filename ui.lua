--========================================================--
--  ui.lua  |  Minimal BAER: Raw Materials + Ores + Energy
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

local function getTaggedItems(tag)
    local items = ae.listItems()
    local out = {}

    for _, it in ipairs(items) do
        if it.tags then
            for _, t in ipairs(it.tags) do
                if t == tag then
                    table.insert(out, { name = it.displayName, count = it.amount })
                end
            end
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

    --------------------------------------------------------
    -- ENERGY (placeholder)
    --------------------------------------------------------
    y = header("[ ENERGY ]", y)
    mon.setCursorPos(1, y)
    mon.write("Stored: N/A")
    y = y + 1
    mon.setCursorPos(1, y)
    mon.write("Capacity: N/A")
    y = y + 2

    --------------------------------------------------------
    -- RAW MATERIALS
    --------------------------------------------------------
    y = header("[ RAW MATERIALS ]", y)
    local raws = getTaggedItems("c:raw_materials")
    for _, r in ipairs(raws) do
        mon.setCursorPos(1, y)
        mon.write(r.name .. ": " .. r.count)
        y = y + 1
    end
    y = y + 1

    --------------------------------------------------------
    -- ORES
    --------------------------------------------------------
    y = header("[ ORES ]", y)
    local ores = getTaggedItems("c:ores")
    for _, o in ipairs(ores) do
        mon.setCursorPos(1, y)
        mon.write(o.name .. ": " .. o.count)
        y = y + 1
    end
end

return ui
