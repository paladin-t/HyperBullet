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
	_shocking = nil,

	--[[ Constructor. ]]

	ctor = function (self, isBlocked, options)
		Weapon.ctor(self, isBlocked, options)

		local cfg = Weapons[options.type]
		self._bullet = options.type

		self._recoil = cfg['recoil']
		self._capacity = cfg['capacity']
		self._shocking = cfg['shocking']

		if cfg['dual'] and not options.secondary then
			self._secondary = Gun.new(isBlocked, merge(options, { secondary = true }))
				:setIsSecondary(true)
			self._secondary
				:play('picked')
		end
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Gun'
	end,

	--[[ Methods. ]]

	interval = function (self)
		return self._interval,
			0, self._interval, 0
	end,

	capacity = function (self)
		return self._capacity
	end,
	setCapacity = function (self, capacity)
		self._capacity = capacity

		return self
	end,

	-- Emits bullet.
	-- returns success, emitted bullet, out of bullet, recoil.
	attack = function (self, dir, consumption, accuracy, shock)
		-- Check for cooldown interval.
		local now = DateTime.ticks()
		if self._timestamp ~= nil then
			local diff = now - self._timestamp
			diff = DateTime.toSeconds(diff)
			if diff < self._interval then
				return false, nil, false, nil
			end
		end
		self._timestamp = now

		-- Check for capacity.
		if self._capacity ~= nil then
			if self._capacity > 0 then
				if consumption ~= nil then
					self._capacity = self._capacity - consumption
				end
			elseif self._capacity == 0 then
				return false, nil, true, nil
			end
		end

		-- Check for obstacle.
		local owner = self._owner
		local ownerPos = Vec2.new(owner.x, owner.y)
		local emitPos = self._facing * self._offset * 1.5
		local hit, _ = owner:raycast(ownerPos, emitPos)
		if hit ~= nil then
			return true, nil, false, self._recoil
		end

		-- Emit.
		local pos = ownerPos + emitPos
		if accuracy ~= nil then
			local deviation = math.pi * 0.3
			local tmp = dir or self._facing
			tmp = tmp:rotated(deviation * ((math.random() - 0.5) * accuracy))
			dir = tmp
		end
		local bullet = self._game.pool:bullet(
			self._bullet,
			pos.x, pos.y, dir,
			owner.group,
			self._game,
			owner._isBulletBlocked
		)
		table.insert(owner._game.pending, bullet)
		if Bullets[self._bullet]['shell_case'] ~= nil then
			local shellCase = self._game.pool:shellCase(
				self._bullet,
				pos.x - dir.x * 8, pos.y - dir.y * 8,
				self._game
			)
			table.insert(owner._game.backgroundEffects, shellCase)
		end

		-- Add effect.
		if self._effect ~= nil then
			local x, y =
				self.x + self._facing.x * 8, self.y + self._facing.y * 8
			local fx, interval = self._effect(self, x, y, self._facing, self._spriteAngle)
			if fx ~= nil then
				self:_emit(fx, interval)
			end
		end

		-- Shock the camera.
		if shock and self._shocking ~= nil then
			local interval, amplitude = self._shocking['interval'], self._shocking['amplitude']
			self._game.camera:shock(interval, amplitude)
		end

		-- Play SFX.
		self._game:playSfx(self:sfxs()['attack'])

		-- Finish.
		return true, bullet, false, self._recoil
	end,

	update = function (self, delta)
		Weapon.update(self, delta)
	end
}, Weapon)
