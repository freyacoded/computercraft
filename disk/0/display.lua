local module = { on = {}, rednet = {} }
local ac = require("ac")
local itemBarScale = math.log
local touchCounter = 0

---@param counts table<string, table<string, ItemSum>>
---@return table<integer, ItemSum>
function labelCountsToSortedList(counts)
    local list = {}
    for _, labelList in pairs(counts) do
        for _, item in pairs(labelList) do
            table.insert(list, item)
        end
    end

	table.sort(list, function (left, right)
	    return left.count > right.count
	end)

	return list
end

---@param monitor Monitor
---@param title string
---@param list table<integer, ItemSum>
function printItems(monitor, title, list)
	monitor.clear()
	monitor.setTextScale(0.5)
	monitor.setBackgroundColor(colors.white)
	monitor.setTextColor(colors.black)
	monitor.setCursorPos(1, 1)
	monitor.clearLine()
	local titlePos = monitor.getSize()/2 - math.ceil((#title/2) - 1)
	monitor.setCursorPos(titlePos, 1)
	monitor.setCursorBlink(false)

	monitor.write(title)
	monitor.setBackgroundColor(colors.black)
	monitor.setTextColor(colors.white)

	if #list == 0 then return end

	local scale = itemBarScale
	local maxLog = scale(list[1].count)

	for i, item in ipairs(list) do
		monitor.setCursorPos(1, i + 1)
		local width, h = monitor.getSize()
		local itemColor = ac.config.labelColors[item.label] or colors.white
		local name = item.displayName
		local count = tostring(item.count)
		local space = (" "):rep(width - #count - #name)

		local text = name .. space .. count
		local foreground = ac.blit[itemColor]:rep(width)
		local barLength = math.ceil((scale(item.count) / maxLog) * width)
		local background = ("f"):rep(width-barLength) .. ("7"):rep(barLength)
		monitor.blit(text, foreground, background)
	end
end

function module.on.update()
    local monitor = ac.getMonitor("display") 
    if not monitor then return end
    ac.setPalette(monitor)

	local views = ac.getLabels()
	table.insert(views, 1, "total")
	local view = views[(#views % touchCounter) + 1]

	local counts
	if view == "total" then
		counts = ac.countInventoryByLabel(ac.getAllInventories())
	else
		counts = ac.countInventoryByLabel(ac.getInventoriesOf(view))
	end

    printItems(monitor, "total", labelCountsToSortedList(counts))
end

function module.on.touch()
	touchCounter = touchCounter + 1
	module.on.update()
end

return module
