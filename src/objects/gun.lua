--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Gun = class({
	--[[ Variables. ]]

	_bullet = nil,

	_recoil = nil,
	_capacity = nil,

	--[[ Constructor. ]]

	ctor = function (self, isBlocked, options)
		Weapon.ctor(self, isBlocked, options)

		local cfg = Weapons[options.type]
		self._bullet = options.type

		self._recoil = cfg['recoil']
		self._capacity = cfg['capacity']

		if cfg['dual'] and not options.shadow then
			self._shadow = Gun.new(isBlocked, merge(options, { shadow = true }))
				:setShadowed(true)
		end
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Gun'
	end,

	--[[ Methods. ]]

	capacity = function (self)
		return self._capacity
	end,

	-- Emits bullet.
	-- returns success, out of bullet, recoil.
	attack = function (self, dir, consumption)
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

		-- Check for capacity.
		if self._capacity ~= nil then
			if self._capacity > 0 then
				if consumption ~= nil then
					self._capacity = self._capacity - consumption
				end
			else
				return false, true, nil
			end
		end

		-- Emit.
		local owner = self._owner
		local pos = Vec2.new(owner.x, owner.y) + self._facing * self._offset * 1.5
		local bullet = self._game.pool:bullet(
			self._bullet,
			pos.x, pos.y, dir or self._facing,
			owner.group,
			game,
			owner._isBlocked
		)
		table.insert(owner._game.pending, bullet)

		-- Finish.
		return true, false, self._recoil
	end,

	update = function (self, delta)
		Weapon.update(self, delta)
	end
}, Weapon)
