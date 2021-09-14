--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Environment = class({
	--[[ Variables. ]]

	group = 'environment',

	_game = nil,

	_weight = 1,
	_moveSpeed = 200,
	_moving = nil,
	_facing = nil,
	_rotating = 0,

	--[[ Constructor. ]]

	ctor = function (self, resources, box, isBlocked, options)
		Object.ctor(self, resources[1], box, isBlocked)

		self._game = options.game

		self._moveSpeed = options.moveSpeed
		self._moving = Vec2.new(0, 0)
		self._facing = Vec2.new(1, 0)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Environment'
	end,

	--[[ Methods. ]]

	behave = function (self, delta, _1)
		-- Interact with objects.
		local EPSILON = 1
		local repulseMovement, repulseRotation = Vec2.new(0, 0), 0
		for _, v in ipairs(self._game.objects) do
			if v.group == 'hero' then
				local m, r = self:_repulse(v)
				repulseMovement, repulseRotation =
					repulseMovement + m, repulseRotation + r
			elseif v.group == 'enemy' then
				local m, r = self:_repulse(v)
				repulseMovement, repulseRotation =
					repulseMovement + m, repulseRotation + r
			elseif v.group == 'environment' then
				if v ~= self then
					local m, r = self:_repulse(v)
					repulseMovement, repulseRotation =
						repulseMovement + m, repulseRotation + r
				end
			elseif v.group == 'weapon' then
				if v:throwing() then
					if self:intersects(v) then -- Environment intersects with a weapon which is being thrown.
						--v:throw(nil)

						-- Do nothing.
					end
				end
			elseif v.group == 'bullet' then
				if not v:dead() and not v:explosive() and self:intersects(v) then -- Environment intersects with bullet.
					--if not v:penetrable() then
					--	v:kill('killed', self)
					--end
					-- Do nothing.
				end
			end
		end
		local l = repulseMovement.length
		if l > EPSILON then
			self._moving = self._moving + repulseMovement
		end
		if repulseRotation ~= 0 then
			self._rotating = self._rotating + repulseRotation
		end

		-- Finish.
		return self
	end,
	update = function (self, delta)
		-- Process moving.
		local movementLength = self._moving.length
		if movementLength ~= 0 then
			local speed = delta * self._moveSpeed / self._weight
			if movementLength > speed then
				self._moving = self._moving * (speed / movementLength)
			end
			local m = self:_move(self._moving)
			if m.length == 0 then
				movementLength = 0
			end
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._moving = Vec2.new(0, 0)
		end

		-- Process rotating.
		local rotationAngle = self._rotating
		if rotationAngle ~= 0 then
			if movementLength ~= 0 then
				local speed = delta * 0.05 / self._weight
				if rotationAngle > speed then
					self._rotating = self._rotating * (speed / rotationAngle)
				end
				self:setAngle(self._spriteAngle + self._rotating)
			end
			self._rotating = 0
		end

		-- Draw shadow effect.
		self:shadow(delta, 3, 3) -- Draw shadow effect.

		-- Base update.
		Object.update(self, delta)
	end,

	_repulse = function (self, other)
		local EPSILON = 16
		local diff = Vec2.new(self.x, self.y) - Vec2.new(other.x, other.y)
		local l = diff:normalize()
		if l > EPSILON then
			return Vec2.new(0, 0), 0
		end
		local FORCE = 10
		local movement = diff * (1 - l / EPSILON) * FORCE
		local rotation = diff.angle

		return movement, rotation
	end
}, Object)
