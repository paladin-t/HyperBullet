--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Enemy = class({
	--[[ Variables. ]]

	group = 'enemy',

	_goals = nil,

	--[[ Constructor. ]]

	ctor = function (self, resource, box, isBlocked, options)
		Character.ctor(self, resource, box, isBlocked, options)
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
		local goal = (self._goals ~= nil and #self._goals > 0) and self._goals[1] or nil
		local dst = nil
		if goal == nil then
			dst = Vec2.new(hero.x, hero.y)
		else
			dst = goal
		end
		local src = Vec2.new(self.x, self.y)
		local diff = dst - src
		local l = diff.length
		local epsilon = 4
		if goal ~= nil and l <= epsilon then
			table.remove(self._goals, 1)

			goto again
		elseif goal == nil and l <= epsilon * 4 then
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
		local pos, idx = self:_raycast(src, Vec2.new(hero.x, hero.y) - src) -- Sight intersects with tile.
		if pos == nil then
			self:attack(nil)
		end

		if DEBUG then
			if pos then
				line(src.x, src.y, pos.x, pos.y, Color.new(255, 255, 255, 128))
			else
				line(src.x, src.y, hero.x, hero.y, Color.new(255, 0, 0, 128))
			end
		end

		-- Interact with objects.
		for _, v in ipairs(self._game.objects) do
			if v.group == 'hero' then
				local weapon = self:weapon()
				if weapon ~= nil then
					local affecting, shape = weapon:affecting()
					if affecting then
						if v:intersectsWithShape(shape) then -- Hero intersects with enemy's melee.
							v:hurt(weapon)

							local weapon = v:weapon()
							if weapon ~= nil then
								v:setWeapon(nil)
								weapon:revive()
								table.insert(self._game.pending, weapon)
							end
						end
					end
				end
			elseif v.group == 'enemy' then
				-- Do nothing.
			elseif v.group == 'weapon' then
				if v:throwing() then
					if v:ownerGroup() ~= 'enemy' and self:intersects(v) then -- Enemy intersects with a weapon which is being thrown.
						v:throw(nil)

						self:hurt(v)

						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._game.pending, weapon)
						end
					end
				end
			elseif v.group == 'bullet' then
				local ownerGroup = v:ownerGroup()
				if ownerGroup ~= 'enemy' then
					if self:intersects(v) then -- Enemy intersects with bullet.
						self:hurt(v)
						if not v:penetrable() then
							v:kill()
						end

						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._game.pending, weapon)
						end
					end
				end
			end
		end

		-- Finish.
		return self
	end
}, Character)
