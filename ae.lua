--========================================================--
--  ae.lua  |  AE2 / ME Bridge wrapper for BAER
--========================================================--

local ae = {}

------------------------------------------------------------
-- Locate ME Bridge
------------------------------------------------------------
local function findMeBridge()
    -- Try by type first (Advanced Peripherals meBridge)
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "meBridge") then
            return peripheral.wrap(name)
        end
    end

    -- Fallback: explicit name "meBridge"
    if peripheral.isPresent("meBridge") then
        return peripheral.wrap("meBridge")
    end

    error("AE ERROR: No meBridge peripheral found")
end

local bridge = findMeBridge()

------------------------------------------------------------
-- listItems
-- Returns a flat array of items:
-- { { name=..., displayName=..., amount=... }, ... }
------------------------------------------------------------
function ae.listItems()
    local raw = bridge.listItems()
    local out = {}

    -- listItems usually returns a map; normalize to array
    for _, it in pairs(raw or {}) do
        table.insert(out, {
            name        = it.name or it.id or "unknown",
            displayName = it.displayName or it.label or (it.name or "Unknown"),
            amount      = it.amount or it.count or 0
        })
    end

    return out
end

------------------------------------------------------------
-- getDashboardData
-- Returns:
-- {
--   drives   = { {label="Drive", percent=NN}, ... },
--   channels = { used=NN, total=NN },
--   totals   = { items=NN, types=NN, buses=0 }
-- }
------------------------------------------------------------
function ae.getDashboardData()
    local usedChannels  = 0
    local totalChannels = 0
    local totalItems    = 0
    local totalTypes    = 0

    if bridge.getUsedChannels then
        usedChannels = bridge.getUsedChannels() or 0
    end
    if bridge.getTotalChannels then
        totalChannels = bridge.getTotalChannels() or 32
    else
        totalChannels = 32
    end

    if bridge.getTotalItemCount then
        totalItems = bridge.getTotalItemCount() or 0
    end
    if bridge.getTotalItemTypes then
        totalTypes = bridge.getTotalItemTypes() or 0
    end

    -- Drives: if you later want real drive data, you can fill this.
    -- For now, leave empty; UI will just skip the list.
    local drives = {}

    return {
        drives   = drives,
        channels = {
            used  = usedChannels,
            total = totalChannels
        },
        totals   = {
            items = totalItems,
            types = totalTypes,
            buses = 0
        }
    }
end

------------------------------------------------------------
-- getWarnings
-- warningItems: array of { name=..., label=..., threshold=... }
-- Returns array of { label=..., count=... } for items at or below threshold
------------------------------------------------------------
function ae.getWarnings(warningItems)
    local results = {}

    if not warningItems or #warningItems == 0 then
        return results
    end

    for _, w in ipairs(warningItems) do
        local count = 0
        if bridge.getItem then
            local data = bridge.getItem({ name = w.name })
            if data and data.amount then
                count = data.amount
            end
        end

        if count <= (w.threshold or 0) then
            table.insert(results, {
                label = w.label or w.name or "Unknown",
                count = count
            })
        end
    end

    return results
end

return ae
