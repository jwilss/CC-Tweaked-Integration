-- ============================================================
--  modules/alerts.lua  –  Rule engine for dashboard alerts
-- ============================================================

local Config   = require("config.settings")
local Utils    = require("modules.utils")
local Machines = require("modules.machines")

local Alerts = {}
local _active = {}

local function push(level, msg)
    table.insert(_active, { level = level, msg = msg })
end

-- ── Rules ────────────────────────────────────────────────────

local function checkEnergy(data)
    if not data.energy.available then return end
    local pct = data.energy.totalPct * 100
    if pct < Config.alerts.lowEnergyPct then
        push("crit", string.format("LOW ENERGY: %.1f%%", pct))
    end
    -- Draining fast? Warn if less than 5 mins to empty
    local flow = data.energy.flowFE or 0
    if flow < -1000 and data.energy.tte and data.energy.tte < 300 then
        push("warn", string.format("DRAINING: empty in %ds", math.floor(data.energy.tte)))
    end
end

local function checkStorage(data)
    if not data.storage.available then return end
    for name, qty in pairs(data.storage.watchedItems) do
        if qty < Config.storage.lowStockThreshold then
            push("warn", string.format("LOW STOCK: %s (%s)", name, Utils.fmtNum(qty)))
        end
    end
end

local function checkMachines(data)
    if not Config.alerts.machineOffline then return end
    for _, m in ipairs(data.machines) do
        if m.status == Machines.STATUS.OFFLINE then
            push("crit", string.format("OFFLINE: %s", m.label))
        end
    end
end

local function checkMagic(data)
    if not data.magic then return end
    local bot = data.magic.botania
    if bot and bot.available and bot.totalPct < 0.05 then
        push("warn", "BOTANIA: Mana critically low")
    end
    local ast = data.magic.astral
    if ast and ast.available and ast.totalPct < 0.1 then
        push("warn", "ASTRAL: Starlight low")
    end
end

local function checkCrafting(data)
    if not data.crafting then return end
    -- Alert on many live jobs (might indicate a loop or mistake)
    if data.crafting.totalJobs > 10 then
        push("warn", string.format("CRAFTING: %d jobs running", data.crafting.totalJobs))
    end
    -- Alert on items needing to be crafted from the keep-stocked list
    for _, n in ipairs(data.crafting.needed or {}) do
        if n.have == 0 then
            push("warn", string.format("OUT: %s (need %s)", n.name, Utils.fmtNum(n.target)))
        end
    end
end

-- ── Public ───────────────────────────────────────────────────

function Alerts.evaluate(data)
    _active = {}
    checkEnergy(data)
    checkStorage(data)
    checkMachines(data)
    checkMagic(data)
    checkCrafting(data)
end

function Alerts.getActive()   return _active          end
function Alerts.hasAny()      return #_active > 0     end
function Alerts.hasCritical()
    for _, a in ipairs(_active) do
        if a.level == "crit" then return true end
    end
    return false
end

return Alerts
