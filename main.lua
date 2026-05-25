--========================================================--
--  main.lua  |  BAER Main
--========================================================--

local ui=require("ui")
local cfg=require("config")
local tabs=require("tabs")

local function findMon()
    for _,n in ipairs(peripheral.getNames()) do
        if peripheral.hasType(n,"monitor") then return peripheral.wrap(n) end
    end
    error("No monitor found")
end

local mon=findMon()
ui.init(mon,cfg)

while true do
    ui.draw()
    local timer=os.startTimer(cfg.updateInterval)
    local e,k=os.pullEvent()
    if e=="key" then tabs.handleKey(k) end
end
