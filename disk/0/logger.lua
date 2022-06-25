local module = { on = {}, rednet = {} }
local ac = require("ac")

module.updateInterval = 2

local monitor = ac.getMonitor("logger")
if monitor then
    monitor.setTextScale(0.5)
end

function module.rednet.aclog(sender, message)
    monitor = ac.getMonitor("logger")
    if not monitor then return end
    local _, h = monitor.getSize()
    monitor.scroll(1)
    monitor.setCursorPos(1, h)

    local label = message.label
    label = string.gsub(label, "Lab ", "")
    monitor.write(label .. ": " .. message.message)
    print(label .. ": " .. message.message)
end

return module
