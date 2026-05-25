--========================================================--
--  power.lua  |  Powah Ender Cell Power Reader Module
--========================================================--

local power = {}

-- Returns a list of all Powah Ender Cells connected as peripherals
local function findCells()
    local cells = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "powah:energy_cell") 
        or peripheral.hasType(name, "powah:ender_cell") then
            table.insert(cells, peripheral.wrap(name))
        end
    end
    return cells
end

-- Cache cells so we don't scan every tick
local cellList = findCells()

-- Reads total stored energy across all cells
function power.getTotalEnergy()
    local total = 0
    for _, cell in ipairs(cellList) do
        local ok, stored = pcall(cell.getEnergy)
        if ok and stored then total = total + stored end
    end
    return total
end

-- Reads total max capacity across all cells
function power.getTotalCapacity()
    local total = 0
    for _, cell in ipairs(cellList) do
        local ok, cap = pcall(cell.getMaxEnergy)
        if ok and cap then total = total + cap end
    end
    return total
end

-- Returns percentage (0–100)
function power.getPercent()
    local stored = power.getTotalEnergy()
    local cap = power.getTotalCapacity()
    if cap == 0 then return 0 end
    return math.floor((stored / cap) * 100)
end

-- Returns a table of per‑cell data for detailed UI
function power.getCells()
    local data = {}
    for i, cell in ipairs(cellList) do
        local ok1, stored = pcall(cell.getEnergy)
        local ok2, cap = pcall(cell.getMaxEnergy)
        table.insert(data, {
            id = i,
            stored = ok1 and stored or 0,
            capacity = ok2 and cap or 0,
            percent = (ok1 and ok2 and cap > 0) and math.floor((stored / cap) * 100) or 0
        })
    end
    return data
end

return power
