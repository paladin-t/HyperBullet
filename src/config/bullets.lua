--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Bullets = {
	['pistol'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullet.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 100,
		['lifetime'] = 10,
		['penetrable'] = false
	},
	['dual_pistols'] = {
	},
	['revolver'] = {
	},
	['shotgun'] = {
		['resource'] = {
			['type'] = 'lines',
			['count'] = 5, ['angle'] = math.pi * 0.02,
			['color'] = Color.new(0, 0, 0)
		},
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = Recti.byXYWH(-6, -6, 28, 28),
		['move_speed'] = 200,
		['lifetime'] = 0.5,
		['penetrable'] = true
	},
	['submachine_gun'] = {
	},
	['machine_gun'] = {
	},
	['rifle'] = {
		['resource'] = {
			['type'] = 'line',
			['color'] = Color.new(0, 0, 0)
		},
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 200,
		['lifetime'] = 10,
		['penetrable'] = false
	},
	['laser'] = {
	},
	['disc_gun'] = {
	}
}
