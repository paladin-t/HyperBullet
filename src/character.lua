--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'object'

Character = class({
	--[[ Variables. ]]

	vacuum = nil,

	_co = nil,
	_context = nil,

	_weapon = nil,

	_weight = 1,
	_moveSpeed = 0,
	_moving = nil, _movingByRecoil = nil,
	_facing = nil,
	_picking = false, _throwing = false,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Object.ctor(self, sprite, box, isBlocked)

		self.vacuum = options.vacuum

		if options.hp then
			self.maxHp = options.hp
			self.hp = options.hp
		end
		if options.atk then
			self.atk = options.atk
		end

		self._co = options.co
		self._context = options.context

		self._moveSpeed = options.moveSpeed
		self._moving = Vec2.new(0, 0)
		self._facing = Vec2.new(1, 0)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Character'
	end,

	--[[ Methods. ]]

	intersects = function (self, other)
		local inter = Math.intersects(self._aabb, other._aabb)

		return inter
	end,
	intersectsWithShape = function (self, shape)
		return Math.intersects(self._aabb, shape)
	end,

	weapon = function (self)
		return self._weapon
	end,
	setWeapon = function (self, weapon)
		if self._weapon ~= nil then
			self._weapon:setOwner(nil)
		end
		if weapon ~= nil then
			weapon
				:setOwner(self)
				:setOwnerGroup(self.group)
		end
		self._weapon = weapon

		return self
	end,

	weight = function (self)
		return self._weight
	end,
	setWeight = function (self, weight)
		self._weight = weight

		return self
	end,

	moveLeft = function (self, delta)
		self._moving.x = -delta * self._moveSpeed / self._weight

		return self
	end,
	moveRight = function (self, delta)
		self._moving.x = delta * self._moveSpeed / self._weight

		return self
	end,
	moveUp = function (self, delta)
		self._moving.y = -delta * self._moveSpeed / self._weight

		return self
	end,
	moveDown = function (self, delta)
		self._moving.y = delta * self._moveSpeed / self._weight

		return self
	end,
	lookAt = function (self, x, y)
		if isNaN(x) --[[ or isNaN(y) ]] then
			return self
		end

		self._facing = Vec2.new(x - self.x, y - self.y).normalized
		self._spriteAngle = self._facing.angle

		return self
	end,
	pick = function (self)
		self._picking = true

		return self
	end,
	throw = function (self)
		self._throwing = true

		return self
	end,
	attack = function (self, consumption)
		local weapon = self:weapon()
		if weapon == nil then
			return self
		end
		local success, empty, recoil = weapon:attack(self._facing, consumption)
		if success then
			if recoil ~= nil and recoil > 0 then
				self._movingByRecoil = -self._facing * (self._moveSpeed / self._weight * recoil)
			end
		end

		return self
	end,
	reset = function (self)
		return self
	end,

	behave = function (self, delta, _1)
		local weapon = self:weapon()
		if weapon ~= nil then
			weapon:behave()
		end

		return self
	end,

	update = function (self, delta)
		if self._movingByRecoil ~= nil then
			local m = self:_move(self._movingByRecoil.x, self._movingByRecoil.y)
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._movingByRecoil = nil
		end
		local l = self._moving.length
		if l ~= 0 then
			local speed = delta * self._moveSpeed / self._weight
			if l > speed then
				self._moving = self._moving * (speed / l)
			end
			local m = self:_move(self._moving.x, self._moving.y)
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._moving = Vec2.new(0, 0)
		end

		Object.update(self, delta)

		local weapon = self:weapon()
		if weapon ~= nil then
			weapon:update(delta)
		end
	end
}, Object)
