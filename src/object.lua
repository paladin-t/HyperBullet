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
	_disappearing = nil, _disappearingTicks = 0,
	_aabb = nil,

	_sprite = nil,
	_spriteWidth = 0, _spriteHeight = 0,
	_spriteAngle = 0,
	_spriteUpdater = nil,

	_walker = nil,
	_isBlocked = nil,
	_slidable = 5,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked)
		self.box = box

		if sprite then
			self._sprite = sprite
			self._sprite:play('idle', false)
			self._spriteWidth, self._spriteHeight =
				self._sprite.width, self._sprite.height
		end

		if isBlocked then
			self._walker = Walker.new()
			self._walker.objectSize = Vec2.new(self.box:width(), self.box:height())
			self._walker.tileSize = Vec2.new(16, 16)
			self._walker.offset = Vec2.new(self.box:width() * 0.5, self.box:height())
			self._isBlocked = isBlocked
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
	revive = function (self)
		self._dead = false
		self._disappearing, self._disappearingTicks = nil, 0

		return self
	end,
	disappear = function (self)
		self._disappearing, self._disappearingTicks = 5, 0

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

	update = function (self, delta)
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

		if res then
			local visible = true
			if self._disappearing then
				local INTERVAL = 0.3
				self._disappearingTicks = self._disappearingTicks + delta
				if self._disappearingTicks > INTERVAL then
					self._disappearingTicks = self._disappearingTicks - INTERVAL
					self._disappearing = self._disappearing - 1
					if self._disappearing <= 0 then
						self:kill()
						self._disappearing, self._disappearingTicks = nil, 0
					end
				end
				if self._disappearingTicks > INTERVAL * 0.5 then
					visible = false
				end
			end
			if visible then
				spr(
					res,
					self.x - self._spriteWidth * 0.5, dstY, dstW, dstH,
					self._spriteAngle
				)
			end
		end

		if DEBUG then
			rect(
				self._aabb:xMin(), self._aabb:yMin(),
				self._aabb:xMax(), self._aabb:yMax(),
				false,
				Color.new(255, 0, 0)
			)
		end
	end,

	_move = function (self, dx, dy)
		local newDir = self._walker:solve(
			Vec2.new(self.x, self.y), Vec2.new(dx, dy),
			self._isBlocked,
			self._slidable
		)

		return newDir
	end
}, Event)
