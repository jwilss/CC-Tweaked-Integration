--========================================================--
--  ae.lua  |  AE2 / ME Bridge wrapper for BAER
--========================================================--

local ae = {}

-- Change this if your ME Bridge name ever changes
local BRIDGE_NAME = "me_bridge_1"

------------------------------------------------------------
-- Locate ME Bridge
------------------------------------------------------------
local function findMeBridge()
    if peripheral.isPresent(BRIDGE_NAME) then
        return peripheral.wrap(BRIDGE_NAME)
    end

    -- Fallback: try by type, just in case
    local bridge = peripheral.find("meBridge")
    if bridge then
        return bridge
    end

    error("AE ERROR: No ME Bridge found (expected "..BRIDGE_NAME..")")
end

local bridge = findMeBridge()

------------------------------------------------------------
-- listItems
-- Returns: { { name=..., displayName=..., amount=... }, ... }
------------------------------------------------------------
function ae.listItems()
    local raw = bridge.listItems()
    local out = {}

    if type(raw) == "table" then
        for _, it in pairs(raw) do
            table.insert(out, {
                name        = it.name or it.id or "unknown",
                displayName = it.displayName or it.label or (it.name or "Unknown"),
                amount      = it.amount or it.count or 0
            })
        end
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
    local totalChannels = 32
    local totalItems    = 0
    local totalTypes    = 0

    if bridge.getUsedChannels then
        usedChannels = bridge.getUsedChannels() or 0
    end
    if bridge.getTotalChannels then
        totalChannels = bridge.getTotalChannels() or totalChannels
    end
    if bridge.getTotalItemCount then
        totalItems = bridge.getTotalItemCount() or 0
    end
    if bridge.getTotalItemTypes then
        totalTypes = bridge.getTotalItemTypes() or 0
    end

    local drives = {}  -- can be filled later from listCells if you want

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
-- warningItems: { { name=..., label=..., threshold=... }, ... }
-- Returns: { { label=..., count=... }, ... }
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
