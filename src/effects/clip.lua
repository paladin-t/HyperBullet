--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Clip = class({
	--[[ Variables. ]]

	_game = nil,
	_content = nil,
	_width = 0, _height = 0,
	_anchor = nil,
	_scale = nil,
	_interval = nil, _ticks = 0,
	_modulators = nil,
	_speed = 1, _speedingDuration = nil,

	--[[ Constructor. ]]

	ctor = function (self, options)
		Object.ctor(self, nil, nil, nil)

		self._game = options.game
		self._anchor = options.anchor
		self._scale = options.scale or nil
		self._interval = options.interval
		self._modulators = options.modulators
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Clip'
	end,

	--[[ Methods. ]]

	content = function (self)
		return self._content
	end,
	setContent = function (self, content)
		self._content = content
		self._width, self._height = self._content.width, self._content.height

		return self
	end,

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

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		if self._speedingDuration ~= nil then
			self._speedingDuration = self._speedingDuration - delta
			if self._speedingDuration <= 0 then
				self._speed, self._speedingDuration = 1, nil
			end
		end

		local factor = 0
		if self._interval ~= nil then
			factor = self._ticks / self._interval

			self._ticks = self._ticks + delta * self._speed
			if self._ticks >= self._interval then
				self._ticks = self._ticks - self._interval
			end
		end

		local scale = self._scale or Vec2.new(1, 1)
		if self._modulators.scale ~= nil then
			local mul = self._modulators.scale(delta, factor)
			scale = scale * mul
		end
		local w, h = nil, nil
		if scale == nil then
			w, h = self._width, self._height
		else
			w, h = self._width * scale.x, self._height * scale.y
		end
		local x, y = self.x, self.y
		if self._anchor == nil then
			x, y = x - w * 0.5, y - h * 0.5
		else
			x, y = x - w * self._anchor.x, y - h * self._anchor.y
		end
		if self._modulators.translate ~= nil then
			local xOffset, yOffset = self._modulators.translate(delta, factor)
			x, y = x + xOffset, y + yOffset
		end
		local angle = 0
		if self._modulators.rotate ~= nil then
			local add = self._modulators.rotate(delta, factor)
			angle = angle + add
		end
		tex(
			self._content,
			x, y, w, h,
			0, 0, self._width, self._height,
			angle, nil
		)
		if self._modulators.shadow1 ~= nil then
			local xOffset, yOffset, col = self._modulators.shadow1(delta, factor)
			tex(
				self._content,
				x + xOffset, y + yOffset, w, h,
				0, 0, self._width, self._height,
				angle, nil,
				false, false,
				col
			)
		end
		if self._modulators.shadow2 ~= nil then
			local xOffset, yOffset, col = self._modulators.shadow2(delta, factor)
			tex(
				self._content,
				x + xOffset, y + yOffset, w, h,
				0, 0, self._width, self._height,
				angle, nil,
				false, false,
				col
			)
		end
	end
}, Object)
