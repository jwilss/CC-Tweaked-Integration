-- ============================================================
--  modules/storage.lua  –  Refined Storage / AE2 bridge
-- ============================================================
--  Compatible with:
--    • RS Bridge      (Refined Storage + CC:Tweaked addon)
--    • ME Bridge      (AE2 + Advanced Peripherals)
--  Both expose very similar APIs; we detect which is present.
-- ============================================================

local Config = require("config.settings")
local Utils  = require("modules.utils")

local Storage = {}

-- Internal: locate the bridge peripheral
local function getBridge()
    -- Try explicit config side first
    local p = Utils.safewrap(Config.storage.bridgeSide)
    if p then return p, "configured" end

    -- Auto-detect RS bridge
    local rs = Utils.getPeripheral("rsBridge")
    if rs then return rs.wrapped, "rs" end

    -- Auto-detect AE2 ME bridge
    local ae = Utils.getPeripheral("meBridge")
    if ae then return ae.wrapped, "ae2" end

    return nil, "none"
end

-- ── Public: collect all storage data ────────────────────────
function Storage.collect()
    local bridge, kind = getBridge()

    local result = {
        available   = false,
        bridgeType  = kind,
        totalItems  = 0,
        totalTypes  = 0,
        fluid       = {},
        watchedItems= {},
    }

    if not bridge then return result end
    result.available = true

    -- ── Items ────────────────────────────────────────────────
    local items = Utils.safeCall(bridge, "getItems") or {}
    result.totalTypes = #items

    for _, entry in ipairs(items) do
        result.totalItems = result.totalItems + (entry.amount or 0)
    end

    -- Populate watched-item counts
    for _, name in ipairs(Config.storage.watchedItems) do
        result.watchedItems[name] = 0
    end
    for _, entry in ipairs(items) do
        local displayName = entry.displayName or entry.name or ""
        if result.watchedItems[displayName] ~= nil then
            result.watchedItems[displayName] = entry.amount or 0
        end
    end

    -- ── Fluids ───────────────────────────────────────────────
    local fluids = Utils.safeCall(bridge, "getFluids") or {}
    for _, f in ipairs(fluids) do
        table.insert(result.fluid, {
            name   = f.displayName or f.name or "Unknown",
            amount = f.amount or 0,
        })
    end

    return result
end

return Storage
