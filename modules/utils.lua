-- ============================================================
--  modules/utils.lua  –  Peripheral discovery & shared helpers
-- ============================================================

local Utils = {}

-- Internal registry: type → list of wrapped peripherals
local _registry = {}

-- ── Peripheral discovery ─────────────────────────────────────
function Utils.discoverPeripherals()
    _registry = {}
    for _, side in ipairs(peripheral.getNames()) do
        local ptype = peripheral.getType(side)
        if ptype then
            -- Normalise type strings (strip mod prefix if present)
            local shortType = ptype:match("[^:]+$") or ptype
            if not _registry[shortType] then
                _registry[shortType] = {}
            end
            table.insert(_registry[shortType], {
                side    = side,
                type    = ptype,
                wrapped = peripheral.wrap(side),
            })
        end
    end
    return _registry
end

-- Return all peripherals matching a type substring (case-insensitive)
function Utils.getPeripherals(typeFragment)
    local results = {}
    for key, list in pairs(_registry) do
        if key:lower():find(typeFragment:lower(), 1, true) then
            for _, p in ipairs(list) do
                table.insert(results, p)
            end
        end
    end
    return results
end

-- Return first peripheral matching type fragment, or nil
function Utils.getPeripheral(typeFragment)
    local list = Utils.getPeripherals(typeFragment)
    return list[1]
end

-- Wrap a specific side, returning nil (not error) if absent
function Utils.safewrap(side)
    if not peripheral.isPresent(side) then return nil end
    return peripheral.wrap(side)
end

-- ── Number formatting helpers ────────────────────────────────

-- Abbreviate large numbers:  1234567 → "1.23M"
function Utils.fmtNum(n)
    n = tonumber(n) or 0
    if n >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n / 1e3)
    else
        return tostring(math.floor(n))
    end
end

-- Percentage bar string:  pct=0.75, width=10  →  "███████░░░"
function Utils.bar(pct, width)
    pct = math.max(0, math.min(1, pct))
    local filled = math.floor(pct * width + 0.5)
    return string.rep("\x7f", filled) .. string.rep(".", width - filled)
    -- \x7f renders as a solid block in CC font
end

-- Clamp a value between min and max
function Utils.clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

-- Safe method call – returns nil instead of throwing
function Utils.safeCall(obj, method, ...)
    if not obj then return nil end
    local fn = obj[method]
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, obj, ...)
    return ok and result or nil
end

return Utils
