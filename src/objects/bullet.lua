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
	_penetrable = false,

	--[[ Constructor. ]]

	ctor = function (self, resource, isBlocked, options)
		Object.ctor(self, resource, options.box, isBlocked)

		self._color = Color.new(255, 0, 0)

		if options.atk then
			self.atk = options.atk
		end

		self._direction = options.direction
		self._moveSpeed = options.moveSpeed
		self._lifetime = options.lifetime or 1
		self._penetrable = options.penetrable

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

	penetrable = function (self)
		return self._penetrable
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
		if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then -- Intersects with tile.
			self:kill()
		else
			self.x = self.x + forward.x
			self.y = self.y + forward.y
		end

		Object.update(self, delta)
	end,

	_build = function (self, dstX, dstY, dstW, dstH)
		local dstX, dstY, dstW, dstH = nil, nil, nil, nil
		local sprite, shapeLine, shapeLines =
			self._sprite, self._shapeLine, self._shapeLines
		if sprite ~= nil then
			dstX, dstY, dstW, dstH =
				self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
				self._spriteWidth, self._spriteHeight
		elseif shapeLine ~= nil then
			dstX, dstY, dstW, dstH =
				self.x, self.y,
				self._spriteWidth, self._spriteHeight
		elseif shapeLines ~= nil then
			dstX, dstY, dstW, dstH =
				self.x, self.y,
				self._spriteWidth, self._spriteHeight
		end
		self._collider = Vec3.new(
			dstX + dstW * 0.5, dstY + dstH * 0.5,
			self.box:width() * 0.5
		)

		return dstX, dstY, dstW, dstH
	end
}, Object)
