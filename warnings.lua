--========================================================--
--  warnings.lua
--========================================================--

local warnings = {}
local log = {}

function warnings.add(msg)
    table.insert(log, 1, msg)
    if #log > 10 then table.remove(log) end
end

function warnings.get()
    return log
end

return warnings
