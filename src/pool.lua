--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Pool = class({
	_bullets = nil,
	_shellCases = nil,
	_effects = nil,

	ctor = function (self)
	end,

	__tostring = function (self)
		return 'Pool'
	end,

	-- Generates a bullet.
	bullet = function (self, type, x, y, direction, group, game, isBlocked)
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
				isBlocked,
				{
					game = game,
					atk = cfg['atk'],
					box = cfg['box'], maxBox = cfg['max_box'],
					moveSpeed = cfg['move_speed'],
					lifetime = cfg['lifetime'],
					penetrable = cfg['penetrable'],
					bouncy = cfg['bouncy'],
					explosive = cfg['explosive'],
					sfxs = cfg['sfxs']
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
	-- Generates a shell case.
	shellCase = function (self, type, x, y, game)
		-- Prepare.
		if type == nil then
			return nil
		end
		local obj, cached = nil, false
		if self._shellCases ~= nil and self._shellCases[type] ~= nil then
			for _, b in ipairs(self._shellCases[type]) do
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
			obj = ShellCase.new(
				cfg['shell_case'],
				{
					game = game,
					lifetime = 1
				}
			)
		end

		-- Cache.
		if not cached then
			if self._shellCases == nil then
				self._shellCases = { }
			end
			if self._shellCases[type] == nil then
				self._shellCases[type] = { }
			end
			table.insert(self._shellCases[type], obj)
		end
		obj
			:reset()
		obj.x, obj.y = x, y
		obj
			:bounce(0.75, 10)

		-- Finish.
		return obj
	end,
	-- Generates an environment object, note environment is not cached.
	environment = function (self, type, x, y, game, isBlocked, options)
		-- Prepare.
		if type == nil then
			return nil
		end
		local obj = nil

		-- Generate.
		local cfg = Environments[type]
		obj = Environment.new(
			transform(cfg['assets'], function (asset, i)
				return Resources.load(asset)
			end),
			cfg['box'],
			isBlocked,
			merge(
				options,
				{
					game = game,
					moveSpeed = cfg['move_speed']
				}
			)
		)

		-- Cache.
		obj.x, obj.y = x, y
		obj
			:setAngle(options.angle)
			:play(
				'idle', false
			)

		-- Finish.
		return obj
	end,
	-- Generates a clip, note clip is not cached.
	clip = function (self, type, x, y, game, options)
		-- Prepare.
		if type == nil then
			return nil
		end
		local obj = nil

		-- Generate.
		if type == 'clip' then
			obj = Clip.new(
				merge(
					options,
					{
						game = game
					}
				)
			)
		else
			error('Unknown effect: ' .. type .. '.')
		end

		-- Cache.
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
		local play, autoRemove = false, false
		if type == 'appearance' then
			if not cached then
				obj = Object.new(
					Resources.load('assets/sprites/appearance.spr'),
					Recti.byXYWH(0, 0, 16, 16),
					nil
				)
			end
			play, autoRemove = true, true
		elseif type == 'disappearance' then
			if not cached then
				obj = Object.new(
					Resources.load('assets/sprites/disappearance.spr'),
					Recti.byXYWH(0, 0, 16, 16),
					nil
				)
			end
			play, autoRemove = true, true
		elseif type == 'blood' then
			if not cached then
				obj = Blood.new(
					{
						game = game
					}
				)
			end
			obj:resize(math.random() * 10 + 10)
		elseif type == 'tips' then
			obj = Tips.new(
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
		if play then
			obj
				:play(
					'idle', true, false,
					autoRemove and function ()
						obj:kill('disappeared', nil)
					end or nil
				)
		end
		obj.x, obj.y = x, y

		-- Finish.
		return obj
	end,

	-- Collect objects in the pool.
	collect = function (self, deep)
		if deep then
			self._bullets = nil
			self._shellCases = nil
			self._effects = nil
		else
			if self._bullets ~= nil then
				for type, lst in pairs(self._bullets) do
					self._bullets[type] = take(lst, 32)
				end
			end
			if self._shellCases ~= nil then
				for type, lst in pairs(self._shellCases) do
					self._shellCases[type] = take(lst, 16)
				end
			end
			if self._effects ~= nil then
				for type, lst in pairs(self._effects) do
					self._effects[type] = take(lst, 16)
				end
			end
		end

		return self
	end
})
