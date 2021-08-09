--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'object'

Gun = class({
	--[[ Variables. ]]

	group = 'weapon',

	_owner = nil,

	_name = nil,
	_bullet = nil,

	_interval = 0.25, _timestamp = nil,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, options)
		Object.ctor(self, sprite, box)

		local cfg = Guns[options.type]
		self._name = cfg['name']
		self._bullet = Bullets[options.type]
		self._interval = cfg['interval']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Gun'
	end,

	--[[ Methods. ]]

	owner = function (self)
		return self._owner
	end,
	setOwner = function (self, owner)
		self._owner = owner
		self._timestamp = nil

		return self
	end,

	name = function (self)
		return self._name
	end,

	emit = function (self, dir)
		local now = DateTime.ticks()
		if self._timestamp ~= nil then
			local diff = now - self._timestamp
			diff = DateTime.toSeconds(diff)
			if diff < self._interval then
				return self
			end
		end
		self._timestamp = now

		local owner = self._owner
		local bullet = Bullet.new(
			self._bullet['resource'],
			owner._isBlocked,
			{
				co = owner._co,
				context = owner._context,
				direction = dir or self._facing,
				atk = self._bullet['atk'],
				box = self._bullet['box'],
				moveSpeed = self._bullet['move_speed'],
				lifetime = self._bullet['lifetime']
			}
		)
		bullet.x, bullet.y = self.x, self.y
		bullet:setOwner(self)
		table.insert(owner._context.objects, bullet)

		return self
	end,

	behave = function (self, delta, _1)
		local owner = self._owner
		if owner then
			self.x, self.y = owner.x, owner.y
			self._facing = owner._facing
		end
	end,

	update = function (self, delta)
		Object.update(self, delta, true)

		font(NORMAL_FONT)
		local txt = self._name
		local textWidth, textHeight = measure(txt, NORMAL_FONT)
		text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
		text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, Color.new(200, 220, 210))
		font(nil)
	end
}, Object)
