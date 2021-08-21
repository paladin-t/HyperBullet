--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

--[[
Controller.
]]

local function startsWith(str, part)
	return part == '' or str:sub(1, #part) == part
end

local devices = { }
local first = nil
local swapAB, swapXY = false, false

local index = 1
repeat
	local attached, name, type = controller(index)
	if attached then
		local swap = (not not string.find(string.lower(type), 'nintendo'))
			or (not not string.find(string.lower(type), 'playstation'))
		if not first then
			print('First attached controller index: ' .. tostring(index) .. '.')

			first = -index
			if swap then
				print('Swapped controller buttons: A-B, X-Y.')
			
				swapAB, swapXY = true, true
			end
		end
		table.insert(
			devices,
			{
				index = -index,
				attached = attached,
				name = name,
				type = type,
				swap = swap
			}
		)
	end
	index = index + 1
until not attached and not name and not type

if (not swapAB or not swapXY) and startsWith(Platform.os, 'Nintendo') then
	print('Swapped controller buttons: A-B, X-Y.')

	swapAB, swapXY = true, true
end

local Controller = {
	first = first or -1,
	devices = devices,

	A = not swapAB and 0 or 1,
	B = not swapAB and 1 or 0,
	X = not swapXY and 2 or 3,
	Y = not swapXY and 3 or 2,
	Back = 4,
	Guide = 5,
	Start = 6,
	LeftStick = 7,
	RightStick = 8,
	LeftShoulder = 9,
	RightShoulder = 10,
	DpadUp = 11,
	DpadDown = 12,
	DpadLeft = 13,
	DpadRight = 14,

	AxisLeftX = -1,
	AxisLeftY = -2,
	AxisRightX = -3,
	AxisRightY = -4,
	AxisTriggerLeft = -5,
	AxisTriggerRight = -6
}

--[[
Exporting.
]]

return {
	Controller = Controller
}
