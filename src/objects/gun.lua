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

	_recoil = nil,
	_capacity = nil,
	_interval = 0.25, _timestamp = nil,
	_throwing = nil,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Object.ctor(self, sprite, box, isBlocked)

		local cfg = Weapons[options.type]
		self._name = cfg['name']
		self._bullet = Bullets[options.type]

		self._recoil = cfg['recoil']
		self._capacity = cfg['capacity']
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
		self._throwing = nil

		return self
	end,

	name = function (self)
		return self._name
	end,

	capacity = function (self)
		return self._capacity
	end,

	throwing = function (self)
		return self._throwing
	end,
	throw = function (self, dir)
		self._throwing = dir

		return self
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
		bullet:setOwnerGroup(owner.group)
		table.insert(owner._context.objects, bullet)

		-- Finish.
		return true, false, self._recoil
	end,

	behave = function (self, delta, _1)
		local owner = self._owner
		if owner then
			self.x, self.y = owner.x, owner.y
			self._facing = owner._facing
		end

		return self
	end,

	update = function (self, delta)
		if self._throwing ~= nil then
			local step = self._throwing * delta * 150
			local forward = self:_move(step.x, step.y)
			if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then -- Hits something.
				self._throwing = nil
			else
				self.x = self.x + forward.x
				self.y = self.y + forward.y
			end
		end

		Object.update(self, delta)

		font(NORMAL_FONT)
		local txt = self._name
		local textWidth, textHeight = measure(txt, NORMAL_FONT)
		text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
		text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, Color.new(200, 220, 210))
		font(nil)
	end
}, Object)
