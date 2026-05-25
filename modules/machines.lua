-- ============================================================
--  modules/machines.lua  –  Machine status reader
-- ============================================================
--  Works with any Mekanism machine (Crusher, Enrichment Chamber,
--  Osmium Compressor, etc.) and Thermal Series machines that
--  expose the standard Advanced Peripherals peripheral API.
--
--  Detected methods (gracefully absent = skipped):
--    getActive()        → boolean
--    getEnergyUsage()   → number (FE/t or J/t)
--    getProgress()      → 0‥100  (Mekanism)
--    getProcessTime()   → ticks  (Thermal)
-- ============================================================

local Config = require("config.settings")
local Utils  = require("modules.utils")

local Machines = {}

local STATUS = {
    ACTIVE   = "ACTIVE",
    IDLE     = "IDLE",
    OFFLINE  = "OFFLINE",
}

local function readMachine(entry)
    local p = Utils.safewrap(entry.side)
    if not p then
        return {
            label   = entry.label,
            side    = entry.side,
            status  = STATUS.OFFLINE,
            active  = false,
            energy  = 0,
            progress= nil,
        }
    end

    local active   = Utils.safeCall(p, "getActive")
    local energy   = Utils.safeCall(p, "getEnergyUsage") or 0
    local progress = Utils.safeCall(p, "getProgress")
        or Utils.safeCall(p, "getProcessProgress")
        or nil

    -- Mekanism getActive() returns bool; some machines return nil when off
    local isActive = (active == true)

    return {
        label    = entry.label,
        side     = entry.side,
        status   = isActive and STATUS.ACTIVE or STATUS.IDLE,
        active   = isActive,
        energy   = energy,
        progress = progress,  -- nil if unsupported
    }
end

-- ── Public ───────────────────────────────────────────────────
function Machines.collect()
    local list = {}
    for _, entry in ipairs(Config.machines.list) do
        table.insert(list, readMachine(entry))
    end
    return list
end

Machines.STATUS = STATUS
return Machines
