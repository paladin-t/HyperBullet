--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local build = function (map_, lingeringPoints, passingByPoints, initialWeapons, enemySequence, options)
	return {
		map = map_,
		wave = function (game, isBlocked)
			-- Prepare.
			local WEAPON_ORIGIN = Vec2.new(map_.width * 16 * 0.5, map_.height * 16 * 0.5)
			local WEAPON_VECTOR = Vec2.new(100, 0)
			local weapons = { }
			forEach(initialWeapons, function (w, i)
				local weapon = (w.class == 'Gun' and Gun or Melee).new(
					game.isEnvironmentBlocked,
					{
						type = w.type,
						game = game,
					}
				)
					:on('picked', function (sender, owner)
						remove(weapons, weapon)
						if owner == game.hero then
							forEach(weapons, function (w, _)
								w:kill()

								local fx = game.pool:effect('disappearance', w.x, w.y, game)
								table.insert(game.foregroundEffects, fx)
							end)
						end
					end)
				table.insert(weapons, weapon)
				local pos = w.position
				if pos == nil then
					pos = WEAPON_ORIGIN + WEAPON_VECTOR:rotated(math.pi * 2 * ((i - 1) / #initialWeapons))
				end
				weapon.x, weapon.y = pos.x, pos.y
				table.insert(game.objects, weapon)

				local fx = game.pool:effect('appearance', pos.x, pos.y, game)
				table.insert(game.foregroundEffects, fx)
			end)

			local pointIndex = 1

			-- Delay.
			Coroutine.waitFor(1.5)

			-- Spawn enemies.
			while game.state.playing do
				-- Delay.
				Coroutine.waitFor(1.5)

				-- Spawn.
				if game.enemyCount < options.maxEnemyCount and not PAUSE_SPAWNING then
					-- Generate enemy.
					local _, type_ = coroutine.resume(enemySequence)
					local cfg = Enemies[type_]
					local enemy = Enemy.new(
						cfg['resource'],
						cfg['box'],
						isBlocked,
						{
							game = game,
							hp = cfg['hp'],
							behaviours = cfg['behaviours'],
							moveSpeed = cfg['move_speed']
						}
					)
					local isLingering, isPassingBy =
						exists(cfg['behaviours'], 'chase') or exists(cfg['behaviours'], 'besiege'),
						exists(cfg['behaviours'], 'pass_by')
					local points = nil
					if isLingering then
						points = lingeringPoints
					elseif isPassingBy then
						points = passingByPoints
					end
					local goal = points[pointIndex]
					local pos = car(goal)
					enemy.x, enemy.y = pos.x, pos.y
					enemy:setGoals(cdr(goal))
					enemy:reset()
					table.insert(game.objects, enemy)

					local fx = game.pool:effect('appearance', pos.x, pos.y, game)
					table.insert(game.foregroundEffects, fx)

					-- Setup event handler.
					enemy:on('dead', function (sender, reason)
						if reason == 'killed' then
							game.enemyCount = game.enemyCount - 1
							game:addKilling(1)
							game:addScore(cfg['score'])

							local fx = game.pool:effect('disappearance', sender.x, sender.y, game)
							table.insert(game.foregroundEffects, fx)
						end
					end)
					game.enemyCount = game.enemyCount + 1

					-- Equip with weapon.
					local weaponCfg = Weapons[cfg['weapon']]
					local weapon = (weaponCfg['class'] == 'Gun' and Gun or Melee).new(
						isBlocked,
						{
							type = cfg['weapon'],
							game = game,
						}
					)
					enemy:setWeapon(weapon)
					weapon:kill('picked')

					-- Finish.
					pointIndex = pointIndex + 1
					if pointIndex > #points then
						pointIndex = 1
					end
				end
			end
		end,
		finished = function (game)
			return options.finishingCondition(game)
		end
	}
end

Scenes = {
	['room1'] = function (level)
		print('Build room1 for level ' .. tostring(level) .. '.')

		return build(
			--[[ Map asset.             ]] Resources.load('assets/maps/map1.map'),
			--[[ Lingering way points.  ]] {
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 32), Vec2.new(96, 32)
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 240), Vec2.new(368, 240)
				},
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 240), Vec2.new(96, 240)
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 32), Vec2.new(368, 32)
				}
			},
			--[[ Passing-by way points. ]] {
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 32), Vec2.new(96, 32),
					Vec2.new(368, 32), Vec2.new(432, 32), Vec2.new(432, 144),
					Vec2.new(496, 144)
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 240), Vec2.new(368, 240),
					Vec2.new(96, 240), Vec2.new(32, 240), Vec2.new(32, 144),
					Vec2.new(-32, 144)
				},
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 240), Vec2.new(96, 240),
					Vec2.new(368, 240), Vec2.new(432, 240), Vec2.new(432, 144),
					Vec2.new(496, 144)
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 32), Vec2.new(368, 32),
					Vec2.new(96, 32), Vec2.new(32, 32), Vec2.new(32, 144),
					Vec2.new(-32, 144)
				}
			},
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'dual_pistols',
					position = nil
				},
				{
					class = 'Melee',
					type = 'knife',
					position = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						coroutine.yield('enemy1_chase_pistol')
					end
				end
			),
			--[[ Other options.         ]] {
				maxEnemyCount = 1,
				finishingCondition = function (game)
					return game.killingCount >= 20
				end
			}
		)
	end
}
