--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Object = class({
	--[[ Variables. ]]

	maxHp = 0, hp = 0,
	atk = 0,

	x = 0, y = 0,
	box = nil,

	_dead = false,
	_disappearable = true, _disappearing = nil, _disappearingTicks = 0,
	_collider = nil,

	_sprite = nil,
	_spriteWidth = 0, _spriteHeight = 0,
	_spriteAngle = 0,
	_spriteUpdater = nil,
	_shapeLine = nil,
	_shapeLines = nil,
	_shapeHeadPosition = nil,
	_color = Color.new(0, 255, 0),

	_walker = nil,
	_raycaster = nil,
	_isBlocked = nil,
	_slidable = 5,

	--[[ Constructor. ]]

	ctor = function (self, resource, box, isBlocked)
		self.box = box

		if resource.__name == 'Sprite' then
			self._sprite = resource
			self._sprite:play('idle', false)
			self._spriteWidth, self._spriteHeight =
				self._sprite.width, self._sprite.height
		elseif resource['type'] == 'line' then
			self._shapeLine = resource
		elseif resource['type'] == 'lines' then
			self._shapeLines = resource
		end

		if isBlocked then
			self._walker = Walker.new()
			self._walker.objectSize = Vec2.new(self.box:width(), self.box:height())
			self._walker.tileSize = Vec2.new(16, 16)
			self._walker.offset = Vec2.new(self.box:width() * 0.5, self.box:height() * 0.5)
			self._isBlocked = isBlocked
		end
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Object'
	end,

	--[[ Methods. ]]

	hurt = function (self, other)
		self.hp = math.max(self.hp - other.atk, 0)
		if self.hp == 0 then
			self:kill('killed')
		end

		return self
	end,
	dead = function (self)
		return self._dead
	end,
	kill = function (self, reason)
		self._dead = true

		self:trigger('dead', reason)

		return self
	end,
	revive = function (self)
		self._dead = false
		self._disappearing, self._disappearingTicks = nil, 0
		self._shapeHeadPosition = nil

		return self
	end,
	disappearable = function (self)
		return self._disappearable
	end,
	setDisappearable = function (self, disappearable)
		self._disappearable = disappearable

		return self
	end,
	disappear = function (self)
		if self._disappearable and self._disappearing == nil then
			self._disappearing, self._disappearingTicks = 5, 0
		end

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

		local sprite, shapeLine, shapeLines =
			self._sprite, self._shapeLine, self._shapeLines
		local dstX, dstY, dstW, dstH = self:_build(dstX, dstY, dstW, dstH)

		local visible = true
		if self._disappearing ~= nil then
			local INTERVAL = 0.3
			self._disappearingTicks = self._disappearingTicks + delta
			if self._disappearingTicks > INTERVAL then
				self._disappearingTicks = self._disappearingTicks - INTERVAL
				self._disappearing = self._disappearing - 1
				if self._disappearing <= 0 then
					self:kill('disappeared')
					self._disappearing, self._disappearingTicks = nil, 0
				end
			end
			if self._disappearingTicks > INTERVAL * 0.5 then
				visible = false
			end
		end
		if visible then
			if sprite ~= nil then
				spr(
					sprite,
					dstX, dstY, dstW, dstH,
					self._spriteAngle
				)
			elseif shapeLine ~= nil then
				if self._shapeHeadPosition == nil then
					self._shapeHeadPosition = Vec2.new(dstX, dstY)
				end
				line(
					self._shapeHeadPosition.x, self._shapeHeadPosition.y,
					dstX, dstY,
					shapeLine['color']
				)
			elseif shapeLines ~= nil then
				if self._shapeHeadPosition == nil then
					self._shapeHeadPosition = Vec2.new(dstX, dstY)
				end
				local pos = Vec2.new(dstX, dstY)
				local diff = pos - self._shapeHeadPosition
				local n, a = shapeLines['count'], shapeLines['angle']
				local c = shapeLines['color']
				for i = 1, n do
					local p = self._shapeHeadPosition + diff:rotated((i - ((n - 1) * 0.5 + 1)) * a)
					line(
						self._shapeHeadPosition.x, self._shapeHeadPosition.y,
						p.x, p.y,
						c
					)
				end
			end
		end

		if DEBUG then
			if self._collider.__name == 'Recti' then
				rect(
					self._collider:xMin(), self._collider:yMin(),
					self._collider:xMax(), self._collider:yMax(),
					false,
					self._color
				)
			elseif self._collider.__name == 'Vec3' then
				circ(
					self._collider.x, self._collider.y,
					self._collider.z,
					false,
					self._color
				)
			end
		end
	end,

	_build = function (self, dstX, dstY, dstW, dstH)
		local dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
			self._spriteWidth, self._spriteHeight
		self._collider = Recti.new(
			dstX + self.box:xMin(), dstY + self.box:yMin(),
			dstX + self.box:xMax(), dstY + self.box:yMax()
		)

		return dstX, dstY, dstW, dstH
	end,

	_raycast = function (self, pos, dir)
		local pos, idx = self._raycaster:solve(pos, dir, self._isBlocked)

		return pos, idx
	end,

	_move = function (self, step)
		local newDir = self._walker:solve(
			Vec2.new(self.x, self.y), step,
			self._isBlocked,
			self._slidable
		)

		return newDir
	end
}, Event)
