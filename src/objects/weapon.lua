--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Weapon = class({
	--[[ Variables. ]]

	type = nil,
	group = 'weapon',

	icon = nil,
	cursor = nil,

	_game = nil,
	_owner = nil, _ownerGroup = nil,
	_name = nil, _acronym = nil,

	_accuracy = nil,
	_facing = nil,
	_interval = 0.25, _timestamp = nil,
	_throwing = nil, _throwingSpeed = 550, _throwingInterval = nil, _throwingTicks = 0,
	_offset = 0,
	_secondary = nil, _isSecondary = false,
	_ownerChanged = false,
	_effect = nil,
	_sfxs = nil,

	--[[ Constructor. ]]

	ctor = function (self, isBlocked, options)
		local cfg = Weapons[options.type]
		local resource = Resources.load(cfg['entry'])
		local box = cfg['box']
		self.type = options.type
		self.icon = Resources.load(cfg['entry'])
		self.icon:play('idle', true, true, true)
		self.cursor = cfg['cursor']
		self.cursor:play('idle', true, true, true)

		Object.ctor(self, resource, box, isBlocked)

		self.atk = cfg['atk']

		self._game = options.game
		self._name, self._acronym = cfg['name'], cfg['acronym']

		self._accuracy = cfg['accuracy']
		self._facing = Vec2.new(1, 0)
		self._interval = cfg['interval']
		self._throwingSpeed, self._throwingInterval, self._throwingTicks =
			cfg['throwing_speed'], cfg['throwing_interval'], 0
		self._offset = cfg['offset']
		self._effect = cfg['effect']
		self._sfxs = cfg['sfxs']
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
		self._disappearing, self._disappearingTicks = nil, 0
		self._spriteAngle = 0
		self._ownerChanged = true

		if owner ~= nil then
			self:trigger('picked', owner)
		end

		if self._secondary ~= nil then
			self._secondary:setOwner(owner)
		end

		return self
	end,
	ownerGroup = function (self)
		return self._ownerGroup
	end,
	setOwnerGroup = function (self, ownerGroup)
		self._ownerGroup = ownerGroup

		if self._secondary ~= nil then
			self._secondary:setOwnerGroup(ownerGroup)
		end

		return self
	end,

	name = function (self)
		return self._name
	end,
	acronym = function (self)
		return self._acronym
	end,

	isMelee = function (self)
		return false
	end,
	isBlade = function (self)
		return false
	end,

	interval = function (self)
		error('Implement me.')
	end,
	affecting = function (self)
		return false, nil
	end,

	accuracy = function (self)
		return self._accuracy
	end,

	capacity = function (self)
		return nil
	end,
	setCapacity = function (self, capacity)
		return self
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

	secondary = function (self)
		return self._secondary
	end,
	isSecondary = function (self)
		return self._isSecondary
	end,
	setIsSecondary = function (self, isSecondary)
		self._isSecondary = isSecondary

		return self
	end,

	sfxs = function (self)
		return self._sfxs
	end,

	attack = function (self, dir, consumption, accuracy, shock)
		error('Implement me.')
	end,

	follow = function (self, delta)
		local owner = self._owner
		if owner then
			if self._isSecondary then
				self._facing = -owner._facing
			else
				self._facing = owner._facing
			end
			local facing = self._facing
			if owner.angleOffset ~= nil then
				facing = facing:rotated(owner.angleOffset)
			end
			self._spriteAngle = facing.angle
			local pos = Vec2.new(owner.x, owner.y) + facing * self._offset
			self.x, self.y = pos.x, pos.y
		end

		return self
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		-- Process throwing.
		if self._throwing ~= nil and not self._isSecondary then
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

		-- Process effect.
		if self._emitters ~= nil then
			for _, entry in ipairs(self._emitters) do
				local emitter = entry.emitter
				local x, y =
					self.x + self._facing.x * 8, self.y + self._facing.y * 8
				emitter.pos.x, emitter.pos.y = x, y
			end
		end

		-- Draw shadow effect.
		local owner = self._owner
		if owner == nil then
			self:shadow(delta, 3, 3) -- Draw shadow effect.
		end

		-- Base update.
		Object.update(self, delta)

		-- Draw information text.
		if not self._isSecondary then
			if not owner and not self._throwing then
				if self._ownerChanged and self._acronym ~= nil then
					if self:isMelee() then
						self._game:acronymMeleeBackground(self.x, self.y - 20)
					else
						self._game:acronymGunBackground(self.x, self.y - 20)
					end
					font(FONT_NORMAL_TEXT)
					local txt = self._acronym
					local textWidth, textHeight = measure(txt, FONT_NORMAL_TEXT)
					text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
					text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, COLOR_CLEAR_TEXT)
					font(nil)
				elseif self._game.state.playing then
					font(FONT_NORMAL_TEXT)
					local txt = self._name
					local textWidth, textHeight = measure(txt, FONT_NORMAL_TEXT)
					text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
					text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, COLOR_CLEAR_TEXT)
					font(nil)
				end
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
