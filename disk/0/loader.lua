---@type string
local programPath = ...
local program = require(programPath)
local ac = require("ac")
local nextTimer = -1

local pendingReboot = false
local originalModificationTimes = {}

function addFileWatch(file)
	file = shell.resolve(file)..".lua"
	originalModificationTimes[file] = fs.attributes(file).modification
end

addFileWatch("loader")
addFileWatch("ac")
addFileWatch("config")
addFileWatch(programPath)

function startTimer()
	os.cancelTimer(nextTimer)
	nextTimer = os.startTimer(program.updateInterval or 2)
end

function handleCall(fun, ...)
	if not fun then return end
	local result = {pcall(fun, ...)}
	local success = table.remove(result, 1)
	if not success then
		ac.error(result[1])
		return
	end
	return result
end

function checkModified()
	for path, modified in pairs(originalModificationTimes) do
		if fs.attributes(path).modification ~= modified then
			print(path, "modified, requesting reboot...")
			pendingReboot = true
			if program.mayReboot == nil or handleCall(program.mayReboot) then
				os.reboot()
			end
		end
	end
end

ac.info("Started " .. programPath)
handleCall(program.on.update)
startTimer()

while true do
	local event = {os.pullEvent()}
	local eventName = event[1]
	table.remove(event, 1)

	if eventName == "timer" then
		if event[1] == nextTimer then
			if pendingReboot and handleCall(program.mayReboot) then os.reboot() end
			if not pendingReboot then checkModified() end

			handleCall(program.on.update)
			startTimer()
		end
	elseif eventName == "rednet_message" and program.rednet then
		local sender, message, protocol = unpack(event)
		handleCall(program.rednet[protocol], sender, message, protocol)
	end

	handleCall(program.on[eventName], unpack(event))
end
