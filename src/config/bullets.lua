--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Bullets = {
	['pistol'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullet.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10),
		['move_speed'] = 100,
		['lifetime'] = 10,
		['penetrable'] = false
	},
	['revolver'] = {
	},
	['shotgun'] = {
		['resource'] = {
			['type'] = 'lines',
			['count'] = 5, ['angle'] = math.pi * 0.01,
			['color'] = Color.new(0, 0, 0)
		},
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10),
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
		['box'] = Recti.byXYWH(3, 3, 10, 10),
		['move_speed'] = 200,
		['lifetime'] = 10,
		['penetrable'] = false
	},
	['laser'] = {
	}
}
