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
				-- Do nothing.
			elseif v.group == 'weapon' then
				if v:throwing() then
					v:throw(nil)

					self:kill()

					local weapon = self:weapon()
					if weapon ~= nil then
						self:setWeapon(nil)
						weapon:revive()
						table.insert(self._context.objects, weapon)
					end
				elseif self._picking and self:weapon() == nil then
					if self:intersects(v) then
						self:setWeapon(v)
						v:kill()
					end
				end
			elseif v.group == 'bullet' then
				local ownerGroup = v:ownerGroup()
				if ownerGroup == 'enemy' then
					if self:intersects(v) then
						self:kill()

						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._context.objects, weapon)
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
				table.insert(self._context.objects, weapon)
			end

			self._throwing = false
		end

		-- Finish.
		return self
	end
}, Character)
