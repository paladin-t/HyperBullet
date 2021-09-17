--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Camera = class({
	x = nil, y = nil,

	_shockingInterval = nil, _shockingAmplitude = nil,

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

	shock = function (self, interval, amplitude)
		self._shockingInterval, self._shockingAmplitude =
			interval, amplitude or 5

		return self
	end,

	prepare = function (self, delta)
		local offsetX, offsetY = nil, nil
		if self._shockingInterval ~= nil then
			offsetX, offsetY =
				math.random(-100, 100) / 100 * self._shockingAmplitude,
				math.random(-100, 100) / 100 * self._shockingAmplitude
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

		if self._shockingInterval ~= nil then
			self._shockingInterval = self._shockingInterval - delta
			if self._shockingInterval <= 0 then
				self._shockingInterval = nil
			end
		end

		return self
	end,

	toWorld = function (self, x, y)
		return x + self.x, y + self.y
	end,
	fromWorld = function (self, x, y)
		return x - self.x, y - self.y
	end
})
