--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Pool = class({
	_bullets = nil,
	_effects = nil,

	ctor = function (self)
	end,

	__tostring = function (self)
		return 'Pool'
	end,

	-- Generates a bullet.
	bullet = function (self, type, x, y, direction, group, game, isBulletBlocked)
		-- Prepare.
		if type == nil then
			return nil
		end
		local obj, cached = nil, false
		if self._bullets ~= nil and self._bullets[type] ~= nil then
			for _, b in ipairs(self._bullets[type]) do
				if b:dead() then
					obj, cached = b, true
					obj:revive()

					break
				end
			end
		end

		-- Generate.
		local cfg = Bullets[type]
		if not cached then
			obj = Bullet.new(
				cfg['resource'],
				isBulletBlocked,
				{
					game = game,
					atk = cfg['atk'],
					box = cfg['box'], maxBox = cfg['max_box'],
					moveSpeed = cfg['move_speed'],
					lifetime = cfg['lifetime'],
					penetrable = cfg['penetrable'],
					bouncy = cfg['bouncy'],
					explosive = cfg['explosive']
				}
			)
		end

		-- Cache.
		if not cached then
			if self._bullets == nil then
				self._bullets = { }
			end
			if self._bullets[type] == nil then
				self._bullets[type] = { }
			end
			table.insert(self._bullets[type], obj)
		end
		obj
			:setOwnerGroup(group)
			:setDirection(direction)
			:play(
				'idle', true, true
			)
		obj.x, obj.y = x, y

		-- Finish.
		return obj
	end,

	-- Generates an effect.
	effect = function (self, type, x, y, game)
		-- Prepare.
		if type == nil then
			return nil
		end
		local obj, cached = nil, false
		if self._effects ~= nil and self._effects[type] ~= nil then
			for _, fx in ipairs(self._effects[type]) do
				if fx:dead() then
					obj, cached = fx, true
					obj:revive()

					break
				end
			end
		end

		-- Generate.
		local autoRemove = false
		if type == 'appearance' then
			if not cached then
				obj = Object.new(
					Resources.load('assets/sprites/appearance.spr'),
					Recti.byXYWH(0, 0, 16, 16),
					nil
				)
			end
			autoRemove = true
		elseif type == 'disappearance' then
			if not cached then
				obj = Object.new(
					Resources.load('assets/sprites/disappearance.spr'),
					Recti.byXYWH(0, 0, 16, 16),
					nil
				)
			end
			autoRemove = true
		elseif type == 'text' then
			obj = Text.new(
				{
					game = game
				}
			)
			obj.x, obj.y = x, y

			return obj -- Return ahead.
		else
			error('Unknown effect: ' .. type .. '.')
		end

		-- Cache.
		if not cached then
			if self._effects == nil then
				self._effects = { }
			end
			if self._effects[type] == nil then
				self._effects[type] = { }
			end
			table.insert(self._effects[type], obj)
		end
		obj
			:play(
				'idle', true, false,
				autoRemove and function ()
					obj:kill('disappeared')
				end or nil
			)
		obj.x, obj.y = x, y

		-- Finish.
		return obj
	end,

	-- Collect objects in the pool.
	collect = function (self, deep)
		if deep then
			self._bullets = nil
			self._effects = nil
		else
			if self._bullets ~= nil then
				for type, effects in pairs(self._bullets) do
					self._bullets[type] = take(effects, 32)
				end
			end
			if self._effects ~= nil then
				for type, effects in pairs(self._effects) do
					self._effects[type] = take(effects, 16)
				end
			end
		end

		return self
	end
})
