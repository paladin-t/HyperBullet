--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Tutorials = {
	['tutorial1'] = function (game, index)
		print('Build tutorial1 for tutorial ' .. tostring(index) .. '.')

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(196, 197, 180)
			},
			--[[ Background asset.      ]] Resources.load('assets/maps/tutorial1_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/tutorial1_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/tutorial1_foreground.map'),
			--[[ Lingering way points.  ]] nil,
			--[[ Passing-by way points. ]] nil,
			--[[ Clips.                 ]] nil,
			--[[ Effects.               ]] {
				{
					type = 'tips',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'W/A/S/D to move'
				},
				{
					type = 'tips',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'Move mouse to look around'
				},
				{
					type = 'tips',
					x = 0.5, y = 0.4,
					layer = 'background',
					content = 'Press R to pick an item'
				}
			},
			--[[ Environments.          ]] nil,
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'pistol',
					capacity = nil,
					position = nil,
					isBlocked = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						Coroutine.waitFor(0.5)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = true,
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 0,
				finishingCondition = function (game, action, data)
					local weapon = game.hero:weapon()
					if weapon ~= nil then
						game.state = States['wait'](
							game,
							1,
							'OK',
							function ()
								game:tutorial(game.tutorialIndex + 1)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end,
	['tutorial2'] = function (game, index)
		print('Build tutorial2 for tutorial ' .. tostring(index) .. '.')

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(196, 197, 180)
			},
			--[[ Background asset.      ]] Resources.load('assets/maps/tutorial2_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/tutorial2_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/tutorial2_foreground.map'),
			--[[ Lingering way points.  ]] nil,
			--[[ Passing-by way points. ]] {
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 48), Vec2.new(96, 48),
					Vec2.new(368, 48), Vec2.new(480, 48), Vec2.new(480, 160),
					Vec2.new(528, 160)
				}
			},
			--[[ Clips.                 ]] nil,
			--[[ Effects.               ]] {
				{
					type = 'tips',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'Equip yourself with the pistol'
				},
				{
					type = 'tips',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'Aim and LMB to shoot'
				}
			},
			--[[ Environments.          ]] nil,
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'pistol',
					capacity = -1,
					position = nil,
					isBlocked = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						coroutine.yield('enemy1_pass_by_none')

						Coroutine.waitFor(2.5)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = true,
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if game.killingCount >= 3 then
						game.state = States['wait'](
							game,
							1,
							'OK',
							function ()
								game:tutorial(game.tutorialIndex + 1)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end,
	['tutorial3'] = function (game, index)
		print('Build tutorial3 for tutorial ' .. tostring(index) .. '.')

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(196, 197, 180)
			},
			--[[ Background asset.      ]] Resources.load('assets/maps/tutorial3_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/tutorial3_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/tutorial3_foreground.map'),
			--[[ Lingering way points.  ]] nil,
			--[[ Passing-by way points. ]] {
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 48), Vec2.new(96, 48),
					Vec2.new(368, 48), Vec2.new(480, 48), Vec2.new(480, 160),
					Vec2.new(528, 160)
				}
			},
			--[[ Clips.                 ]] nil,
			--[[ Effects.               ]] {
				{
					type = 'tips',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'Equip yourself with the knife'
				},
				{
					type = 'tips',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'LMB to slash with a melee weapon'
				}
			},
			--[[ Environments.          ]] nil,
			--[[ Initial weapons.       ]] {
				{
					class = 'Melee',
					type = 'knife',
					capacity = nil,
					position = nil,
					isBlocked = nil
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						coroutine.yield('enemy1_pass_by_none')

						Coroutine.waitFor(2.5)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = true,
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if game.killingCount >= 3 then
						game.state = States['wait'](
							game,
							1,
							'OK',
							function ()
								game:tutorial(game.tutorialIndex + 1)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end,
	['tutorial4'] = function (game, index)
		print('Build tutorial4 for tutorial ' .. tostring(index) .. '.')

		local WALKABLE_CEL = 768
		local THROWABLE_CEL = 833
		local WALL_CEL = 1000

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(196, 197, 180)
			},
			--[[ Background asset.      ]] Resources.load('assets/maps/tutorial4_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/tutorial4_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/tutorial4_foreground.map'),
			--[[ Lingering way points.  ]] nil,
			--[[ Passing-by way points. ]] {
				{
					Vec2.new(-32, 160),
					Vec2.new(32, 160), Vec2.new(32, 48), Vec2.new(96, 48),
					Vec2.new(368, 48), Vec2.new(480, 48), Vec2.new(480, 160),
					Vec2.new(528, 160)
				}
			},
			--[[ Clips.                 ]] nil,
			--[[ Effects.               ]] {
				{
					type = 'tips',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'RMB or F to throw any weapon to attack'
				}
			},
			--[[ Environments.          ]] nil,
			--[[ Initial weapons.       ]] {
				{
					class = 'Melee',
					type = 'knife',
					capacity = nil,
					position = nil,
					isBlocked = function (pos)
						local cel = mget(game.building, pos.x, pos.y)
						if cel ~= WALKABLE_CEL and cel ~= THROWABLE_CEL then
							return true
						end
						if game.foreground ~= nil then
							cel = mget(game.foreground, pos.x, pos.y)
							if cel >= WALL_CEL then
								return true
							end
						end

						return false
					end
				}
			},
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						coroutine.yield('enemy1_pass_by_none')

						Coroutine.waitFor(2.5)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = true,
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if action == 'throw' then
						game.initializeWeapons()
					end

					if game.killingCount >= 3 then
						game.state = States['wait'](
							game,
							1,
							'OK',
							function ()
								game.state = States['tutorial_win'](game)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end
}
