--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Character = class({
	--[[ Variables. ]]

	_game = nil,

	_weapon = nil, _armour = nil,

	_weight = 1,
	_moveSpeed = 0,
	_moving = nil, _movingByRecoil = nil,
	_facing = nil,
	_picking = false, _throwing = false,

	_spriteLegs = nil,
	_spriteLegsWidth = 0, _spriteLegsHeight = 0,
	_spriteDead = nil,
	_spriteSplitted1 = nil, _spriteSplitted2 = nil,

	_isBulletBlocked = nil,

	--[[ Constructor. ]]

	ctor = function (self, resources, box, isBlocked, isBulletBlocked, options)
		Object.ctor(self, resources[1], box, isBlocked)

		if options.hp then
			self.maxHp = options.hp
			self.hp = options.hp
		end
		if options.atk then
			self.atk = options.atk
		end

		self._spriteAngle = math.pi * 0.5
		self._spriteLegs = resources[2]
		self._spriteLegs:play('walk', false)
		self._spriteLegsWidth, self._spriteLegsHeight =
			self._spriteLegs.width, self._spriteLegs.height
		self._spriteDead = resources[3]
		self._spriteSplitted1, self._spriteSplitted2 = resources[4], resources[5]

		self._game = options.game

		self._moveSpeed = options.moveSpeed
		self._moving = Vec2.new(0, 0)
		self._facing = Vec2.new(1, 0)

		self._raycaster = self._game.raycaster
		self._pathfinder = self._game.pathfinder
		self._isBulletBlocked = isBulletBlocked
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Character'
	end,

	--[[ Methods. ]]

	hurt = function (self, other)
		local invincible, _ = self:invincible()
		if invincible then
			return false
		end
		self:setInvincible(1.5)

		local armour = self:armour()
		if armour ~= nil then
			armour.hp = math.max(armour.hp - other.atk, 0)
			if armour.hp == 0 then
				self:setArmour(nil)
				armour.x, armour.y = self.x, self.y
				armour:revive()
				table.insert(self._game.pending, armour)
			end

			return false
		end

		return Object.hurt(self, other)
	end,
	corpse = function (self, splitted)
		if splitted then
			return self._spriteSplitted1, self._spriteSplitted2
		else
			return self._spriteDead
		end
	end,

	intersects = function (self, other)
		return Math.intersects(self._collider, other._collider)
	end,
	intersectsWithShape = function (self, shape)
		return Math.intersects(self._collider, shape)
	end,

	weapon = function (self)
		return self._weapon
	end,
	setWeapon = function (self, weapon)
		if self._weapon ~= nil then
			self._weapon
				:setOwner(nil)
				:float(2)
				:play('idle')
			self:play('idle')
		end
		if weapon ~= nil then
			weapon
				:setOwner(self)
				:setOwnerGroup(self.group)
				:reset()
				:play('picked')
			weapon.xOffset, weapon.yOffset = nil, nil
			if weapon:secondary() == nil then
				self:play('picked')
			else
				self:play('picked_dual')
			end
		end
		self._weapon = weapon

		return self
	end,
	armour = function (self)
		return self._armour
	end,
	setArmour = function (self, armour)
		if self._armour ~= nil then
			self._armour
				:setOwner(nil)
				:float(2)
		end
		if armour ~= nil then
			armour
				:setOwner(self)
		end
		self._armour = armour

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
	facing = function (self)
		return self._facing
	end,
	lookAt = function (self, x, y)
		if isNaN(x) --[[ or isNaN(y) ]] then
			return self
		end

		if x == self.x and y == self.y then
			y = y + 1
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
	attack = function (self, consumption, accuracy, shock)
		local weapon = self:weapon()
		if weapon == nil then
			return nil
		end
		local success, bullet, empty, recoil = weapon:attack(self._facing, consumption, accuracy, shock)
		if success then
			if recoil ~= nil and recoil > 0 then
				self._movingByRecoil = -self._facing * (self._moveSpeed / self._weight * recoil)
			end

			local secondary = weapon:secondary()
			if secondary ~= nil then
				secondary:attack(-self._facing, nil, accuracy, false)
			end

			if weapon:isMelee() then
				local interval, _2, _3, _4 = weapon:interval()
				self:slash(interval)
			end
		end

		return bullet
	end,

	reset = function (self)
		return self
	end,

	behave = function (self, delta, hero)
		local weapon = self:weapon()
		if weapon ~= nil then
			weapon:behave(delta, hero)
			local secondary = weapon:secondary()
			if secondary ~= nil then
				secondary:behave(delta, hero)
			end
		end

		return self
	end,
	update = function (self, delta)
		-- Process moving.
		if self._movingByRecoil ~= nil then
			local m = self:_move(self._movingByRecoil) -- By recoil.
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._movingByRecoil = nil
		end
		local movementLength = self._moving.length
		if movementLength ~= 0 then
			local speed = delta * self._moveSpeed / self._weight
			if movementLength > speed then
				self._moving = self._moving * (speed / movementLength)
			end
			local m = self:_move(self._moving) -- By behaviour.
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._moving = Vec2.new(0, 0)
		end

		-- Update weapon and calculate priority.
		local weapon = self:weapon()
		local secondary = nil
		local before, after = false, false
		if weapon ~= nil then
			secondary = weapon:secondary()
			if weapon:isMelee() then
				before = true
			else
				after = true
			end
			weapon:follow(delta)
			if secondary ~= nil then
				secondary:follow(delta)
			end
		end

		-- Update and draw legs.
		local _, invincibleCol = self:invincible()
		local spriteLegs = self._spriteLegs
		if spriteLegs ~= nil then
			if movementLength ~= 0 then
				local dstX, dstY, dstW, dstH =
					self.x - self._spriteLegsWidth * 0.5, self.y - self._spriteLegsHeight * 0.5,
					self._spriteLegsWidth, self._spriteLegsHeight
				local angle = self._spriteAngle + math.pi * 0.5
				if secondary ~= nil then
					angle = angle + math.pi * 0.5
				end
				if invincibleCol == nil then
					spr( -- Draw shadow effect.
						spriteLegs,
						dstX + 3, dstY + 3, dstW, dstH,
						angle, nil,
						COLOR_SHADOW
					)
					spr(
						spriteLegs,
						dstX, dstY, dstW, dstH,
						angle
					)
				else
					spr(
						spriteLegs,
						dstX, dstY, dstW, dstH,
						angle, nil,
						invincibleCol
					)
				end
			end
		end

		-- Update and draw this character and weapon.
		if invincibleCol == nil then
			if weapon ~= nil then
				weapon:shadow(delta, 3, 3) -- Draw shadow effect.
			end
			self:shadow(delta, 3, 3) -- Draw shadow effect.
		end

		if before then
			weapon:update(delta)
		end
		if secondary ~= nil and before then
			secondary:update(delta)
		end

		Object.update(self, delta)

		if after then
			weapon:update(delta)
		end
		if secondary ~= nil and after then
			secondary:update(delta)
		end
	end,

	_repulse = function (self, other)
		local EPSILON = 16
		local diff = Vec2.new(self.x, self.y) - Vec2.new(other.x, other.y)
		local l = diff:normalize()
		if l > EPSILON then
			return Vec2.new(0, 0)
		end
		local FORCE = 10

		return diff * (1 - l / EPSILON) * FORCE
	end
}, Object)
