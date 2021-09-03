--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local STACK_SIZE = 5

Text = class({
	--[[ Variables. ]]

	_x = nil, _y = nil, -- Relative position in screen space, normally from 0 to 1.
	_content = nil,
	_font = nil,
	_color = nil,
	_pivot = Vec2.new(0, 0), -- Relative position in local space, normally from 0 to 1.
	_interval = nil,

	_ticks = 0,
	_characters = nil,
	_contentWidth = 0, _contentHeight = 0,

	--[[ Constructor. ]]

	ctor = function (self, x, y, content, options)
		self._x, self._y = x, y
		self._content = content
		self._font = options.font
		self._color = options.color
		self._pivot = options.pivot
		self._interval = options.interval

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

	update = function (self, delta)
		local stackSize = 0
		self._ticks = self._ticks + delta
		if self._ticks >= self._interval then
			self._ticks = self._ticks - self._interval
		end
		local c1, c2 = self._color[1], self._color[2]
		for i, ch in ipairs(self._characters) do
			local factor = math.sin((self._ticks / self._interval + i * 0.075) * math.pi * 2)
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
		end

		local canvasWidth, canvasHeight = Canvas.main:size()

		font(self._font)
		local x, y =
			canvasWidth * self._x - self._contentWidth * self._pivot.x,
			canvasHeight * self._y - self._contentHeight * self._pivot.y
		for k = 1, stackSize do
			for _, ch in ipairs(self._characters) do
				local z = -ch.z:get(k) * 10 * ((k - 1) / (STACK_SIZE - 1))
				local col = ch.colorStack:get(k)
				local a = col.a * (k / STACK_SIZE)
				if k == stackSize then
					text(ch.character, x + ch.x - 1, y + ch.y + z, Color.new(0, 0, 0, 100))
					text(ch.character, x + ch.x + 1, y + ch.y + z, Color.new(0, 0, 0, 100))
					text(ch.character, x + ch.x, y + ch.y + z - 1, Color.new(0, 0, 0, 100))
					text(ch.character, x + ch.x, y + ch.y + z + 1, Color.new(0, 0, 0, 100))
				end
				text(ch.character, x + ch.x, y + ch.y + z, Color.new(col.r, col.g, col.b, a))
			end
		end
		font(nil)
	end
})
