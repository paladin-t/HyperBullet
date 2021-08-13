--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'object'

Melee = class({
	--[[ Variables. ]]

	group = 'weapon',

	_owner = nil,

	_name = nil,

	_interval = 0.15, _timestamp = nil,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, options)
		Object.ctor(self, sprite, box)

		local cfg = Weapons[options.type]
		self._name = cfg['name']
		self._interval = cfg['interval']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Melee'
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
				return nil
			end
		end
		self._timestamp = now

		-- TODO

		return self._recoil
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
