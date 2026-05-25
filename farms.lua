--========================================================--
--  farms.lua  |  Real values from AE
--========================================================--

local farms  = {}
local ae     = require("ae")
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

function farms.getEssence()
    local cfg = config.items.essences or {}

    local inferium   = countItems(cfg.inferium   or {})
    local prudentium = countItems(cfg.prudentium or {})
    local supremium  = countItems(cfg.supremium  or {})

    return {
        { name = "Inferium",   count = inferium },
        { name = "Prudentium", count = prudentium },
        { name = "Supremium",  count = supremium }
    }
end

function farms.getMob()
    local cfg = config.items.mob_drops or {}

    local gunpowder = countItems(cfg.gunpowder or {})
    local pearls    = countItems(cfg.pearls    or {})
    local skulls    = countItems(cfg.skulls    or {})

    return {
        { name = "Gunpowder", count = gunpowder },
        { name = "Pearls",    count = pearls },
        { name = "Skulls",    count = skulls }
    }
end

return farms
