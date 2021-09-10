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
	xOffset = nil, yOffset = nil,
	angleOffset = nil,
	box = nil,

	_dead = false,
	_invincible = nil, _invincibleColor = nil,
	_disappearable = true, _disappearing = nil, _disappearingTicks = 0,
	_collider = nil,

	_sprite = nil,
	_spriteWidth = 0, _spriteHeight = 0,
	_spriteAngle = 0,
	_spriteUpdater = nil,
	_shapeSprites = nil,
	_shapeLine = nil,
	_shapeLines = nil,
	_shapeHeadPosition = nil,
	_color = Color.new(0, 255, 0),
	_emitters = nil,
	_tweens = nil,

	_walker = nil,
	_raycaster = nil,
	_pathfinder = nil,
	_isBlocked = nil,
	_slidable = 5,

	--[[ Constructor. ]]

	ctor = function (self, resource, box, isBlocked)
		self.box = box

		if resource ~= nil then
			if resource.__name == 'Sprite' then
				self._sprite = resource
				self._sprite:play('idle', false)
				self._spriteWidth, self._spriteHeight =
					self._sprite.width, self._sprite.height
			elseif resource['type'] == 'sprite' then
				self._sprite = resource['resource']
				self._sprite:play('idle', false)
				self._spriteWidth, self._spriteHeight =
					self._sprite.width, self._sprite.height
			elseif resource['type'] == 'sprites' then
				self._shapeSprites = resource
				local sprite = self._shapeSprites['resource']
				sprite:play('idle', false)
				self._spriteWidth, self._spriteHeight =
					sprite.width, sprite.height
			elseif resource['type'] == 'line' then
				self._shapeLine = resource
			elseif resource['type'] == 'lines' then
				self._shapeLines = resource
			end
		end

		if isBlocked ~= nil then
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
			self:kill('killed', other)
		end

		return true
	end,
	dead = function (self)
		return self._dead
	end,
	kill = function (self, reason, byWhom)
		self._dead = true

		self:trigger('dead', reason, byWhom)

		return self
	end,
	revive = function (self)
		self._dead = false
		self._disappearing, self._disappearingTicks = nil, 0
		self._shapeHeadPosition = nil

		return self
	end,
	invincible = function (self)
		return self._invincible, self._invincibleColor
	end,
	setInvincible = function (self, invincible)
		self._invincible = invincible

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
	angle = function (self)
		return self._spriteAngle
	end,
	setAngle = function (self, angle)
		self._spriteAngle = angle

		return self
	end,

	tween = function (self, t)
		if self._tweens == nil then
			self._tweens = { }
		end
		table.insert(self._tweens, t)

		return self
	end,
	float = function (self, interval, val)
		local up, down = nil, nil
		up = Tween.new(interval * 0.5, { y = 0 }, { y = val or -4 }, Tween.easing.linear)
			:on('changed', function (sender, val)
				self.yOffset = val.y
			end)
			:on('completed', function (sender, val)
				remove(self._tweens, up)
				down:reset()
				self:tween(down)
			end)
		down = Tween.new(interval * 0.5, { y = val or -4 }, { y = 0 }, Tween.easing.linear)
			:on('changed', function (sender, val)
				self.yOffset = val.y
			end)
			:on('completed', function (sender, val)
				remove(self._tweens, down)
				up:reset()
				self:tween(up)
			end)
		self:tween(up)

		return self
	end,
	slash = function (self, interval, val)
		local left, right, middle = nil, nil, nil
		left = Tween.new(interval * 0.2, { angle = 0 }, { angle = -(val or math.pi * 0.25) }, Tween.easing.linear)
			:on('changed', function (sender, val)
				self.angleOffset = val.angle
			end)
			:on('completed', function (sender, val)
				remove(self._tweens, left)
				self:tween(right)
			end)
		right = Tween.new(interval * 0.6, { angle = -(val or math.pi * 0.25) }, { angle = val or math.pi * 0.25 }, Tween.easing.linear)
			:on('changed', function (sender, val)
				self.angleOffset = val.angle
			end)
			:on('completed', function (sender, val)
				remove(self._tweens, right)
				self:tween(middle)
			end)
		middle = Tween.new(interval * 0.2, { angle = val or math.pi * 0.25 }, { angle = 0 }, Tween.easing.linear)
			:on('changed', function (sender, val)
				self.angleOffset = val.angle
			end)
			:on('completed', function (sender, val)
				remove(self._tweens, middle)
			end)
		self:tween(left)

		return self
	end,
	bounce = function (self, interval, val)
		local x, y =
			self.x + (val or 10) * (math.random() * 2 - 1),
			self.y + (val or 10) * (math.random() * 0.2 + 1)
		self:tween(
			Tween.new(interval, { x = self.x, y = self.y }, { x = x, y = y }, Tween.easing.outBounce)
				:on('changed', function (sender, val)
					self.x, self.y = val.x, val.y
				end)
		)

		return self
	end,

	raycast = function (self, pos, dir, isBlocked)
		return self._raycaster:solve(pos, dir, isBlocked or self._isBlocked)
	end,
	findpath = function (self, pos, dst)
		return self._pathfinder:solve(pos, dst)
	end,

	reset = function (self)
		self._tweens = nil

		return self
	end,

	behave = function (self, delta, hero)
		error('Implement me.')
	end,
	update = function (self, delta)
		-- Update the tweenings.
		self:_tween(delta)

		-- Call custom sprite update handler if it's set.
		if self._spriteUpdater then
			self._spriteUpdater(delta)
		end

		-- Calculate basic information.
		local sprite, shapeSprites, shapeLine, shapeLines =
			self._sprite, self._shapeSprites, self._shapeLine, self._shapeLines
		local emitters = self._emitters
		local dstX, dstY, dstW, dstH = self:_build()
		if self.xOffset ~= nil then
			dstX = dstX + self.xOffset
		end
		if self.yOffset ~= nil then
			dstY = dstY + self.yOffset
		end

		-- Calculate visibility.
		local visible = true
		if self._disappearing ~= nil then
			local INTERVAL = 0.3
			self._disappearingTicks = self._disappearingTicks + delta
			if self._disappearingTicks > INTERVAL then
				self._disappearingTicks = self._disappearingTicks - INTERVAL
				self._disappearing = self._disappearing - 1
				if self._disappearing <= 0 then
					self:kill('disappeared', nil)
					self._disappearing, self._disappearingTicks = nil, 0
				end
			end
			if self._disappearingTicks > INTERVAL * 0.5 then
				visible = false
			end
		end

		-- Draw if visible.
		if visible then
			if sprite ~= nil then
				if self._invincible ~= nil then
					if math.floor(self._invincible * 15) % 2 == 1 then
						self._invincibleColor = Color.new(255, 255, 255, 16)
					else
						self._invincibleColor = nil
					end
					self._invincible = self._invincible - delta
					if self._invincible <= 0 then
						self._invincible, self._invincibleColor = nil, nil
					end
				end
				local angle = self._spriteAngle
				if self.angleOffset ~= nil then
					angle = angle + self.angleOffset
				end
				if self._invincibleColor == nil then
					spr(
						sprite,
						dstX, dstY, dstW, dstH,
						angle
					)
				else
					spr(
						sprite,
						dstX, dstY, dstW, dstH,
						angle, nil,
						self._invincibleColor
					)
				end
			elseif shapeSprites ~= nil then
				if self._shapeHeadPosition == nil then
					self._shapeHeadPosition = Vec2.new(dstX, dstY)
				end
				local pos = Vec2.new(dstX, dstY)
				local diff = pos - self._shapeHeadPosition
				local n, angle = shapeSprites['count'], shapeSprites['angle']
				for i = 1, n do
					local p = self._shapeHeadPosition + diff:rotated((i - ((n - 1) * 0.5 + 1)) * angle)
					spr(
						shapeSprites['resource'],
						p.x, p.y, self._spriteWidth, self._spriteHeight,
						self._spriteAngle
					)
				end
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
				local n, angle = shapeLines['count'], shapeLines['angle']
				local c = shapeLines['color']
				for i = 1, n do
					local p = self._shapeHeadPosition + diff:rotated((i - ((n - 1) * 0.5 + 1)) * angle)
					line(
						self._shapeHeadPosition.x, self._shapeHeadPosition.y,
						p.x, p.y,
						c
					)
				end
			end
		end

		-- Process and draw emitters.
		if emitters ~= nil then
			local dead = nil
			for i, entry in ipairs(emitters) do
				local emitter = entry.emitter
				if emitter.refresh ~= nil then
					emitter:refresh(self, delta)
				end
				emitter:update(delta)
				emitter:draw()

				entry.interval = entry.interval - delta
				if entry.interval <= 0 then
					if dead == nil then
						dead = { }
					end
					table.insert(dead, 1, i)
				end
			end
			if dead ~= nil then
				for _, idx in ipairs(dead) do
					table.remove(emitters, idx)
				end
				if #emitters == 0 then
					emitters = nil
					self._emitters = nil
				end
			end
		end

		-- Draw debug information.
		if DEBUG_SHOW_WIREFRAME then
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

	shadow = function (self, delta, offsetX, offsetY)
		local dstX, dstY, dstW, dstH = self:_build()
		local angle = self._spriteAngle
		if self.angleOffset ~= nil then
			angle = angle + self.angleOffset
		end
		local sprite = self._sprite
		spr(
			sprite,
			dstX + (offsetX or 2), dstY + (offsetY or 2), dstW, dstH,
			angle, nil,
			COLOR_SHADOW
		)

		return self
	end,

	_build = function (self)
		local dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
			self._spriteWidth, self._spriteHeight
		self._collider = Recti.new(
			dstX + self.box:xMin(), dstY + self.box:yMin(),
			dstX + self.box:xMax(), dstY + self.box:yMax()
		)

		return dstX, dstY, dstW, dstH
	end,

	_move = function (self, step)
		local newDir = Vec2.new(0, 0)
		local stepLength = step:normalize()
		if stepLength > 0 then
			local singleStepLength = 8
			local pos = Vec2.new(self.x, self.y)
			while stepLength > 0 do -- Split into a few steps to avoid penetration.
				local step_ = step * math.min(stepLength, singleStepLength)
				local m = self._walker:solve(
					pos, step_,
					self._isBlocked,
					self._slidable
				)
				pos = pos + m
				newDir = newDir + m
				stepLength = stepLength - singleStepLength
			end
		else
			newDir = self._walker:solve(
				Vec2.new(self.x, self.y), step * stepLength,
				self._isBlocked,
				self._slidable
			)
		end

		return newDir
	end,

	_tween = function (self, delta)
		if self._tweens ~= nil then
			local dead = nil
			for _, t in ipairs(self._tweens) do
				if t:update(delta) then
					if dead == nil then
						dead = { }
					end
					table.insert(dead, t)
				end
			end
			if dead ~= nil then
				self._tweens = filter(self._tweens, function (t)
					return not exists(dead, t)
				end)
				if #self._tweens == 0 then
					self._tweens = nil
				end
			end
		end

		return self
	end,

	_emit = function (self, emitter, interval)
		if self._emitters == nil then
			self._emitters = { }
		end
		table.insert(
			self._emitters,
			{
				emitter = emitter,
				interval = interval
			}
		)

		return self
	end,
}, Event)
