--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'objects/weapon'

Melee = class({
	--[[ Variables. ]]

	_shape = nil, _affecting = false,
	_preInterval = 0.05, _postInterval = 0.05,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Weapon.ctor(self, sprite, box, isBlocked, options)

		self._color = Color.new(255, 0, 0)

		local cfg = Weapons[options.type]
		self._name = cfg['name']

		self._shape = cfg['shape']
		self._preInterval, self._postInterval = cfg['pre_interval'], cfg['post_interval']
		self._interval = cfg['interval']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Melee'
	end,

	--[[ Methods. ]]

	affecting = function (self)
		if not self._affecting then
			return false, nil
		end

		local shape = nil
		if self._shape['type'] == 'circle' then
			shape = Vec3.new(self.x, self.y - self.box:height() * 0.5, self._shape['r'])
		end

		return true, shape
	end,

	-- Attacks with this melee itself.
	-- returns success, out of bullet (always false), recoil.
	attack = function (self, dir, _)
		-- Check for cooldown interval.
		local now = DateTime.ticks()
		if self._timestamp ~= nil then
			local diff = now - self._timestamp
			diff = DateTime.toSeconds(diff)
			if diff < self._interval then
				return false, false, nil
			end
		end
		self._timestamp = now

		-- Finish.
		return true, false, nil
	end,

	behave = function (self, delta, hero)
		if self._timestamp ~= nil then
			local now = DateTime.ticks()
			local diff = now - self._timestamp
			diff = DateTime.toSeconds(diff)
			if diff < self._preInterval then
				self._affecting = false
			elseif diff < self._interval - self._postInterval then
				self._affecting = true
			elseif diff < self._interval then
				self._affecting = false
			else
				self._timestamp = nil
			end
		end

		Weapon.behave(self, delta, hero)

		return self
	end,

	update = function (self, delta)
		Weapon.update(self, delta)

		if DEBUG then
			if self._affecting then
				if self._shape['type'] == 'circle' then
					circ(
						self.x, self.y - self.box:height() * 0.5,
						self._shape['r'],
						false,
						self._color
					)
				end
			end
		end
	end
}, Weapon)
