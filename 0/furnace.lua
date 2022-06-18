local furnace = peripheral.wrap("minecraft:furnace_0")
local _, sides = furnace.getTransferLocations()
print(sides)
