--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'character'

Enemy = class({
	--[[ Variables. ]]

	group = 'enemy',

	_goals = nil,

	--[[ Constructor. ]]

	ctor = function (self, sprite, box, isBlocked, options)
		Character.ctor(self, sprite, box, isBlocked, options)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Enemy'
	end,

	--[[ Methods. ]]

	setGoals = function (self, goals)
		self._goals = goals

		return self
	end,

	behave = function (self, delta, hero)
		-- Prepare.
		Character.behave(self, delta, hero)

		-- Walk through way points.
		::again::
		local goal = self._goals[1]
		local dst = nil
		if goal == 'hero' then
			dst = Vec2.new(hero.x, hero.y)
		else
			dst = goal
		end
		local src = Vec2.new(self.x, self.y)
		local diff = dst - src
		local l = diff.length
		local epsilon = 4
		if goal ~= 'hero' and l <= epsilon then
			table.remove(self._goals, 1)

			goto again
		elseif goal == 'hero' and l <= epsilon * 4 then
			-- Do nothing.
		else
			if l >= epsilon * 2 then
				if diff.x <= -epsilon then
					self:moveLeft(delta)
				elseif diff.x >= epsilon then
					self:moveRight(delta)
				end
				if diff.y <= -epsilon then
					self:moveUp(delta)
				elseif diff.y >= epsilon then
					self:moveDown(delta)
				end
			else
				self._moving = diff
			end
		end

		-- Look at the hero.
		self:lookAt(hero.x, hero.y)

		-- Attack.
		self:attack()

		-- Interact with objects.
		for _, v in ipairs(self._context.objects) do
			if v.group == 'weapon' then
				-- TODO
			elseif v.group == 'bullet' then
				local emitter = v:owner():owner()
				if emitter.group == 'hero' then
					if self:intersects(v) then
						self:kill()
					end
				end
			end
		end
	end
}, Character)
