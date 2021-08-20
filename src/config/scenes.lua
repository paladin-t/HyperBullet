--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Scenes = {
	['room1'] = function (game, isBlocked)
		return {
			['map'] = Resources.load('assets/maps/map1.map'),
			['wave'] = function (level)
				-- Prepare.
				Coroutine.waitFor(1.5)
	
				-- Way points.
				local goals = {
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
				}
				local n = 1
	
				-- Spawn enemies.
				while not game.gameover do
					-- Delay.
					Coroutine.waitFor(1.5)
	
					-- Spawn.
					if game.enemyCount < 1 and not PAUSE_SPAWNING then
						-- Generate enemy.
						local type_ = 'enemy1'
						local cfg = Enemies[type_]
						local enemy = Enemy.new(
							cfg['resource'],
							cfg['box'],
							isBlocked,
							{
								game = game,
								hp = cfg['hp'],
								moveSpeed = cfg['move_speed']
							}
						)
						local goal = goals[n]
						local pos = car(goal)
						enemy.x, enemy.y = pos.x, pos.y
						enemy:setGoals(cdr(goal))
						enemy:reset()
						table.insert(game.objects, enemy)
	
						-- Setup event handler.
						enemy:on('dead', function (sender)
							game.enemyCount = game.enemyCount - 1
							game:addScore(10)
						end)
						game.enemyCount = game.enemyCount + 1
	
						-- Equip with weapon.
						local weapon = Gun.new(
							isBlocked,
							{
								type = 'pistol',
								game = game,
							}
						)
						enemy:setWeapon(weapon)
						weapon:kill()
	
						-- Finish.
						n = n + 1
						if n > #goals then
							n = 1
						end
					end
				end
			end
		}
	end
}
