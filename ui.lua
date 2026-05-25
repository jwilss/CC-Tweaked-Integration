--========================================================--
--  ui.lua  |  BAER ASCII UI for 5x4
--========================================================--

local ui = {}
local cfg
local mon

local tabs = require("tabs")
local ae_storage = require("ae_storage")
local machines = require("machines")
local farms = require("farms")
local warningsMod = require("warnings")
local power = require("power")
local ae = require("ae")

local pulse = 1
local last = 0

function ui.init(m,c)
    mon=m cfg=c
    mon.setTextScale(cfg.ui.scale)
    mon.setBackgroundColor(cfg.ui.backgroundColor)
    mon.setTextColor(cfg.ui.textColor)
    mon.clear()
end

local function sec(title,y)
    mon.setCursorPos(1,y)
    mon.setBackgroundColor(cfg.ui.sectionBackground)
    mon.setTextColor(cfg.ui.sectionText)
    local w=mon.getSize()
    mon.write(title..string.rep("=",w-#title))
    mon.setBackgroundColor(cfg.ui.backgroundColor)
    mon.setTextColor(cfg.ui.textColor)
    return y+1
end

local function bar(p,w)
    local f=math.floor(w*(p/100))
    return "["..string.rep("#",f)..string.rep("-",w-f).."]"
end

local function pulseUpdate()
    local t=os.clock()
    if t-last>cfg.ui.warnPulseSpeed then
        last=t pulse=pulse%3+1
    end
end

------------------------------------------------------------
-- Pages
------------------------------------------------------------

local function drawPower()
    local y=2
    y=sec("[ POWER ]",y)
    local pct=power.getPercent() or 0
    local w=mon.getSize()
    mon.setCursorPos(1,y) mon.write("PWR:"..pct.."% "..bar(pct,20)) y=y+1
    mon.setCursorPos(1,y) mon.write("RF:"..(power.getTotalEnergy() or 0).." / "..(power.getTotalCapacity() or 0)) y=y+1

    mon.setCursorPos(1,y) mon.write("REACTOR:120kRF/t Fuel:87% Temp:642C") y=y+1
    mon.setCursorPos(1,y) mon.write("CELLS:4 FLUX:12 NET:142kRF/t")
end

local function drawStorage1()
    local y=2
    local o=ae_storage.getOverview()
    y=sec("[ DRIVES ]",y)
    for _,d in ipairs(o.drives or {}) do
        mon.setCursorPos(1,y)
        mon.write(d.label..":"..d.percent.."% "..bar(d.percent,10))
        y=y+1
    end

    y=sec("[ CHANNELS ]",y)
    mon.setCursorPos(1,y)
    mon.write(o.channels.used.." / "..o.channels.total.." "..bar((o.channels.used*100)/o.channels.total,10))
    y=y+1

    mon.setCursorPos(1,y)
    mon.write("ITEMS:"..o.totals.items.." TYPES:"..o.totals.types.." BUSES:"..o.totals.buses)
end

local function drawStorage2()
    local y=2
    local m=ae_storage.getMaterials()

    y=sec("[ ORES ]",y)
    for _,i in ipairs(m.ores) do
        mon.setCursorPos(1,y) mon.write(i.name..":"..i.count) y=y+1
    end

    y=sec("[ RAW ]",y)
    for _,i in ipairs(m.raw) do
        mon.setCursorPos(1,y) mon.write(i.name..":"..i.count) y=y+1
    end

    y=sec("[ INGOTS ]",y)
    for _,i in ipairs(m.ingots) do
        mon.setCursorPos(1,y) mon.write(i.name..":"..i.count) y=y+1
    end
end

local function drawMachines()
    local y=2
    local i=machines.getIF()
    y=sec("[ IF ]",y)
    mon.setCursorPos(1,y) mon.write("Crusher:"..i.crusher.." Latex:"..i.latex.." Plastic:"..i.plastic) y=y+1

    local t=machines.getThermal()
    y=sec("[ THERMAL ]",y)
    mon.setCursorPos(1,y) mon.write("Mag:"..t.mag.." Comp:"..t.comp.." Num:"..t.num) y=y+1

    local r=machines.getRFTools()
    y=sec("[ RFTools ]",y)
    mon.setCursorPos(1,y) mon.write("Recv:"..r.recv.." Energy:"..r.energy)
end

local function drawFarms()
    local y=2
    y=sec("[ ESSENCE ]",y)
    for _,e in ipairs(farms.getEssence()) do
        mon.setCursorPos(1,y) mon.write(e.name..":"..e.count) y=y+1
    end

    y=sec("[ MOB ]",y)
    for _,d in ipairs(farms.getMob()) do
        mon.setCursorPos(1,y) mon.write(d.name..":"..d.count) y=y+1
    end
end

local function drawWarnings()
    local y=2
    pulseUpdate()

    local w,h=mon.getSize()
    local bg,fg
    if pulse==1 then bg=cfg.ui.warnBackground fg=cfg.ui.warnText
    elseif pulse==2 then bg=colors.black fg=cfg.ui.warnBackground
    else bg=colors.red fg=colors.white end

    y=sec("[ WARNINGS ]",y)

    mon.setBackgroundColor(bg) mon.setTextColor(fg)
    mon.setCursorPos(1,y) mon.write(string.rep("#",w)) y=y+1

    local warn=ae.getWarnings(cfg.warningItems)
    if #warn>0 then
        local m="! WARNING: "..warn[1].label.." LOW - "..warn[1].count.." REMAINING !"
        mon.setCursorPos(1,y) mon.write(m..string.rep(" ",w-#m))
        warningsMod.add("Threshold hit")
    else
        mon.setCursorPos(1,y) mon.write("No active warnings"..string.rep(" ",w-18))
    end
    y=y+1

    mon.setCursorPos(1,y) mon.write(string.rep("#",w))
    mon.setBackgroundColor(cfg.ui.backgroundColor)
    mon.setTextColor(cfg.ui.textColor)
    y=y+2

    mon.setCursorPos(1,y) mon.write("LOG: ")
    local log=warningsMod.get()
    for i=1,math.min(#log,3) do
        mon.setCursorPos(1,y+i) mon.write(log[i])
    end
end

------------------------------------------------------------
-- Draw
------------------------------------------------------------
function ui.draw()
    mon.clear()
    tabs.drawBar(mon)

    local t=tabs.getTab()
    if t==1 then drawPower()
    elseif t==2 then
        if tabs.getStoragePage()==1 then drawStorage1() else drawStorage2() end
    elseif t==3 then drawMachines()
    elseif t==4 then drawFarms()
    elseif t==5 then drawWarnings()
    end
end

return ui
