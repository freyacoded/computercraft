---@type string
local programPath = ...
local program = require(programPath)
local nextTimer = os.startTimer(program.updateInterval or 2)
if not program.on then program.on = {} end

local pendingReboot = false
local originalModificationTimes = {
	[shell.getRunningProgram()] = fs.attributes(shell.getRunningProgram()).modification,
	[programPath] = fs.attributes(programPath).modification
	-- TODO: Add config
}

function startTimer() 
	nextTimer = os.startTimer(program.updateInterval or 2)
end

function handleCall(fun, ...)
	if not fun then return end
	local result = {pcall(fun, ...)}
	local success = table.remove(result, 1)
	if not result[1] then 
		print("Error: " .. result[1])
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

startTimer()

while true do
	local event = {os.pullEvent()}
	table.remove(event, 1)
	local eventName = event[1]

	if eventName == "timer" then
		if event[2] == nextTimer then
			if pendingReboot and handleCall(program.mayReboot) then os.reboot() end
			if not pendingReboot then checkModified() end

			handleCall(program.on.update)
			startTimer()
		end
	elseif eventName == "rednet_message" and program.rednet then
		local sender, message, protocol = unpack(event)
		handleCall(program.rednet[eventName], sender, message, protocol)
	end

	handleCall(program.on[eventName], unpack(event))
end
