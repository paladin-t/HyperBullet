--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'event'

Object = class({
	--[[ Variables. ]]

	maxHp = 0, hp = 0,
	atk = 0,

	x = 0, y = 0,
	box = nil,

	_dead = false,
	_aabb = nil,

	_sprite = nil,
	_spriteWidth = 0, _spriteHeight = 0,
	_spriteAngle = 0,
	_spriteUpdater = nil,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box)
		self.box = box

		if sprite then
			self._sprite = sprite
			self._sprite:play('idle', false)
			self._spriteWidth, self._spriteHeight =
				self._sprite.width, self._sprite.height
		end
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Object'
	end,

	--[[ Methods. ]]

	dead = function (self)
		return self._dead
	end,
	kill = function (self)
		self._dead = true

		self:trigger('dead')

		return self
	end,

	play = function (self, motion, reset, loop, played)
		if not self._sprite then
			return false, nil
		end
		if reset == nil then reset = true end
		if loop == nil then loop = true end

		local success, duration = self._sprite:play(motion, reset, loop)
		if success and played then
			local ticks = 0
			self._spriteUpdater = function (delta)
				ticks = ticks + delta
				if ticks >= duration then
					ticks = ticks - duration
					played()
					if not loop then
						self._spriteUpdater = nil
					end
				end
			end
		end

		return success, duration
	end,

	behave = function (self, delta, hero)
		error('Implement me.')
	end,

	update = function (self, delta, visible)
		if self._spriteUpdater then
			self._spriteUpdater(delta)
		end

		local res = self._sprite
		local dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - self.box:yMax(),
			self._spriteWidth, self._spriteHeight

		self._aabb = Recti.new(
			dstX + self.box:xMin(), dstY + self.box:yMin(),
			dstX + self.box:xMax(), dstY + self.box:yMax()
		)

		if res and visible then
			spr(
				res,
				self.x - self._spriteWidth * 0.5, dstY, dstW, dstH,
				self._spriteAngle
			)
		end

		if DEBUG then
			rect(
				self._aabb:xMin(), self._aabb:yMin(),
				self._aabb:xMax(), self._aabb:yMax(),
				false,
				Color.new(255, 0, 0)
			)
		end
	end
}, Event)
