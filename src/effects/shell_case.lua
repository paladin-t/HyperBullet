--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

ShellCase = class({
	--[[ Variables. ]]

	_game = nil,

	_shape = nil,
	_lifetime = 0.75, _ticks = 0,

	--[[ Constructor. ]]

	ctor = function (self, shape, options)
		Object.ctor(self, nil, nil, nil)

		self._game = options.game
		self._shape = shape
		self._lifetime = options.lifetime

		self._color = self._shape['color']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'ShellCase'
	end,

	--[[ Methods. ]]

	reset = function (self)
		Object.reset(self)

		self._ticks = 0

		return self
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		self:_tween(delta)

		local fadeTime = self._lifetime * 0.8
		local col = nil
		if self._ticks < fadeTime then
			col = self._color
		else
			local a = clamp((1 - (self._ticks - fadeTime) / (self._lifetime - fadeTime)) * 255, 0, 255)
			col = Color.new(self._color.r, self._color.g, self._color.b, a)
		end
		local y = self._shape['type']
		if y == 'circle' then
			circ(self.x, self.y, self._shape['r'], true, col)
		elseif y == 'rect' then
			local w, h = self._shape['width'], self._shape['height']
			local x1, y1, x2, y2 = nil, nil, nil, nil
			if w <= 1 then
				x1, x2 = self.x, self.x
			else
				x1, x2 = self.x - w * 0.5, self.x + w * 0.5
			end
			if h <= 1 then
				y1, y2 = self.y, self.y
			else
				y1, y2 = self.y - h * 0.5, self.y + h * 0.5
			end
			rect(x1, y1, x2, y2, true, col)
		end
		if self._game.state.playing then
			self._ticks = self._ticks + delta
			if self._ticks >= self._lifetime then
				self:kill('disappeared', nil)
			end
		end
	end
}, Object)
