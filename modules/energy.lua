-- ============================================================
--  modules/energy.lua  –  Mekanism + Thermal energy readers
-- ============================================================
--  Now includes production/consumption tracking:
--    We store the last reading and compare to the new one.
--    Delta / elapsed time → FE per second (net flow).
--    Positive = net charging, negative = net draining.
-- ============================================================

local Config = require("config.settings")
local Utils  = require("modules.utils")

local Energy = {}

local J_TO_FE = 2.5   -- Mekanism Joules → Forge Energy

-- ── Delta tracking state (persists across collect() calls) ───
local _lastTotal = nil   -- last totalEnergy value
local _lastTime  = nil   -- os.clock() of last reading
local _flowFE    = 0     -- smoothed net FE/s (positive = gain)

-- Exponential moving average factor (0 = no smoothing, 1 = frozen)
local SMOOTH = 0.3

-- ── Internal helpers ─────────────────────────────────────────

local function readCell(wrapped, isMek)
    local energy    = Utils.safeCall(wrapped, "getEnergy")    or 0
    local maxEnergy = Utils.safeCall(wrapped, "getMaxEnergy") or 1
    if isMek then
        energy    = energy    * J_TO_FE
        maxEnergy = maxEnergy * J_TO_FE
    end
    return energy, maxEnergy
end

local function probe(side, isMek)
    local p = Utils.safewrap(side)
    if not p then return nil end
    local e, max = readCell(p, isMek)
    if max == 0 then return nil end
    return { side = side, energy = e, maxEnergy = max, pct = e/max, isMek = isMek }
end

local function discoverCells()
    local cells = {}

    for _, side in ipairs(Config.energy.mekanismSides) do
        local cell = probe(side, true)
        if cell then table.insert(cells, cell) end
    end
    for _, side in ipairs(Config.energy.thermalSides) do
        local cell = probe(side, false)
        if cell then table.insert(cells, cell) end
    end

    if #cells == 0 then
        for _, p in ipairs(Utils.getPeripherals("inductionMatrix")) do
            local e, max = readCell(p.wrapped, true)
            if max > 0 then table.insert(cells, { side=p.side, energy=e, maxEnergy=max, pct=e/max, isMek=true }) end
        end
        for _, p in ipairs(Utils.getPeripherals("energyCube")) do
            local e, max = readCell(p.wrapped, true)
            if max > 0 then table.insert(cells, { side=p.side, energy=e, maxEnergy=max, pct=e/max, isMek=true }) end
        end
        for _, p in ipairs(Utils.getPeripherals("energyCell")) do
            local e, max = readCell(p.wrapped, false)
            if max > 0 then table.insert(cells, { side=p.side, energy=e, maxEnergy=max, pct=e/max, isMek=false }) end
        end
    end

    return cells
end

-- ── Public ───────────────────────────────────────────────────
function Energy.collect()
    local cells = discoverCells()

    local totalEnergy, totalMax = 0, 0
    for _, c in ipairs(cells) do
        totalEnergy = totalEnergy + c.energy
        totalMax    = totalMax    + c.maxEnergy
    end

    -- ── Flow calculation ─────────────────────────────────────
    local now = os.clock()
    if _lastTotal ~= nil and _lastTime ~= nil then
        local dt = now - _lastTime
        if dt > 0 then
            local rawFlow = (totalEnergy - _lastTotal) / dt
            -- Smooth it so display doesn't jump around every tick
            _flowFE = _flowFE * SMOOTH + rawFlow * (1 - SMOOTH)
        end
    end
    _lastTotal = totalEnergy
    _lastTime  = now

    -- Estimate time-to-full or time-to-empty
    local tte = nil   -- seconds
    if math.abs(_flowFE) > 100 then
        local remaining = _flowFE > 0
            and (totalMax - totalEnergy)   -- filling: FE until full
            or  totalEnergy                -- draining: FE until empty
        tte = remaining / math.abs(_flowFE)
    end

    return {
        available   = #cells > 0,
        cells       = cells,
        totalEnergy = totalEnergy,
        totalMax    = totalMax,
        totalPct    = totalMax > 0 and (totalEnergy / totalMax) or 0,
        unit        = Config.energy.displayUnit,
        flowFE      = _flowFE,   -- net FE/s, + = charging, - = draining
        tte         = tte,       -- seconds until full/empty, or nil
    }
end

return Energy
