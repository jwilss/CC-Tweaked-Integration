--========================================================--
--  machines.lua  |  Real values from AE
--========================================================--

local machines = {}

local ae    = require("ae")
local config = require("config")

local function countItems(ids)
    local items = ae.listItems()
    local set = {}
    for _, id in ipairs(ids) do set[id] = true end

    local total = 0
    for _, it in ipairs(items) do
        if set[it.name] then
            total = total + (it.amount or 0)
        end
    end
    return total
end

function machines.getIndustrialForegoing()
    local cfg = config.items.industrial_foregoing or {}
    local latexIds   = cfg.latex   or {}
    local plasticIds = cfg.plastic or {}

    local latex   = countItems(latexIds)
    local plastic = countItems(plasticIds)

    return {
        crusher = "AE",          -- we are reading from AE, not the block
        latex   = latex,
        plastic = plastic
    }
end

function machines.getThermal()
    -- For now, leave these as 0 until we wire real dynamos
    return { mag = 0, comp = 0, num = 0 }
end

function machines.getRFTools()
    -- Same here: placeholder until we wire the dimension builder/receiver
    return { recv = "Unknown", energy = "0/0" }
end

return machines
