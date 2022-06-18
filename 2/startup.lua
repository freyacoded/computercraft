local chest = peripheral.find("minecraft:chest")
local monitor = peripheral.find("monitor")

monitor.setTextScale(0.5)
while true do 
	local i = 1
	monitor.clear()
	for slot, item in pairs(chest.list()) do
		monitor.setCursorPos(1, i)
		print(textutils.serialise(item))
		monitor.write(slot .. " " .. item.name)
		if item.damage ~= nil then monitor.write(" dmg " .. item.damage) end
		i = i + 1
	end
	sleep(1)
end