--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local STACK_SIZE = 5

Text = class({
	--[[ Variables. ]]

	_worldSpace = false,
	_content = nil,
	_font = nil,
	_color = nil,
	_pivot = Vec2.new(0, 0), -- Relative position in local space, normally from 0 to 1.
	_style = 'wave',
	_depth = 10,
	_interval = nil, _phase = 0,
	_lifetime = nil, _ticks = 0,
	_characters = nil,
	_contentWidth = 0, _contentHeight = 0,

	--[[ Constructor. ]]

	ctor = function (self, x, y, content, options)
		Object.ctor(self, nil, nil, nil)

		self.x, self.y = x, y
		self._worldSpace = options.worldSpace
		self._content = content
		self._font = options.font
		self._color = options.color
		self._pivot = options.pivot
		self._style = options.style
		self._depth = options.depth
		self._interval = options.interval
		self._lifetime = options.lifetime
		local MARGIN = 1
		self._characters = { }
		local x, y = 0, 0
		for i, ch in characters(self._content) do
			local textWidth, textHeight = measure(ch, self._font)
			table.insert(
				self._characters,
				{
					index = i,
					character = ch,
					width = textWidth, height = textHeight,
					x = x, y = y, z = Stack.new(STACK_SIZE),
					colorStack = Stack.new(STACK_SIZE)
				}
			)
			x = x + textWidth + MARGIN
			self._contentWidth = self._contentWidth + textWidth + MARGIN
			if textHeight > self._contentHeight then
				self._contentHeight = textHeight
			end
		end
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Text'
	end,

	--[[ Methods. ]]

	content = function (self)
		return self._content
	end,
	setContent = function (self, content)
		self._content = content

		return self
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		if self._lifetime ~= nil then
			self._ticks = self._ticks + delta
			if self._ticks >= self._lifetime then
				self:kill('disappeared', nil)
			end
		end

		local stackSize = 0
		self._phase = self._phase + delta
		if self._phase >= self._interval then
			self._phase = self._phase - self._interval
		end
		local c1, c2 = self._color[1], self._color[2]
		for i, ch in ipairs(self._characters) do
			if self._style == 'wave' then
				local factor = math.sin((self._phase / self._interval + i * 0.075) * math.pi * 2)
				local f = (factor + 1) * 0.5
				local col = Color.new(
					lerp(c1.r, c2.r, f),
					lerp(c1.g, c2.g, f),
					lerp(c1.b, c2.b, f),
					lerp(c1.a, c2.a, f)
				)
				ch.z:push(f)
				ch.colorStack:push(col)
				if ch.z:count() > stackSize then
					stackSize = ch.z:count()
				end
			elseif self._style == 'blink' then
				local factor = math.sin((self._phase / self._interval) * math.pi * 2)
				local f = (factor + 1) * 0.5
				local col = Color.new(
					lerp(c1.r, c2.r, f),
					lerp(c1.g, c2.g, f),
					lerp(c1.b, c2.b, f),
					lerp(c1.a, c2.a, f)
				)
				ch.z:push(1)
				ch.colorStack:push(col)
				if ch.z:count() > stackSize then
					stackSize = ch.z:count()
				end
			end
		end

		font(self._font)
		local x, y = nil, nil
		if self._worldSpace then
			x, y =
				self.x - self._contentWidth * self._pivot.x,
				self.y - self._contentHeight * self._pivot.y
		else
			local canvasWidth, canvasHeight = Canvas.main:size()
			x, y =
				canvasWidth * self.x - self._contentWidth * self._pivot.x,
				canvasHeight * self.y - self._contentHeight * self._pivot.y
		end
		for k = 1, stackSize do
			for _, ch in ipairs(self._characters) do
				local z = -ch.z:get(k) * self._depth * ((k - 1) / (STACK_SIZE - 1))
				local col = ch.colorStack:get(k)
				local f = k / STACK_SIZE * 255
				col = col * Color.new(f, f, f, 255)
				text(ch.character, x + ch.x, y + ch.y + z, col)
			end
		end
		font(nil)
	end
}, Object)
