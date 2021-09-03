--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Scenes = {
	['room1'] = function (game, index)
		print('Build room1 for level ' .. tostring(index) .. '.')

		local enemyCandidates = Probabilistic.new() -- Enemy candidates.
		if index == 1 then
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
		elseif index == 2 then
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
				:add({ type = 'enemy1_chase_submachine_gun' }, 20)
				:add({ type = 'enemy1_chase_machine_gun' }, 10)
		else
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
				:add({ type = 'enemy1_chase_submachine_gun' }, 20)
				:add({ type = 'enemy2_chase_submachine_gun_body_armour' }, 5)
				:add({ type = 'enemy1_chase_machine_gun' }, 10)
				:add({ type = 'enemy2_chase_machine_gun_body_armour' }, 5)
				:add({ type = 'enemy1_pass_by_rifle' }, 20)
				:add({ type = 'enemy1_pass_by_laser' }, 10)
				:add({ type = 'enemy1_chase_disc_gun' }, 20)
				:add({ type = 'enemy1_chase_mines' }, 20)
		end

		return game:build(
			--[[ Background asset.      ]] Resources.load('assets/maps/map1_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/map1_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/map1_foreground.map'),
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
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'dual_pistols',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'shotgun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'submachine_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'machine_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'rifle',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'laser',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'disc_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'mines',
					capacity = nil,
					position = nil
				},
				{
					class = 'Melee',
					type = 'knife',
					capacity = nil,
					position = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						local data, _ = enemyCandidates:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				initialWeaponsAngle = nil,
				maxEnemyCount = 3,
				finishingCondition = function (game)
					if game.killingCount >= 10 then
						game:play(true, false)

						return true
					end

					return false
				end
			},
			--[[ Clear colors.          ]] {
				Color.new(80, 80, 80)
			},
			--[[ Effects.               ]] nil
		)
	end,
	['room2'] = function (game, index)
		print('Build room2 for level ' .. tostring(index) .. '.')

		local enemyCandidates = Probabilistic.new() -- Enemy candidates.
		if index == 1 then
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
		elseif index == 2 then
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
				:add({ type = 'enemy1_chase_submachine_gun' }, 20)
				:add({ type = 'enemy1_chase_machine_gun' }, 10)
		else
			enemyCandidates
				:add({ type = 'enemy1_chase_knife' }, 50)
				:add({ type = 'enemy1_besiege_knife' }, 50)
				:add({ type = 'enemy1_chase_pistol' }, 50)
				:add({ type = 'enemy1_chase_dual_pistols' }, 50)
				:add({ type = 'enemy1_chase_shotgun' }, 20)
				:add({ type = 'enemy1_chase_submachine_gun' }, 20)
				:add({ type = 'enemy2_chase_submachine_gun_body_armour' }, 5)
				:add({ type = 'enemy1_chase_machine_gun' }, 10)
				:add({ type = 'enemy2_chase_machine_gun_body_armour' }, 5)
				:add({ type = 'enemy1_pass_by_rifle' }, 20)
				:add({ type = 'enemy1_pass_by_laser' }, 10)
				:add({ type = 'enemy1_chase_disc_gun' }, 20)
				:add({ type = 'enemy1_chase_mines' }, 20)
		end

		return game:build(
			--[[ Background asset.      ]] Resources.load('assets/maps/map2_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/map2_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/map2_foreground.map'),
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
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'dual_pistols',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'shotgun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'submachine_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'machine_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'rifle',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'laser',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'disc_gun',
					capacity = nil,
					position = nil
				},
				{
					class = 'Gun',
					type = 'mines',
					capacity = nil,
					position = nil
				},
				{
					class = 'Melee',
					type = 'knife',
					capacity = nil,
					position = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						local data, _ = enemyCandidates:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				initialWeaponsAngle = nil,
				maxEnemyCount = 3,
				finishingCondition = function (game)
					if game.killingCount >= 10 then
						game:play(true, false)

						return true
					end

					return false
				end
			},
			--[[ Clear colors.          ]] {
				Color.new(80, 80, 80)
			},
			--[[ Effects.               ]] nil
		)
	end
}
