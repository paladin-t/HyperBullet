--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Mine = class({
	--[[ Variables. ]]

	group = 'mine',

	_game = nil,

	_box = nil,
	_lifetime = 1,
	_flashtime = 0.25,
	_ticks = 0, _timeout = false, _affected = false,
	_sfxs = nil,

	--[[ Constructor. ]]

	ctor = function (self, resource, isBlocked, options)
		Object.ctor(self, resource, options.box, isBlocked)

		self._color = Color.new(255, 0, 0)

		if options.atk then
			self.atk = options.atk
		end

		self._game = options.game

		self._box = options.box
		self._lifetime = options.lifetime or 1
		self._sfxs = options.sfxs
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Mine'
	end,

	--[[ Methods. ]]

	revive = function (self)
		error('Impossible.')
	end,
	disappear = function (self)
		error('Impossible.')
	end,

	behave = function (self, delta, _1)
		-- Interact with objects.
		if self._timeout and not self._affected then
			for _, v in ipairs(self._game.objects) do
				if not DEBUG_IMMORTAL and v.group == 'hero' then
					if v:intersects(self) then -- Hero intersects with mine.
						self._game:hurtWithMine(self, v)
					end
				elseif v.group == 'enemy' then
					if v:intersects(self) then -- Enemy intersects with mine.
						self._game:hurtWithMine(self, v)
					end
				elseif v.group == 'weapon' then
					-- Do nothing.
				elseif v.group == 'armour' then
					-- Do nothing.
				elseif v.group == 'bullet' then
					-- Do nothing.
				end
			end
			self._affected = true
		end

		-- Process ticking.
		if self._timeout then
			self._ticks = self._ticks + delta
			if self._ticks >= self._flashtime then
				self:kill('disappeared', nil)

				return self
			end
		else
			self._ticks = self._ticks + delta
			if self._ticks >= self._lifetime then
				self._timeout = true
				self._ticks = 0
				self._game.camera:shock(0.25, 5)

				self._game:playSfx(self._sfxs['explode'])
			end
		end

		-- Finish.
		return self
	end,
	update = function (self, delta)
		-- Draw shadow effect.
		local owner = self._owner
		if owner == nil then
			self:shadow(delta, 3, 3) -- Draw shadow effect.
		end

		-- Call custom sprite update handler if it's set.
		if self._spriteUpdater then
			self._spriteUpdater(delta)
		end

		-- Calculate basic information.
		local sprite = self._sprite
		local dstX, dstY, dstW, dstH = self:_build()

		-- Draw the mine object.
		if self._timeout then
			local a = (1 - self._ticks / self._flashtime) * 255
			local col = Color.new(255, 255, 255, a)
			circ(
				self._collider.x, self._collider.y,
				self._collider.z,
				true,
				col
			)
		else
			spr(
				sprite,
				dstX, dstY, dstW, dstH,
				self._spriteAngle
			)

			local a = (math.sin(self._ticks / self._lifetime * 10) + 1) * 0.5 * 255
			local col = Color.new(self._color.r, self._color.g, self._color.b, a)
			circ(
				self._collider.x, self._collider.y,
				self._collider.z,
				false,
				col
			)
		end
	end,

	_build = function (self, dstX, dstY, dstW, dstH)
		local dstX, dstY, dstW, dstH = nil, nil, nil, nil
		dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
			self._spriteWidth, self._spriteHeight
		self._collider = Vec3.new(
			dstX + dstW * 0.5, dstY + dstH * 0.5,
			self.box:width() * 5
		)

		return dstX, dstY, dstW, dstH
	end
}, Object)
