local ui = require("ui")
local cfg = {}

local function findMon()
    for _, n in ipairs(peripheral.getNames()) do
        if peripheral.getType(n) == "monitor" then
            return peripheral.wrap(n)
        end
    end
    error("No monitor found")
end

local mon = findMon()
ui.init(mon, cfg)

while true do
    ui.draw()
    sleep(1)
end
