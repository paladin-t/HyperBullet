--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
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
		self._bullet = Bullets[options.type]

		self._recoil = cfg['recoil']
		self._capacity = cfg['capacity']
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
		local bullet = Bullet.new(
			self._bullet['resource'],
			owner._isBlocked,
			{
				game = owner._game,
				direction = dir or self._facing,
				atk = self._bullet['atk'],
				box = self._bullet['box'], maxBox = self._bullet['max_box'],
				moveSpeed = self._bullet['move_speed'],
				lifetime = self._bullet['lifetime'],
				penetrable = self._bullet['penetrable']
			}
		)
		local pos = Vec2.new(owner.x, owner.y) + self._facing * self._offset * 1.5
		bullet.x, bullet.y =
			pos.x, pos.y
		bullet:setOwnerGroup(owner.group)
		table.insert(owner._game.pending, bullet)

		-- Finish.
		return true, false, self._recoil
	end,

	update = function (self, delta)
		Weapon.update(self, delta)
	end
}, Weapon)
