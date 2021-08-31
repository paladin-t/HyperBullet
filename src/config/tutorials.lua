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
			--[[ Background asset.      ]] Resources.load('assets/maps/tutorial1_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/tutorial1_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/tutorial1_foreground.map'),
			--[[ Lingering way points.  ]] nil,
			--[[ Passing-by way points. ]] nil,
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'pistol',
					capacity = nil,
					position = nil
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
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 0,
				finishingCondition = function (game)
					local weapon = game.hero:weapon()
					if weapon ~= nil then
						game:tutorial(game.tutorialIndex + 1)

						return true
					end

					return false
				end
			},
			--[[ Effects.               ]] {
				{
					type = 'text',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'W/A/S/D to move'
				},
				{
					type = 'text',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'Move mouse to look around'
				},
				{
					type = 'text',
					x = 0.5, y = 0.4,
					layer = 'background',
					content = 'Press R to pick an item'
				}
			}
		)
	end,
	['tutorial2'] = function (game, index)
		print('Build tutorial2 for tutorial ' .. tostring(index) .. '.')

		return game:build(
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
			--[[ Initial weapons.       ]] {
				{
					class = 'Gun',
					type = 'pistol',
					capacity = -1,
					position = nil
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
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 3,
				finishingCondition = function (game)
					if game.killingCount >= 3 then
						game:tutorial(game.tutorialIndex + 1)

						return true
					end

					return false
				end
			},
			--[[ Effects.               ]] {
				{
					type = 'text',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'Equip a weapon'
				},
				{
					type = 'text',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'Aim and LMB to shoot'
				}
			}
		)
	end,
	['tutorial3'] = function (game, index)
		print('Build tutorial3 for tutorial ' .. tostring(index) .. '.')

		return game:build(
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
			--[[ Initial weapons.       ]] {
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
						coroutine.yield('enemy1_pass_by_none')

						Coroutine.waitFor(2.5)
					end
				end
			),
			--[[ Other options.         ]] {
				initialWeaponsAngle = math.pi * 0.5,
				maxEnemyCount = 3,
				finishingCondition = function (game)
					if game.killingCount >= 3 then
						game.state = States['tutorial_win'](game)

						return true
					end

					return false
				end
			},
			--[[ Effects.               ]] {
				{
					type = 'text',
					x = 0.5, y = 0.3,
					layer = 'background',
					content = 'Equip a weapon'
				},
				{
					type = 'text',
					x = 0.5, y = 0.35,
					layer = 'background',
					content = 'LMB to slash with a melee weapon'
				},
				{
					type = 'text',
					x = 0.5, y = 0.4,
					layer = 'background',
					content = 'RMB or F to throw any weapon to attack'
				}
			}
		)
	end
}
