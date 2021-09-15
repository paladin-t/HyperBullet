--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Blood = class({
	--[[ Variables. ]]

	_game = nil,

	_r = 0,
	_lifetime = 20, _ticks = 0,

	--[[ Constructor. ]]

	ctor = function (self, options)
		Object.ctor(self, nil, nil, nil)

		self._game = options.game

		self._color = Color.new(200, 30, 30)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Blood'
	end,

	--[[ Methods. ]]

	resize = function (self, r)
		self._r = r

		return self
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		local fadeTime = self._lifetime * 0.7
		if self._ticks < fadeTime then
			circ(self.x, self.y, self._r, true, self._color)
		else
			local a = clamp((1 - (self._ticks - fadeTime) / (self._lifetime - fadeTime)) * 255, 0, 255)
			circ(self.x, self.y, self._r, true, Color.new(self._color.r, self._color.g, self._color.b, a))
		end
		if self._game.state.playing then
			self._ticks = self._ticks + delta
			if self._ticks >= self._lifetime then
				self:kill('disappeared', nil)
			end
		end
	end
}, Object)
