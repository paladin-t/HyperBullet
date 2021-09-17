--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Painter = class({
	--[[ Variables. ]]

	_colors = nil,
	_color = nil,
	_multiple = false,
	_interval = nil, _ticks = 0,
	_speed = 1, _speedingDuration = nil,

	--[[ Constructor. ]]

	ctor = function (self, colors, options)
		self._colors = { }
		forEach(colors, function (c, _)
			table.insert(self._colors, c)
		end)
		self._color = self._colors[1]
		self._multiple = #self._colors > 1
		self._interval = options.interval * #self._colors
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Painter'
	end,

	--[[ Methods. ]]

	speed = function (self)
		return self._speed
	end,
	setSpeed = function (self, speed, duration)
		self._speed, self._speedingDuration = speed, duration

		return self
	end,

	reset = function (self)
		self._speed, self._speedingDuration = 1, nil

		return self
	end,

	update = function (self, delta)
		if self._multiple then
			if self._speedingDuration ~= nil then
				self._speedingDuration = self._speedingDuration - delta
				if self._speedingDuration <= 0 then
					self._speed, self._speedingDuration = 1, nil
				end
			end

			local factor = (math.sin((self._ticks / self._interval) * math.pi * 2) + 1) * 0.5
			local idx1 = math.floor(factor * #self._colors) + 1
			local idx2 = idx1 + 1
			if idx2 > #self._colors then
				idx2 = idx2 - #self._colors
			end
			local c1, c2 = self._colors[idx1], self._colors[idx2]
			local f = math.fmod(factor * #self._colors, 1)
			self._color = Color.new(
				lerp(c1.r, c2.r, f),
				lerp(c1.g, c2.g, f),
				lerp(c1.b, c2.b, f),
				lerp(c1.a, c2.a, f)
			)

			self._ticks = self._ticks + delta * self._speed
			if self._ticks >= self._interval then
				self._ticks = self._ticks - self._interval
			end
		end

		cls(self._color)
	end
})
