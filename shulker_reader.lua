--========================================================--
--  shulker_reader.lua  |  Reads contents of any inventory
--========================================================--

local function findInventories()
    local invs = {}
    for _, n in ipairs(peripheral.getNames()) do
        if peripheral.hasType(n, "inventory") then
            table.insert(invs, peripheral.wrap(n))
        end
    end
    return invs
end

local invs = findInventories()

if #invs == 0 then
    print("No shulker/inventory found")
    return
end

for _, inv in ipairs(invs) do
    print("Inventory:", peripheral.getName(inv))
    local list = inv.list()

    for slot, item in pairs(list) do
        print("  [" .. slot .. "] " .. item.name .. " x" .. item.count)
    end

    print("")
end
