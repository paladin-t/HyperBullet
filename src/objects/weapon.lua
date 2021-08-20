--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Weapon = class({
	--[[ Variables. ]]

	group = 'weapon',

	cursor = nil,

	_game = nil,
	_owner = nil, _ownerGroup = nil,
	_name = nil,

	_facing = nil,
	_interval = 0.25, _timestamp = nil,
	_throwing = nil, _throwingSpeed = 550, _throwingInterval = nil, _throwingTicks = 0,
	_offset = 0,

	--[[ Constructor. ]]

	ctor = function (self, isBlocked, options)
		local cfg = Weapons[options.type]
		local resource = Resources.load(cfg['entry'])
		local box = cfg['box']
		self.cursor = cfg['cursor']

		Object.ctor(self, resource, box, isBlocked)

		self.atk = cfg['atk']

		self._game = options.game
		self._name = cfg['name']

		self._facing = Vec2.new(1, 0)
		self._interval = cfg['interval']
		self._throwingSpeed, self._throwingInterval, self._throwingTicks =
			cfg['throwing_speed'], cfg['throwing_interval'], 0
		self._offset = cfg['offset']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Weapon'
	end,

	--[[ Methods. ]]

	owner = function (self)
		return self._owner
	end,
	setOwner = function (self, owner)
		self._owner = owner
		self._facing = Vec2.new(1, 0)
		self._timestamp = nil
		self._throwing = nil
		self._throwingTicks = 0
		self._spriteAngle = 0

		return self
	end,

	ownerGroup = function (self)
		return self._ownerGroup
	end,
	setOwnerGroup = function (self, ownerGroup)
		self._ownerGroup = ownerGroup

		return self
	end,

	name = function (self)
		return self._name
	end,

	throwing = function (self)
		return self._throwing
	end,
	throw = function (self, dir)
		self._throwing = dir
		if self._throwing ~= nil then
			self._spriteAngle = 0
			self._throwingTicks = 0
		end

		return self
	end,

	affecting = function (self)
		return false, nil
	end,

	capacity = function (self)
		return nil
	end,

	attack = function (self, dir, consumption)
		error('Implement me.')
	end,

	behave = function (self, delta, _1)
		local owner = self._owner
		if owner then
			self._facing = owner._facing
			self._spriteAngle = self._facing.angle
			local pos = Vec2.new(owner.x, owner.y) + self._facing * self._offset
			self.x, self.y = pos.x, pos.y
		end

		return self
	end,

	update = function (self, delta)
		if self._throwing ~= nil then
			local step = self._throwing * delta * self._throwingSpeed
			local forward = self:_move(step)
			if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then -- Intersects with tile.
				self._throwing = nil
			else
				self.x = self.x + forward.x
				self.y = self.y + forward.y
			end
			if self._throwingInterval ~= nil then
				self._throwingTicks = self._throwingTicks + delta
				if self._throwingTicks >= self._throwingInterval then
					self._throwing = nil
					self._throwingTicks = 0
				end
			end
		end

		Object.update(self, delta)

		if self._game.state.playing then
			if not self._owner and not self._throwing then
				font(NORMAL_FONT)
				local txt = self._name
				local textWidth, textHeight = measure(txt, NORMAL_FONT)
				text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
				text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, Color.new(200, 220, 210))
				font(nil)
			end
		end
	end,

	_build = function (self, dstX, dstY, dstW, dstH)
		local dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
			self._spriteWidth, self._spriteHeight
		self._collider = Vec3.new(
			dstX + dstW * 0.5, dstY + dstH * 0.5,
			self.box:width() * 0.5
		)

		return dstX, dstY, dstW, dstH
	end
}, Object)
