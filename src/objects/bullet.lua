--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'object'

Bullet = class({
	--[[ Variables. ]]

	group = 'bullet',

	_ownerGroup = nil,

	_direction = nil,
	_moveSpeed = 0,
	_lifetime = 1,
	_ticks = 0,

	--[[ Constructor. ]]

	ctor = function (self, sprite, isBlocked, options)
		Object.ctor(self, sprite, options.box, isBlocked)

		self._color = Color.new(255, 0, 0)

		if options.atk then
			self.atk = options.atk
		end

		self._direction = options.direction
		self._moveSpeed = options.moveSpeed
		self._lifetime = options.lifetime or 1

		self._slidable = 0
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Bullet'
	end,

	--[[ Methods. ]]

	ownerGroup = function (self)
		return self._ownerGroup
	end,
	setOwnerGroup = function (self, ownerGroup)
		self._ownerGroup = ownerGroup

		return self
	end,

	behave = function (self, delta, _1)
		self._ticks = self._ticks + delta
		if self._ticks >= self._lifetime then
			self:kill()

			return self
		end

		return self
	end,

	update = function (self, delta)
		local step = self._direction * delta * self._moveSpeed
		local forward = self:_move(step.x, step.y)
		if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then -- Hits something.
			self:kill()
		else
			self.x = self.x + forward.x
			self.y = self.y + forward.y
		end

		Object.update(self, delta)
	end
}, Object)
