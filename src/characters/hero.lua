--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'character'

Hero = class({
	--[[ Variables. ]]

	group = 'hero',

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Character.ctor(self, sprite, box, isBlocked, options)
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
		for _, v in ipairs(self._context.objects) do
			if v.group == 'enemy' then
				local weapon = self:weapon()
				if weapon ~= nil then
					local affecting, shape = weapon:affecting()
					if affecting then
						if v:intersectsWithShape(shape) then
							v:hurt(weapon)

							local weapon = v:weapon()
							if weapon ~= nil then
								v:setWeapon(nil)
								weapon:revive()
								table.insert(self._context.pending, weapon)
							end
						end
					end
				end
			elseif v.group == 'weapon' then
				if v:throwing() then
					if v:ownerGroup() ~= 'hero' and self:intersects(v) then
						v:throw(nil)

						self:hurt(v)

						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._context.pending, weapon)
						end
					end
				elseif self._picking then
					if self:intersects(v) then
						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._context.pending, weapon)
						end

						self:setWeapon(v)
						v:kill()
					end
				end
			elseif v.group == 'bullet' then
				local ownerGroup = v:ownerGroup()
				if ownerGroup == 'enemy' then
					if not IMMORTAL and self:intersects(v) then
						self:hurt(v)

						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._context.pending, weapon)
						end
					end
				end
			end
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
				table.insert(self._context.pending, weapon)
			end

			self._throwing = false
		end

		-- Finish.
		return self
	end
}, Character)
