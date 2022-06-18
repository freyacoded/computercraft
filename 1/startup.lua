local config = nil
local monitor = nil
local namedInventories = nil
local touchCounter = 0
local dryRun = false
peripheral.find("modem", rednet.open)

function itemHash(item)
	return item.name .. "/" .. item.damage
end

function humanName(item)
	local lookup = config.humanName[item.hash]
	if lookup ~= nil then return lookup end

	local replacePattern =  "[^:]+:"
	local subName = item.name:gsub(replacePattern, "")
	--print(subName)
	if config.mustHaveLookup[subName] == true then return item.hash end
	return subName
end

function countItems(label, inventory, counts)
	if counts == nil then counts = {} end
	for _, item in pairs(inventory.list()) do
		local hash = itemHash(item)

		if counts[hash] == nil then
			item.hash = hash
			item.humanName = humanName(item)
			item.color = config.chestColors[label] or colors.white
			--print(textutils.serialise(item))
			counts[hash] = item
		else counts[hash].count = counts[hash].count + item.count end

	end
	return counts
end

function countIntake()
	local counts = {}
	for i, intake in ipairs(config.intakes) do
		local intake = peripheral.wrap(intake)
		if intake then
			countItems("intake", intake, counts)
		end
	end
	return counts
end

function tableToSortedList(counts)
	local list = {}
	for hash, item in pairs(counts) do
		table.insert(list, item)
	end
	table.sort(list, function (left, right)
	    return left.count > right.count
	end)
	
	return list
end

function printItems(label, list)
	monitor.clear()
	monitor.setTextScale(0.5)
	monitor.setBackgroundColor(colors.white)
	monitor.setTextColor(colors.black)
	monitor.setCursorPos(1, 1)
	monitor.clearLine()
	local labelPos = monitor.getSize()/2 - math.ceil((#label/2) - 1)
	monitor.setCursorPos(labelPos, 1)
	monitor.setCursorBlink(false)

	monitor.write(label)
	monitor.setBackgroundColor(colors.black)
	monitor.setTextColor(colors.white)

	if #list == 0 then return end

	local scale = config.itemBarScale
	local maxLog = scale(list[1].count)
	print("maxLog", maxLog)

	for i, item in ipairs(list) do
		monitor.setCursorPos(1, i + 1)
		local width, h = monitor.getSize()
		local itemColor = item.color or colors.white
		local name = item.humanName
		local count = tostring(item.count)
		local space = (" "):rep(width - #count - #name)

		local text = name .. space .. count
		local foreground = config.blit[item.color]:rep(width)
		local barLength = math.ceil((scale(item.count) / maxLog) * width)
		local background = ("f"):rep(width-barLength) .. ("7"):rep(barLength)
		print(foreground)
		print(background .. "|")
		monitor.blit(text, foreground, background)
	end
end

function render()
	local currentView = config.views[touchCounter % #config.views + 1]

	if currentView == "total" then
		local counts = {}
		for label, inventory in pairs(namedInventories) do
			countItems(label, inventory, counts)
		end
		local intakeCounts = countIntake()
		for hash, item in pairs(intakeCounts) do
			counts[hash..":I"] = item
		end

		local list = tableToSortedList(counts)
		printItems("total", list)
	elseif currentView == "intake" then
		local list = tableToSortedList(countIntake())
		printItems("intake", list)
	else
		local counts = countItems(currentView, namedInventories[currentView])
		local list = tableToSortedList(counts)
		printItems(currentView, list)
	end
end

function findSortLocation(item)
	item.hash = itemHash(item)
	item.humanName = humanName(item)
	for key, location in pairs(config.sort) do
		if item.humanName:find(key) then
			return location
		end
	end
end

function move(item, slot, from, toName) 
	print("Moving", item.count, item.humanName, "to", toName)
	if not dryRun then
		from.pushItems(config.chests[toName], slot)
	end
end

function sortIntake(inventory)
	for slot, item in pairs(inventory.list()) do
		local location = findSortLocation(item)
		if location then move(item, slot, inventory, location) end
	end
end

function sortIntakes()
	for _, name in ipairs(config.intakes) do
		local inventory = peripheral.wrap(name)
		if inventory then sortIntake(inventory) end
	end
end

while true do
	config = require("config")
	monitor = peripheral.wrap(config.monitor)

	monitor.setPaletteColour(colors.lightGray, 0xbbbbbb)
	monitor.setPaletteColour(colors.gray, 0x383838)
	monitor.setPaletteColour(colors.black, 0x000000)

	namedInventories = {}
	for label, inventoryName in pairs(config.chests) do
		inventory = peripheral.wrap(inventoryName)
		if inventory == nil then
			print(label .. " " .. inventoryName .. " not found")
		else
			namedInventories[label] = inventory
		end
	end

	render()
	sortIntakes()

	local sender, coords = rednet.receive("touch", 2)
	if coords then
		touchCounter = touchCounter + 1
		if coords.y >= 38 then 
			monitor.clear()
			os.reboot() 
		end
	end
end
