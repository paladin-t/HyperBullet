--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Enemy = class({
	--[[ Variables. ]]

	group = 'enemy',

	_behaviours = nil,
	_goals = nil,
	_lookAtTarget = nil,

	--[[ Constructor. ]]

	ctor = function (self, resources, box, isBlocked, isBulletBlocked, options)
		Character.ctor(self, resources, box, isBlocked, isBulletBlocked, options)

		self._behaviours = transform(options.behaviours, function (b, _)
			return Behaviours[b]()
		end)
		self._lookAtTarget = options.lookAtTarget
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
	lookAtTarget = function (self)
		return self._lookAtTarget
	end,
	setLookAtTarget = function (self, lookAtTarget)
		self._lookAtTarget = lookAtTarget

		return self
	end,

	behave = function (self, delta, hero)
		-- Prepare.
		Character.behave(self, delta, hero)

		-- Behave.
		local src, dst = nil, nil
		for _, b in ipairs(self._behaviours) do
			src, dst = b:behave(self, delta, hero, src, dst)
		end

		-- Interact with objects.
		local EPSILON = 1
		local repulse = Vec2.new(0, 0)
		for _, v in ipairs(self._game.objects) do
			if v.group == 'hero' then
				local weapon = self:weapon()
				if weapon ~= nil then
					local affecting, shape = weapon:affecting()
					if affecting then
						if not DEBUG_IMMORTAL and v:intersectsWithShape(shape) then -- Hero intersects with enemy's melee.
							local hadArmour = v:armour()
							v:hurt(weapon)
							local weapon = v:weapon()
							if weapon ~= nil and hadArmour == nil then
								v:setWeapon(nil)
								weapon:revive()
								table.insert(self._game.pending, weapon)
							end
						end
					end
				end
				repulse = repulse + self:_repulse(v)
			elseif v.group == 'enemy' then
				if v ~= self then
					repulse = repulse + self:_repulse(v)
				end
			elseif v.group == 'weapon' then
				if v:throwing() then
					if v:ownerGroup() ~= 'enemy' and self:intersects(v) then -- Enemy intersects with a weapon which is being thrown.
						v:throw(nil)

						local hadArmour = self:armour()
						self:hurt(v)
						local weapon = self:weapon()
						if weapon ~= nil and hadArmour == nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._game.pending, weapon)
						end
					end
				elseif self._picking then
					if self:intersects(v) then -- Enemy intersects with weapon for picking.
						local weapon = self:weapon()
						if weapon ~= nil then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._game.pending, weapon)
						end

						self:setWeapon(v)
						v:kill('picked', nil)
					end
				end
			elseif v.group == 'armour' then
				-- Do nothing.
			elseif v.group == 'bullet' then
				local ownerGroup = v:ownerGroup()
				if ownerGroup ~= 'enemy' then
					if self:intersects(v) then -- Enemy intersects with bullet.
						local hadArmour = self:armour()
						self:hurt(v)
						if not v:penetrable() then
							v:kill('killed', self)
						end
						local weapon = self:weapon()
						if weapon ~= nil and hadArmour == nil and self._game.state.playing then
							self:setWeapon(nil)
							weapon:revive()
							table.insert(self._game.pending, weapon)
						end
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
			end

			self._throwing = false
		end

		-- Finish.
		return self
	end
}, Character)
