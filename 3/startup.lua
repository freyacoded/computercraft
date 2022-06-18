peripheral.find("modem", rednet.open)
while true do
	local event, id, x, y = os.pullEvent("monitor_touch")
	rednet.broadcast({ x=x,y=y}, "touch")
	print(x, y)
end
