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
			if v.group == 'weapon' then
				if self:weapon() == nil then
					if self:intersects(v) then
						self:setWeapon(v)
						v:kill()
					end
				end
			elseif v.group == 'enemy' then
				-- TODO
			elseif v.group == 'bullet' then
				local emitter = v:owner():owner()
				if emitter.group == 'enemy' then
					if self:intersects(v) then
						self:kill()
					end
				end
			end
		end
	end
}, Character)
