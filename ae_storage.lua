--========================================================--
--  ae_storage.lua  |  AE2 Storage Reader
--========================================================--

local ae_storage = {}
local ae = require("ae")

local function filter(items, fn)
    local out = {}
    for _, it in ipairs(items) do
        if fn(it) then
            out[it.displayName] = (out[it.displayName] or 0) + it.amount
        end
    end
    return out
end

local function sorted(map)
    local list = {}
    for k,v in pairs(map) do
        table.insert(list, {name=k, count=v})
    end
    table.sort(list, function(a,b) return a.name < b.name end)
    return list
end

function ae_storage.getOverview()
    return ae.getDashboardData()
end

function ae_storage.getMaterials()
    local items = ae.listItems()

    local ores = filter(items, function(i) return string.find(i.name, "ore") end)
    local raw = filter(items, function(i) return string.find(i.name, "raw_") end)
    local ing = filter(items, function(i) return string.find(i.name, "ingot") end)
    local atm = filter(items, function(i)
        local n = i.name
        return string.find(n,"allthemodium") or string.find(n,"vibranium") or string.find(n,"unobtainium")
    end)

    return {
        ores = sorted(ores),
        raw = sorted(raw),
        ingots = sorted(ing),
        atm = sorted(atm)
    }
end

return ae_storage
