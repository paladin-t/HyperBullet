--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'character'

Bullet = class({
	--[[ Variables. ]]

	group = 'bullet',

	_owner = nil,

	_direction = nil,

	_lifetime = 1,
	_ticks = 0,

	--[[ Constructor. ]]

	ctor = function (self, sprite, isBlocked, options)
		Character.ctor(
			self,
			sprite, options.box,
			isBlocked,
			options
		)

		self._direction = options.direction

		self._lifetime = options.lifetime or 1

		self._slidable = 0
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Bullet'
	end,

	--[[ Methods. ]]

	owner = function (self)
		return self._owner
	end,
	setOwner = function (self, owner)
		self._owner = owner

		return self
	end,

	behave = function (self, delta, _1)
		self._ticks = self._ticks + delta
		if self._ticks >= self._lifetime then
			self:kill()

			return
		end

		local step = self._direction * delta * self._moveSpeed
		local forward = self:_move(step.x, step.y)
		if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then
			self:kill()
		else
			self._moving.x = self._moving.x + forward.x
			self._moving.y = self._moving.y + forward.y
		end
	end
}, Character)