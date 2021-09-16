--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Hero = class({
	--[[ Variables. ]]

	group = 'hero',

	--[[ Constructor. ]]

	ctor = function (self, resources, box, isBlocked, isBulletBlocked, options)
		Character.ctor(self, resources, box, isBlocked, isBulletBlocked, options)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Hero'
	end,

	--[[ Methods. ]]

	behave = function (self, delta, _1)
		-- Prepare.
		Character.behave(self, delta, _1)

		-- Interact with objects.
		local EPSILON = 1
		local repulse = Vec2.new(0, 0)
		for _, v in ipairs(self._game.objects) do
			if v.group == 'enemy' then
				local weapon = self:weapon()
				if weapon ~= nil then
					local affecting, shape = weapon:affecting()
					if affecting then
						if v:intersectsWithShape(shape) then -- Enemy intersects with hero's melee.
							self._game:hurtWithWeapon(weapon, v)
						end
					end
				end
				repulse = repulse + self:_repulse(v)
			elseif v.group == 'weapon' then
				if v:throwing() then
					if v:ownerGroup() ~= 'hero' and self:intersects(v) then -- Hero intersects with a weapon which is being thrown.
						v:throw(nil)

						self._game:hurtWithWeapon(v, self)
					end
				elseif self._picking then
					if self:intersects(v) then -- Hero intersects with weapon for picking.
						if self._game:pickWeapon(self, v) then
							self._game.room.check(self, 'pick', v)
						end
					end
				end
			elseif v.group == 'armour' then
				if self._picking then
					if self:intersects(v) then -- Hero intersects with armour for picking.
						if self._game:pickArmour(self, v) then
							self._game.room.check(self, 'pick', v)
						end
					end
				end
			elseif v.group == 'bullet' then
				local ownerGroup = v:ownerGroup()
				if ownerGroup ~= 'hero' then
					if not DEBUG_IMMORTAL and not v:dead() and not v:explosive() and self:intersects(v) then -- Hero intersects with bullet.
						if not v:penetrable() then
							v:kill('killed', self)
						end
						self._game:hurtWithBullet(v, self)
					end
				end
			end
		end
		local l = repulse.length
		if l > EPSILON then
			self._moving = self._moving + repulse
		end

		-- Process picking and throwing.
		if self._picking then
			self._picking = false
		end
		if self._throwing then
			local weapon = self:weapon()
			if weapon ~= nil then
				self:setWeapon(nil)
				weapon:revive()
				weapon:throw(self._facing)
				table.insert(self._game.pending, weapon)

				self._game.room.check(self, 'throw', weapon)
			end

			self._throwing = false
		end

		-- Finish.
		return self
	end
}, Character)
