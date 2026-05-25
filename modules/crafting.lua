-- ============================================================
--  modules/crafting.lua  –  Autocrafting queue tracker
-- ============================================================
--  Works with:
--    • Refined Storage bridge  → getCraftingJobs()
--    • AE2 ME bridge           → getCraftingJobs()
--
--  Also supports a MANUAL queue: you define items you always
--  want to keep stocked in config, and this module checks if
--  current stock is below the target, flagging items that
--  need crafting. Useful when autocrafting isn't set up yet.
-- ============================================================

local Config  = require("config.settings")
local Utils   = require("modules.utils")

local Crafting = {}

-- ── Internal: get bridge ─────────────────────────────────────
local function getBridge()
    local p = Utils.safewrap(Config.storage.bridgeSide)
    if p then return p end
    local rs = Utils.getPeripheral("rsBridge")
    if rs then return rs.wrapped end
    local ae = Utils.getPeripheral("meBridge")
    if ae then return ae.wrapped end
    return nil
end

-- ── Live autocrafting jobs (RS / AE2) ────────────────────────
local function getLiveJobs(bridge)
    if not bridge then return {} end
    local raw = Utils.safeCall(bridge, "getCraftingJobs") or {}
    local jobs = {}
    for _, job in ipairs(raw) do
        table.insert(jobs, {
            name      = job.item and (job.item.displayName or job.item.name) or "Unknown",
            amount    = job.amount    or 0,
            progress  = job.progress  or nil,   -- 0‥100 if available
            crafting  = job.crafting  ~= false,  -- still active?
        })
    end
    return jobs
end

-- ── Manual queue: items below target stock ───────────────────
local function getManualQueue(bridge)
    if not bridge then return {} end
    if not Config.crafting or not Config.crafting.keepStocked then return {} end

    -- Build a name→amount map from current items
    local items = Utils.safeCall(bridge, "listItems") or {}
    local stock = {}
    for _, entry in ipairs(items) do
        local name = entry.displayName or entry.name or ""
        stock[name] = (stock[name] or 0) + (entry.amount or 0)
    end

    local needed = {}
    for _, rule in ipairs(Config.crafting.keepStocked) do
        local have   = stock[rule.item] or 0
        local target = rule.target or 64
        if have < target then
            table.insert(needed, {
                name    = rule.item,
                have    = have,
                target  = target,
                deficit = target - have,
            })
        end
    end
    return needed
end

-- ── Public ───────────────────────────────────────────────────
function Crafting.collect()
    local bridge = getBridge()
    local live   = getLiveJobs(bridge)
    local needed = getManualQueue(bridge)

    return {
        available  = bridge ~= nil,
        liveJobs   = live,
        needed     = needed,       -- items below keep-stocked targets
        totalJobs  = #live,
    }
end

return Crafting
