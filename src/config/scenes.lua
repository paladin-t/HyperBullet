--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Scenes = {
	['wave1'] = function (co, context, isBlocked)
		return function ()
			-- Prepare.
			Coroutine.waitFor(1.5)

			-- Way points.
			local goals = {
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 32), Vec2.new(96, 32),
					'hero'
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 240), Vec2.new(368, 240),
					'hero'
				},
				{
					Vec2.new(-32, 144),
					Vec2.new(32, 144), Vec2.new(32, 240), Vec2.new(96, 240),
					'hero'
				},
				{
					Vec2.new(496, 144),
					Vec2.new(432, 144), Vec2.new(432, 32), Vec2.new(368, 32),
					'hero'
				}
			}
			local n = 1

			-- Spawn enemies.
			while not context.gameover do
				-- Delay.
				Coroutine.waitFor(1.5)

				-- Spawn.
				if context.enemyCount < 10 then
					-- Generate enemy.
					local type_ = 'enemy1'
					local cfg = Enemies[type_]
					local enemy = Enemy.new(
						cfg['resource'],
						cfg['box'],
						isBlocked,
						{
							co = co,
							context = context,
							hp = cfg['hp'],
							atk = cfg['atk'],
							moveSpeed = cfg['move_speed']
						}
					)
					local goal = goals[n]
					local pos = car(goal)
					enemy.x, enemy.y = pos.x, pos.y
					enemy:setGoals(cdr(goal))
					enemy:reset()
					table.insert(context.objects, enemy)

					-- Setup event handler.
					enemy:on('dead', function (sender)
						context.enemyCount = context.enemyCount - 1
						context:addScore(10)
					end)
					context.enemyCount = context.enemyCount + 1

					-- Equip with weapon.
					local weapon = Gun.new(
						Resources.load('gun.spr'),
						Recti.byXYWH(0, 0, 16, 16),
						{
							type = 'pistol'
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
	end
}
