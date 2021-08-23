--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Bullet = class({
	--[[ Variables. ]]

	group = 'bullet',

	_ownerGroup = nil,

	_box = nil, _maxBox = nil,
	_direction = nil,
	_moveSpeed = 0,
	_lifetime = 1, _ticks = 0,
	_penetrable = false,

	--[[ Constructor. ]]

	ctor = function (self, resource, isBlocked, options)
		Object.ctor(self, resource, options.box, isBlocked)

		self._color = Color.new(255, 0, 0)

		if options.atk then
			self.atk = options.atk
		end

		self._box, self._maxBox = options.box, options.maxBox
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

	revive = function (self)
		Object.revive(self)
		self._ticks = 0

		return self
	end,

	ownerGroup = function (self)
		return self._ownerGroup
	end,
	setOwnerGroup = function (self, ownerGroup)
		self._ownerGroup = ownerGroup

		return self
	end,

	direction = function (self)
		return self._direction
	end,
	setDirection = function (self, dir)
		self._direction = dir

		return self
	end,

	penetrable = function (self)
		return self._penetrable
	end,

	behave = function (self, delta, _1)
		self._ticks = self._ticks + delta
		if self._ticks >= self._lifetime then
			self:kill('disappeared')

			return self
		end
		if self._maxBox ~= nil then
			local factor = self._ticks / self._lifetime
			self.box = Recti.byXYWH(
				lerp(self._box:xMin(), self._maxBox:xMin(), factor),
				lerp(self._box:yMin(), self._maxBox:yMin(), factor),
				lerp(self._box:width(), self._maxBox:width(), factor),
				lerp(self._box:height(), self._maxBox:height(), factor)
			)
		end

		return self
	end,

	update = function (self, delta)
		local step = self._direction * delta * self._moveSpeed
		local forward = self:_move(step)
		if (step.x ~= 0 and forward.x == 0) or (step.y ~= 0 and forward.y == 0) then -- Intersects with tile.
			self:kill('disappeared')
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
