--========================================================--
--  farms.lua
--========================================================--

local farms = {}

function farms.getEssence()
    return {
        {name="Inferium", count=12480},
        {name="Prudentium", count=3240},
        {name="Supremium", count=128}
    }
end

function farms.getMob()
    return {
        {name="Gunpowder", count=1280},
        {name="Pearls", count=642},
        {name="Skulls", count=12}
    }
end

return farms
