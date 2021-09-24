--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local function pickWeapons(index)
	local group1 = {
		{
			class = 'Melee',
			type = 'knife'
		}
	}
	local group2 = {
		{
			class = 'Gun',
			type = 'pistol'
		},
		{
			class = 'Gun',
			type = 'dual_pistols'
		}
	}
	local group3 = {
		{
			class = 'Gun',
			type = 'shotgun'
		},
		{
			class = 'Gun',
			type = 'submachine_gun'
		},
		{
			class = 'Gun',
			type = 'machine_gun'
		},
		{
			class = 'Gun',
			type = 'mines'
		}
	}

	local weaponCandidates = { }
	if index == 1 then
		forEach(group2, function (candidate, _)
			table.insert(weaponCandidates, candidate)
		end)
		forEach(group3, function (candidate, _)
			table.insert(weaponCandidates, candidate)
		end)
		forEach(group1, function (candidate, _)
			table.insert(weaponCandidates, candidate)
		end)
	else
		local one, _ = anyOnce(group1)
		table.insert(weaponCandidates, one)
		one, _ = anyOnce(group2)
		table.insert(weaponCandidates, one)
	end
	weaponCandidates = transform(weaponCandidates, function (candidate, _)
		return {
			class = candidate.class,
			type = candidate.type,
			capacity = nil,
			position = nil,
			isBlocked = nil
		}
	end)

	return weaponCandidates, math.pi * 0.15
end

local function pickEnemies(index)
	local enemyCandidates = Probabilistic.new() -- Enemy candidates.
	if index == 1 or index == 2 then
		enemyCandidates
			:add({ type = 'enemy1_chase_knife' }, 30)
			:add({ type = 'enemy1_besiege_knife' }, 30)
			:add({ type = 'enemy2_pass_by_pistol' }, 30)
			:add({ type = 'enemy2_chase_pistol' }, 30)
			:add({ type = 'enemy2_chase_dual_pistols' }, 30)
			:add({ type = 'enemy3_chase_shotgun' }, 20)
	elseif index == 3 then
		enemyCandidates
			:add({ type = 'enemy1_chase_knife' }, 30)
			:add({ type = 'enemy1_besiege_knife' }, 30)
			:add({ type = 'enemy2_pass_by_pistol' }, 30)
			:add({ type = 'enemy2_chase_pistol' }, 30)
			:add({ type = 'enemy2_chase_dual_pistols' }, 30)
			:add({ type = 'enemy3_chase_shotgun' }, 20)
			:add({ type = 'enemy4_chase_submachine_gun' }, 20)
			:add({ type = 'enemy4_chase_machine_gun' }, 10)
	else
		enemyCandidates
			:add({ type = 'enemy1_chase_knife' }, 30)
			:add({ type = 'enemy1_besiege_knife' }, 30)
			:add({ type = 'enemy2_pass_by_pistol' }, 30)
			:add({ type = 'enemy2_chase_pistol' }, 30)
			:add({ type = 'enemy2_chase_dual_pistols' }, 30)
			:add({ type = 'enemy3_chase_shotgun' }, 20)
			:add({ type = 'enemy4_chase_submachine_gun' }, 20)
			:add({ type = 'enemy4_chase_submachine_gun_body_armour' }, 5)
			:add({ type = 'enemy4_chase_machine_gun' }, 10)
			:add({ type = 'enemy4_chase_machine_gun_body_armour' }, 5)
			:add({ type = 'enemy5_chase_mines' }, 20)
	end

	return enemyCandidates
end

local function modulateClips(index)
	return {
		translate = function (delta, factor)
			local pingpong = math.sin((factor * 1) * math.pi * 2 + math.pi * (index - 1))

			return 0, pingpong * 160
		end,
		scale = function (delta, factor)
			local pingpong = (math.sin((factor * 8) * math.pi * 2) + 1) * 0.5

			return pingpong < 0.5 and 1 or 0.8
		end,
		rotate = function (delta, factor)
			return (factor * 2) * math.pi * 2
		end,
		shadow1 = function (delta, factor)
			local pingpong = math.sin((factor * 16) * math.pi * 2)

			return pingpong * 2, pingpong * 2, Color.new(10, 191, 150, 128)
		end,
		shadow2 = function (delta, factor)
			local pingpong = math.sin((factor * 16) * math.pi * 2)

			return pingpong * -2, pingpong * -2, Color.new(235, 117, 206, 128)
		end
	}
end

Scenes = {
	['room1'] = function (game, index)
		print('Build room1 for level ' .. tostring(index) .. '.')

		local weaponCandidates, weaponAngle = pickWeapons(index)
		local enemyCandidates = pickEnemies(index)

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(35,  17,  54),
				Color.new(11,  111, 191),
				Color.new(147, 28,  132)
			},
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
			--[[ Clips.                 ]] {
				{
					type = 'clip',
					x = -0.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/steps1.png'),
					options = {
						anchor = Vec2.new(0.85, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = 1.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/steps2.png'),
					options = {
						anchor = Vec2.new(0.15, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = -0.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/sculpture1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(1)
					}
				},
				{
					type = 'clip',
					x = 1.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/sculpture1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(2)
					}
				},
				{
					type = 'clip',
					x = 0.5, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/carpet2.png'),
					options = {
						anchor = Vec2.new(0.5, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				}
			},
			--[[ Effects.               ]] nil,
			--[[ Environments.          ]] {
				{
					type = 'painting1',
					x = 0.22, y = 0.16,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'painting2',
					x = 0.88, y = 0.21,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'painting3',
					x = 0.12, y = 0.81,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'painting4',
					x = 0.68, y = 0.80,
					options = {
						angle = math.pi * 2 * math.random()
					}
				}
			},
			--[[ Initial weapons.       ]] weaponCandidates,
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						local data, _ = enemyCandidates:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = false,
				initialWeaponsAngle = weaponAngle,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if game.killingCount >= 10 then
						game.state = States['wait'](
							game,
							1,
							nil,
							function ()
								game:play(true, false)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end,
	['room2'] = function (game, index)
		print('Build room2 for level ' .. tostring(index) .. '.')

		local weaponCandidates, weaponAngle = pickWeapons(index)
		local enemyCandidates = pickEnemies(index)

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(35,  17,  54),
				Color.new(11,  111, 191),
				Color.new(147, 28,  132)
			},
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
			--[[ Clips.                 ]] {
				{
					type = 'clip',
					x = -0.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/carpet1.png'),
					options = {
						anchor = Vec2.new(0.85, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = 1.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/carpet1.png'),
					options = {
						anchor = Vec2.new(0.15, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = -0.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/beer1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(1)
					}
				},
				{
					type = 'clip',
					x = 1.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/beer1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(2)
					}
				},
				{
					type = 'clip',
					x = 0.5, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/carpet3.png'),
					options = {
						anchor = Vec2.new(0.5, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				}
			},
			--[[ Effects.               ]] nil,
			--[[ Environments.          ]] {
				{
					type = 'newspaper1',
					x = 0.22, y = 0.16,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'pizza2',
					x = 0.88, y = 0.21,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'pizza2',
					x = 0.83, y = 0.23,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'pizza1',
					x = 0.24, y = 0.81,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'pizza2',
					x = 0.28, y = 0.76,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'newspaper1',
					x = 0.68, y = 0.80,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle1',
					x = 0.58, y = 0.21,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle2',
					x = 0.56, y = 0.19,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle1',
					x = 0.54, y = 0.51,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle2',
					x = 0.6, y = 0.53,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'chair2',
					x = 0.4, y = 0.35,
					options = {
						angle = -math.pi * 0.5
					}
				},
				{
					type = 'chair2',
					x = 0.46666, y = 0.35,
					options = {
						angle = -math.pi * 0.5
					}
				},
				{
					type = 'chair2',
					x = 0.53332, y = 0.35,
					options = {
						angle = -math.pi * 0.5
					}
				},
				{
					type = 'chair2',
					x = 0.6, y = 0.35,
					options = {
						angle = -math.pi * 0.5
					}
				}
			},
			--[[ Initial weapons.       ]] weaponCandidates,
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						local data, _ = enemyCandidates:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = false,
				initialWeaponsAngle = weaponAngle,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if game.killingCount >= 10 then
						game.state = States['wait'](
							game,
							1,
							nil,
							function ()
								game:play(true, false)
							end
						)

						return true
					end

					return false
				end
			}
		)
	end,
	['room3'] = function (game, index)
		print('Build room3 for level ' .. tostring(index) .. '.')

		local weaponCandidates, weaponAngle = pickWeapons(index)
		local enemyCandidates = pickEnemies(index)

		return game:build(
			--[[ Clear colors.          ]] {
				Color.new(35,  17,  54),
				Color.new(11,  111, 191),
				Color.new(147, 28,  132)
			},
			--[[ Background asset.      ]] Resources.load('assets/maps/map3_background.map'),
			--[[ Building asset.        ]] Resources.load('assets/maps/map3_building.map'),
			--[[ Foreground asset.      ]] Resources.load('assets/maps/map3_foreground.map'),
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
			--[[ Clips.                 ]] {
				{
					type = 'clip',
					x = -0.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/floor1.png'),
					options = {
						anchor = Vec2.new(0.85, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = 1.0, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/floor1.png'),
					options = {
						anchor = Vec2.new(0.15, 0.5),
						scale = nil,
						interval = nil,
						modulators = { }
					}
				},
				{
					type = 'clip',
					x = -0.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/painting1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(1)
					}
				},
				{
					type = 'clip',
					x = 1.07, y = 0.5,
					layer = 'background',
					content = Resources.load('assets/imgs/clips/painting1.png'),
					options = {
						anchor = nil,
						scale = Vec2.new(0.5, 0.5),
						interval = 8.0,
						modulators = modulateClips(2)
					}
				}
			},
			--[[ Effects.               ]] nil,
			--[[ Environments.          ]] {
				{
					type = 'fruit1',
					x = 0.22, y = 0.16,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'fruit1',
					x = 0.26, y = 0.18,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'fruit1',
					x = 0.32, y = 0.13,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle2',
					x = 0.88, y = 0.21,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle3',
					x = 0.78, y = 0.18,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle3',
					x = 0.83, y = 0.19,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle3',
					x = 0.12, y = 0.81,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'bottle2',
					x = 0.21, y = 0.76,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'newspaper1',
					x = 0.68, y = 0.80,
					options = {
						angle = math.pi * 2 * math.random()
					}
				},
				{
					type = 'chair1',
					x = 0.25, y = 0.28,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.376, y = 0.28,
					options = {
						angle = math.pi
					}
				},
				{
					type = 'chair1',
					x = 0.438, y = 0.28,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.563, y = 0.28,
					options = {
						angle = math.pi
					}
				},
				{
					type = 'chair1',
					x = 0.625, y = 0.28,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.75, y = 0.28,
					options = {
						angle = math.pi
					}
				},
				{
					type = 'chair1',
					x = 0.25, y = 0.73,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.376, y = 0.73,
					options = {
						angle = math.pi
					}
				},
				{
					type = 'chair1',
					x = 0.438, y = 0.73,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.563, y = 0.73,
					options = {
						angle = math.pi
					}
				},
				{
					type = 'chair1',
					x = 0.625, y = 0.73,
					options = {
						angle = 0
					}
				},
				{
					type = 'chair1',
					x = 0.75, y = 0.73,
					options = {
						angle = math.pi
					}
				}
			},
			--[[ Initial weapons.       ]] weaponCandidates,
			--[[ Enemy sequence.        ]] coroutine.create(
				function ()
					while true do
						local data, _ = enemyCandidates:next()
						coroutine.yield(data.type)
					end
				end
			),
			--[[ Other options.         ]] {
				isTutorial = false,
				initialWeaponsAngle = weaponAngle,
				maxEnemyCount = 3,
				finishingCondition = function (game, action, data)
					if game.killingCount >= 10 then
						game.state = States['wait'](
							game,
							1,
							nil,
							function ()
								game:play(true, false)
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
