--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local beGamepad = require 'libs/beInput/beInput_Gamepad'
local beController = require 'libs/beInput/beInput_Controller'
local beKeyCode = require 'libs/beInput/beInput_KeyCode'

--[[
Wrapper.
]]

local NAN = 0 / 0

local touch1 = { NAN, NAN, false, false }
local touch2 = { NAN, NAN, false, false }

local axises1 = { 0, 0, 0, 0, 0, 0 }
local axises2 = { 0, 0, 0, 0, 0, 0 }

local function update(_)
	local x, y, lmb, rmb = mouse()
	touch1 = touch2
	touch2 = {
		x, y, lmb, rmb
	}

	axises1 = axises2
	axises2 = {
		btn(beController.Controller.AxisLeftX, beController.Controller.first),
		btn(beController.Controller.AxisLeftY, beController.Controller.first),
		btn(beController.Controller.AxisRightX, beController.Controller.first),
		btn(beController.Controller.AxisRightY, beController.Controller.first),
		btn(beController.Controller.AxisTriggerLeft, beController.Controller.first),
		btn(beController.Controller.AxisTriggerRight, beController.Controller.first)
	}
end
local function reset()
	touch1 = { NAN, NAN, false, false }
	touch2 = { NAN, NAN, false, false }

	axises1 = { 0, 0, 0, 0, 0, 0 }
	axises2 = { 0, 0, 0, 0, 0, 0 }
end

function touch()
	return touch2[1], touch2[2], touch2[3], touch2[4]
end
function touchp()
	if Features.hasTouchScreen() then
		if touch1[3] and not touch2[3] then
			return touch1[1], touch1[2], touch1[3] and not touch2[3], touch1[4] and not touch2[4]
		end
	
		return NaN(), NaN(), false
	else
		return touch1[1], touch1[2], touch1[3] and not touch2[3], touch1[4] and not touch2[4]
	end
end

function axis(axis_, dir)
	if dir < 0 then
		return axises2[-axis_] <= -20000
	elseif dir > 0 then
		return axises2[-axis_] >= 20000
	else
		return false
	end
end
function axisp(axis_, dir)
	if dir < 0 then
		return axises1[-axis_] <= -20000 and math.abs(axises2[-axis_]) < 20000
	elseif dir > 0 then
		return axises1[-axis_] >= 20000 and math.abs(axises2[-axis_]) < 20000
	else
		return false
	end
end

--[[
Exporting.
]]

beInput = {
	version = '1.0',

	FirstRepeatDuration = 500000000,
	RepeatDuration = 50000000,

	Gamepad = beGamepad.Gamepad,
	Controller = beController.Controller,
	KeyCode = beKeyCode.KeyCode,

	update = update,
	reset = reset
}
