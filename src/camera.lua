--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Camera = class({
	x = nil, y = nil,

	_shocking = nil,

	ctor = function (self)
	end,

	__tostring = function (self)
		return 'Camera'
	end,

	get = function (self)
		return self.x, self.y
	end,
	set = function (self, x, y)
		self.x, self.y = x, y

		return self
	end,
	reset = function (self)
		self.x, self.y = nil, nil

		return self
	end,

	shock = function (self, interval)
		self._shocking = interval

		return self
	end,

	prepare = function (self, delta)
		local offsetX, offsetY = nil, nil
		if self._shocking ~= nil then
			offsetX, offsetY =
				math.random(-100, 100) / 100 * 5, math.random(-100, 100) / 100 * 5
		end

		if offsetX ~= nil --[[ or offsetY ~= nil ]] then
			camera(self.x + offsetX, self.y + offsetY)
		else
			camera(self.x, self.y)
		end

		return self
	end,
	finish = function (self, delta)
		camera()

		if self._shocking ~= nil then
			self._shocking = self._shocking - delta
			if self._shocking <= 0 then
				self._shocking = nil
			end
		end

		return self
	end,
})
