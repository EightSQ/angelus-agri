-- angelus-agri.lua
--
-- ComputerCraft farm script by EightSQ
-- (c) 2018 EightSQ



local function printUsage()
	print( "Usage:" )
	print( "angelus <bounding-block>" )
end

local tArgs = { ... }
if #tArgs < 1 then
	printUsage()
	return
end

local bounding = tArgs[1] --read bounding block from commandline
local position = { x=0, y=0, v=0 } --initialize 0,0 position (chest position)
local INSPECTION_SLOT = 1

local function refuelProcess()
	turtle.select(16)
	while turtle.refuel() == false do
		print("Need fuel...")
		while true do
			sInput = read()
			if sInput ~= nil or sInput ~= "" then
				break
			end
		end
	end
end

local function moveForward()
	local success = turtle.forward()
	if success then
		if position.v == 0 then
			position.x += 1
		elseif position.v == 1 then
			position.y += 1
		elseif position.v == 2 then
			position.x -= 1
		elseif position.v == 3 then
			position.y -= 1
		end
	end
end

local function returnToHome()
	-- go to x = 0
	if position.x > 0 then
		repeat
			turtle.turnRight()
			position.v = (position.v + 1) % 4
		until position.v == 2
		while position.x > 0 do
			moveForward()
		end
	elseif position.x < 0 then
		repeat
			turtle.turnRight()
			position.v = (position.v + 1) % 4
		until position.v == 0
		while position.x < 0 do
			moveForward()
		end
	end

	-- go to y = 0
	if position.y > 0 then
		repeat
			turtle.turnRight()
			position.v = (position.v + 1) % 4
		until position.v == 3
		while position.y > 0 do
			moveForward()
		end
	elseif position.y < 0 then
		repeat
			turtle.turnRight()
			position.v = (position.v + 1) % 4
		until position.v == 1
		while position.y < 0 do
			moveForward()
		end
	end

	-- turn to chest and drop all items
	repeat
		turtle.turnRight()
		position.v = (position.v + 1) % 4
	until position.v == 2
	for i=1,15 do
		turtle.select(i)
		turtle.drop()
	end

	-- turn back to field
	turtle.turnRight()
	position.v = (position.v + 1) % 4
	turtle.turnRight()
	position.v = (position.v + 1) % 4
end

local function selectFreeCropSlot()
	local slot = 2
	while turtle.getItemCount(slot) == 64 do
		slot += 1
	end

	return slot, turtle.getItemSpace(slot)
end

local function selectFreeSeedSlot()
	local slot = 15
	while turtle.getItemCount(slot) == 64 do
		slot -= 1
	end

	return slot, turtle.getItemSpace(slot)
end

local function fieldEndTurn()
	if position.v == 0 then
		moveForward()
		turtle.turnRight()
		position.v = (position.v + 1) % 4
		moveForward()
		local success, iData = turtle.inspect()
		if iData.name == bounding then
			returnToHome()
		else
			turtle.turnRight()
			position.v = (position.v + 1) % 4
		end
	else
		moveForward()
		turtle.turnLeft()
		position.v = (position.v + 3) % 4
		moveForward()
		local success, iData = turtle.inspect()
		if iData.name == bounding then
			returnToHome()
		else
			turtle.turnLeft()
			position.v = (position.v + 3) % 4
		end
	end
end

local function throwItem()
	turtle.turnRight()
	turtle.turnRight()
	turtle.drop()
	turtle.turnRight()
	turtle.turnRight()
end

while true do
	if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel < 1 then
		refuelProcess()
	end
	local success, iData = turtle.inspect()
	if iData.name == "air" then
		fieldEndTurn()
	else
		turtle.dig()
		turtle.select(INSPECTION_SLOT)
		turtle.suck()
		for 1,2 do
			local pickedItem = turtle.getItemDetail()
			if pickedItem.name == "wheat_seeds" then
				turtle.place()
				if pickedItem.count > 1 then -- store the rest
					local rest = pickedItem.count - 1
					while rest ~= 0 do
						local slot,space == selectFreeSeedSlot()
						if space <= rest then
							turtle.transferTo(slot, space)
							rest -= space
						else
							turtle.transferTo(slot)
							break
						end
					end
			elseif pickedItem.name == "wheat" then
				local rest = pickedItem.count
				while rest ~= 0 do
					local slot,space == selectFreeSeedSlot()
					if space <= rest then
						turtle.transferTo(slot, space)
						rest -= space
					else
						turtle.transferTo(slot)
						break
					end
				end
			else -- unknown item routine
				throwItem()
			end
		end
		moveForward()
	end
end
