---@class CInventory
---@field name string
---@field label string
---@field peripheral inventory?
local _ = {}

---@param name string
---@param label string
---@return CInventory
function inventory(name, label)
    return { name = name, label = label, peripheral = peripheral.wrap(name) }
end

local c = {}

---@class Config
---@field passive table<integer, CInventory>
---@field active table<integer, CInventory>
---@field labelColors table<string, integer>
---@field monitors table<string, string>
return {
    passive = {
        inventory("quark:quark_chest_1", "stone"),
        inventory("minecraft:chest_4", "wood"),
    },
    active = {
        inventory("quark:quark_chest_0", "intake"),
    },
    labelColors = {
        stone = colors.blue,
        wood = colors.green,
        intake = colors.red
    },
    monitors = {
        logger = "monitor_1",
        display = "monitor_2",
    },
}
