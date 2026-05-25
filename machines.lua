--========================================================--
--  machines.lua
--========================================================--

local machines = {}

function machines.getIF()
    return { crusher="Active", latex="12400mB", plastic=320 }
end

function machines.getThermal()
    return { mag=80, comp=0, num=0 }
end

function machines.getRFTools()
    return { recv="Online", energy="12.4M/20M" }
end

return machines
