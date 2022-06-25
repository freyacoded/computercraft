local ac = {}

---@class InventoryItems
---@field inventory CInventory
---@field name string
---@field damage integer
---@field count integer
---@field displayName string
local _

---@class ItemSum
---@field label string
---@field name string
---@field damage integer
---@field count integer
---@field displayName string
local __

---@type Config
ac.config = require("config")

peripheral.find("modem", rednet.open)

ac.blit = {
    [1] = "0",
    [2] = "1",
    [4] = "2",
    [8] = "3",
    [16] = "4",
    [32] = "5",
    [64] = "6",
    [128] = "7",
    [256] = "8",
    [512] = "9",
    [1024] = "a",
    [2048] = "b",
    [4096] = "c",
    [8192] = "d",
    [16384] = "e",
    [32768] = "f"
}

function log(string, level)
    local message = {
        level = level,
        label = os.getComputerLabel() or "Unknown",
        message = string,
    }
    rednet.broadcast(message, "aclog")
end

function ac.info(string)
    log(string, "info")
end

function ac.error(string)
    log(string, "error")
end

---@param item ItemInfo
---@return string
function itemHash(item)
    return item.name .. "/" .. item.damage
end

---@param inventory CInventory
---@return table<string, InventoryItems>
function ac.countInventory(inventory)
    local items = {}
    if not inventory.peripheral then return {} end
    for slot, item in pairs(inventory.peripheral.list()) do
        local hash = itemHash(item)
        local contained = items[hash]
        if not contained then
            items[hash] = {
                inventory = inventory,
                name = item.name,
                damage = item.damage,
                count = item.count,
                displayName = inventory.peripheral.getItemMeta(slot).displayName
            }
        else
            contained.count = contained.count + item.count
        end
    end
    return items
end

---@param inventories table<integer, CInventory>
---@return table<string, table<string, ItemSum>>
function ac.countInventoryByLabel(inventories)
    local counts = {}

    for _, inventory in ipairs(inventories) do
        local labelCounts = counts[inventory.label]
        if not labelCounts then
            labelCounts = {}
            counts[inventory.label] = labelCounts
        end

        for hash, item in pairs(ac.countInventory(inventory)) do
            local itemEntry = labelCounts[hash]
            if not itemEntry then
                labelCounts[hash] = {
                    label = inventory.label,
                    name = item.name,
                    damage = item.damage,
                    count = item.count,
                    displayName = item.displayName
                }
            else
                itemEntry.count = itemEntry.count + item.count
            end
        end
    end

    return counts
end

---@return table<integer, CInventory>
function ac.getAllInventories()
    t = {}
    for _, v in pairs(ac.config.active) do table.insert(t, v) end
    for _, v in pairs(ac.config.passive) do table.insert(t, v) end
    return t
end

---@param name string
---@return Monitor?
function ac.getMonitor(name)
    local n = ac.config.monitors[name]
    if not n then return end
    return peripheral.wrap(n)
end

function ac.setPalette(monitor)
    monitor.setPaletteColour(colors.lightGray, 0xbbbbbb)
	monitor.setPaletteColour(colors.gray, 0x383838)
	monitor.setPaletteColour(colors.black, 0x000000)
	monitor.setPaletteColour(colors.blue, 0x6666ff)
end

return ac
