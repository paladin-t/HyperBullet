--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local build = function (background, building, lingeringPoints, passingByPoints, initialWeapons, enemySequence, options)
	return {
		background = background, building = building,
		wave = function (game, isBlocked, isBulletBlocked)
			-- Prepare.
			local WEAPON_ORIGIN = Vec2.new(building.width * 16 * 0.5, building.height * 16 * 0.5)
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
					:setDisappearable(false)
					:on('picked', function (sender, owner)
						sender:off('picked')
						remove(weapons, sender)
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
					pos = WEAPON_ORIGIN + WEAPON_VECTOR:rotated(
						math.pi * 2 * ((i - 1) / #initialWeapons)
							+ math.pi * 0.07
					)
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
				if game.enemyCount < options.maxEnemyCount and not DEBUG_PAUSE_SPAWNING then
					-- Generate enemy.
					local _, type_ = coroutine.resume(enemySequence)
					local cfg = Enemies[type_]
					local enemy = Enemy.new(
						Resources.load(cfg['assets'][1]), Resources.load(cfg['assets'][2]),
						cfg['box'],
						isBlocked, isBulletBlocked,
						{
							game = game,
							hp = cfg['hp'],
							behaviours = cfg['behaviours'],
							lookAtTarget = cfg['look_at_target'],
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
			--[[ Background asset.      ]] Resources.load('assets/maps/map1_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/map1_building.map'),
			--[[ Lingering way points.  ]] {
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 48), Vec2.new(96, 48)
				},
				{
					Vec2.new(528, 160),
					Vec2.new(480, 160), Vec2.new(480, 272), Vec2.new(368, 272)
				},
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 272), Vec2.new(96, 272)
				},
				{
					Vec2.new(528, 160),
					Vec2.new(480, 160), Vec2.new(480, 48), Vec2.new(368, 48)
				}
			},
			--[[ Passing-by way points. ]] {
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 48), Vec2.new(96, 48),
					Vec2.new(368, 48), Vec2.new(480, 48), Vec2.new(480, 160),
					Vec2.new(528, 160)
				},
				{
					Vec2.new(528, 160),
					Vec2.new(480, 160), Vec2.new(480, 272), Vec2.new(368, 272),
					Vec2.new(96, 272), Vec2.new(32, 272), Vec2.new(32, 160),
					Vec2.new(-32, 160)
				},
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 272), Vec2.new(96, 272),
					Vec2.new(368, 272), Vec2.new(480, 272), Vec2.new(480, 160),
					Vec2.new(528, 160)
				},
				{
					Vec2.new(528, 160),
					Vec2.new(480, 160), Vec2.new(480, 48), Vec2.new(368, 48),
					Vec2.new(96, 48), Vec2.new(32, 48), Vec2.new(32, 160),
					Vec2.new(-32, 160)
				}
			},
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'pistol',
					position = nil
				},
				{
					class = 'Gun',
					type = 'dual_pistols',
					position = nil
				},
				{
					class = 'Gun',
					type = 'shotgun',
					position = nil
				},
				{
					class = 'Gun',
					type = 'submachine_gun',
					position = nil
				},
				{
					class = 'Gun',
					type = 'machine_gun',
					position = nil
				},
				{
					class = 'Gun',
					type = 'rifle',
					position = nil
				},
				{
					class = 'Gun',
					type = 'laser',
					position = nil
				},
				{
					class = 'Gun',
					type = 'disc_gun',
					position = nil
				},
				{
					class = 'Gun',
					type = 'mines',
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
					local prob = Probabilistic.new()
						:add({ type = 'enemy1_chase_knife' }, 50)
						:add({ type = 'enemy1_besiege_knife' }, 50)
						:add({ type = 'enemy1_chase_pistol' }, 50)
						:add({ type = 'enemy1_chase_dual_pistols' }, 50)
						:add({ type = 'enemy1_chase_shotgun' }, 20)
						:add({ type = 'enemy1_chase_submachine_gun' }, 20)
						:add({ type = 'enemy1_chase_machine_gun' }, 10)
						:add({ type = 'enemy1_pass_by_rifle' }, 20)
						:add({ type = 'enemy1_pass_by_laser' }, 10)
						:add({ type = 'enemy1_chase_disc_gun' }, 20)
						:add({ type = 'enemy1_chase_mines' }, 20)

					while true do
						local data, _ = prob:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				maxEnemyCount = 3,
				finishingCondition = function (game)
					return game.killingCount >= 20
				end
			}
		)
	end
}
