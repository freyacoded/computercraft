local beeOutputName = "minecraft:chest_3"
local combOutputName = "minecraft:ironchest_iron_5"

function startsWith(text, prefix)
	if text == nil then return false end
    return text:find(prefix, 1, true) == 1
end

function getOutputItems(house, filter)
	local output = house.list()
	output[1] = nil
	output[2] = nil
	if filter == nil then return output end

	for slot, item in pairs(output) do
		if not filter(item) then output[slot] = nil end
	end
	return output
end

function moveBee(house, isPrincess)
	local prefix = "forestry:bee_drone"
	local slot = 2
	if isPrincess then
		prefix = "forestry:bee_princess"
		slot = 1
	end

	local chosenSlot = nil
	for slot, item in pairs(getOutputItems(house)) do
		if startsWith(item.name, prefix) then
			chosenSlot = slot
			break
		end
	end

	if chosenSlot == nil then return end

	local moved = house.pullItems("self", chosenSlot, 1, slot)
	local houseName = peripheral.getName(house)
	if moved > 0 and isPrincess then
		print(houseName .. ": Inserted princess")
	elseif moved > 0 then
		print(houseName .. ": Inserted drone")
	end
end

function handleBeehouse(house)
	local houseName = peripheral.getName(house)
	local output = house.list()
	local queenSlotItem = output[1]
	local droneSlotItem = output[2]
	output[1] = nil
	output[2] = nil

	if not queenSlotItem == nil then print(houseName .. ": Item in queen slot: " .. queenSlotItem.name) end
	if not droneSlotItem == nil then print(houseName .. ": Item in drone slot: " .. droneSlotItem.name) end

	if queenSlotItem == nil then moveBee(house, true) end
	if droneSlotItem == nil and 
		(queenSlotItem == nil or not startsWith(queenSlotItem.name, "forestry:bee_queen")) then
			moveBee(house, false)
	end

	for slot, item in pairs(output) do
		print(houseName .. ": Item in output: " .. item.name)
		if startsWith(item.name, "forestry:bee_drone") then
			local moved = house.pushItems(beeOutputName, slot)
			print(houseName .. ": Moved " .. moved .. " drones")
		elseif startsWith(item.name, "forestry:bee_comb") or startsWith(item.name, "magicbees:beecomb") then
			local moved = house.pushItems(combOutputName, slot)
			print(houseName .. ": Moved " .. moved .. " combs")
		end
	end
end

while true do
	sleep(1)
	local houses = { peripheral.find("forestry:bee_house") }
	for _, house in pairs(houses) do
	 	local success, err = pcall(handleBeehouse, house)
	 	if not success then
			local houseName = peripheral.getName(house)
			print(houseName .. ": " .. err)
	 	end
	end
end
