-- ============================================================
--  modules/magic.lua  –  Botania + Astral Sorcery readers
-- ============================================================
--  Botania:
--    Mana Spreader / Mana Pool via "botaniaPeripheral" from
--    the Botania CC:Tweaked addon (or Patchouli integration).
--    Exposed methods: getMana(), getMaxMana()
--
--  Astral Sorcery:
--    Attunement Altar / Starlight Infuser via Advanced Peripherals
--    or a dedicated integration peripheral.
--    Exposed methods: getStarlight(), getMaxStarlight()
--
--  Neither mod ships a first-party CC peripheral; you need one of:
--    • Botanic Additions (for Botania pools/spreaders)
--    • Astral Sorcery CC Compat (community mod)
--  If neither is present, data shows as unavailable gracefully.
-- ============================================================

local Config = require("config.settings")
local Utils  = require("modules.utils")

local Magic = {}

-- ── Botania ──────────────────────────────────────────────────

local function readBotania()
    local result = {
        available = false,
        pools     = {},
        totalMana = 0,
        totalMax  = 0,
    }

    -- Try configured sides first, then auto-detect
    local sides = Config.magic.botaniaSides or {}
    local perips = {}

    for _, side in ipairs(sides) do
        local p = Utils.safewrap(side)
        if p then table.insert(perips, { side = side, wrapped = p }) end
    end

    if #perips == 0 then
        -- Auto-detect: look for "manaPool" or "botaniaPeripheral" type
        for _, p in ipairs(Utils.getPeripherals("manaPool")) do
            table.insert(perips, p)
        end
        for _, p in ipairs(Utils.getPeripherals("botania")) do
            table.insert(perips, p)
        end
    end

    if #perips == 0 then return result end
    result.available = true

    for _, p in ipairs(perips) do
        local mana    = Utils.safeCall(p.wrapped, "getMana")    or 0
        local maxMana = Utils.safeCall(p.wrapped, "getMaxMana") or 0

        -- Some integrations use getStored / getCapacity
        if mana == 0 then
            mana    = Utils.safeCall(p.wrapped, "getStored")   or 0
            maxMana = Utils.safeCall(p.wrapped, "getCapacity") or maxMana
        end

        if maxMana > 0 then
            table.insert(result.pools, {
                side    = p.side,
                mana    = mana,
                maxMana = maxMana,
                pct     = mana / maxMana,
            })
            result.totalMana = result.totalMana + mana
            result.totalMax  = result.totalMax  + maxMana
        end
    end

    result.totalPct = result.totalMax > 0
        and (result.totalMana / result.totalMax)
        or 0

    return result
end

-- ── Astral Sorcery ───────────────────────────────────────────

local function readAstral()
    local result = {
        available  = false,
        altars     = {},
        totalLight = 0,
        totalMax   = 0,
    }

    local sides = Config.magic.astralSides or {}
    local perips = {}

    for _, side in ipairs(sides) do
        local p = Utils.safewrap(side)
        if p then table.insert(perips, { side = side, wrapped = p }) end
    end

    if #perips == 0 then
        for _, p in ipairs(Utils.getPeripherals("attunementAltar")) do
            table.insert(perips, p)
        end
        for _, p in ipairs(Utils.getPeripherals("starlightInfuser")) do
            table.insert(perips, p)
        end
        for _, p in ipairs(Utils.getPeripherals("astralsorcery")) do
            table.insert(perips, p)
        end
    end

    if #perips == 0 then return result end
    result.available = true

    for _, p in ipairs(perips) do
        local light    = Utils.safeCall(p.wrapped, "getStarlight")    or 0
        local maxLight = Utils.safeCall(p.wrapped, "getMaxStarlight") or 0

        -- Fallback names used by some community integrations
        if light == 0 then
            light    = Utils.safeCall(p.wrapped, "getStarlightLevel") or 0
            maxLight = Utils.safeCall(p.wrapped, "getMaxStarlightLevel") or maxLight
        end

        -- Some expose a 0‥1 float instead of absolute values
        if maxLight == 0 and light > 0 and light <= 1 then
            maxLight = 1
        end

        if maxLight > 0 then
            table.insert(result.altars, {
                side     = p.side,
                light    = light,
                maxLight = maxLight,
                pct      = light / maxLight,
            })
            result.totalLight = result.totalLight + light
            result.totalMax   = result.totalMax   + maxLight
        end
    end

    result.totalPct = result.totalMax > 0
        and (result.totalLight / result.totalMax)
        or 0

    return result
end

-- ── Public ───────────────────────────────────────────────────

function Magic.collect()
    return {
        botania = readBotania(),
        astral  = readAstral(),
    }
end

return Magic
