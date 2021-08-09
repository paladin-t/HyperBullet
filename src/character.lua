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
	_bullets = nil,

	_moveSpeed = 0,
	_moving = nil,
	_facing = nil,

	_walker = nil,
	_isBlocked = nil,
	_slidable = 5,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Object.ctor(self, sprite, box)

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

		self._bullets = { }

		self._moveSpeed = options.moveSpeed
		self._moving = Vec2.new(0, 0)
		self._facing = Vec2.new(1, 0)

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
		return 'Character'
	end,

	--[[ Methods. ]]

	intersects = function (self, other)
		local inter = Math.intersects(self._aabb, other._aabb)

		return inter
	end,
	intersectsWithWeapon = function (self, other)
		local inter = Math.intersects(self._aabbAttack, other._aabb)

		return inter
	end,
	intersectsWithBullet = function (self, other)
		for _, v in ipairs(self._bullets) do
			if Math.intersects(v._aabb, other._aabb) then
				return true, v
			end
		end

		return false, nil
	end,

	weapon = function (self)
		return self._weapon
	end,
	setWeapon = function (self, weapon)
		self._weapon = weapon
		self._weapon:setOwner(self)

		return self
	end,

	moveLeft = function (self, delta)
		self._moving.x = -delta * self._moveSpeed

		return self
	end,
	moveRight = function (self, delta)
		self._moving.x = delta * self._moveSpeed

		return self
	end,
	moveUp = function (self, delta)
		self._moving.y = -delta * self._moveSpeed

		return self
	end,
	moveDown = function (self, delta)
		self._moving.y = delta * self._moveSpeed

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
	attack = function (self)
		if self._weapon == nil then
			return self
		end
		self._weapon:emit(self._facing)

		return self
	end,
	reset = function (self)
		self._bullets = { }
	end,

	behave = function (self, delta, _1)
		if self._weapon then
			self._weapon:behave()
		end

		if #self._bullets > 0 then
			for _, v in ipairs(self._bullets) do
				v:behave(delta, _1)
			end
			self._bullets = filter(self._bullets, function (obj) return obj.hp > 0 end)
		end
	end,

	update = function (self, delta)
		local l = self._moving.length
		if l ~= 0 then
			if l > delta * self._moveSpeed then
				self._moving = self._moving * (delta * self._moveSpeed / l)
			end
			local m = self:_move(self._moving.x, self._moving.y)
			self.x = self.x + m.x
			self.y = self.y + m.y
			self._moving = Vec2.new(0, 0)
		end

		Object.update(self, delta, true)

		for _, v in ipairs(self._bullets) do
			v:update(delta)
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
}, Object)
