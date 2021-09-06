--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Bullets = {
	['pistol'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/pistol.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 400,
		['lifetime'] = 3,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 1, ['height'] = 1,
			['color'] = Color.new(33, 3, 5)
		}
	},
	['dual_pistols'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/dual_pistols.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 400,
		['lifetime'] = 3,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 1, ['height'] = 1,
			['color'] = Color.new(33, 3, 5)
		}
	},
	['shotgun'] = {
		['resource'] = {
			['type'] = 'sprites',
			['count'] = 5, ['angle'] = math.pi * 0.015,
			['resource'] = Resources.load('assets/sprites/objects/bullets/shotgun.spr')
		},
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = Recti.byXYWH(-6, -6, 28, 28),
		['move_speed'] = 300,
		['lifetime'] = 0.5,
		['penetrable'] = true,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 2, ['height'] = 1,
			['color'] = Color.new(200, 3, 5)
		}
	},
	['submachine_gun'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/submachine_gun.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 300,
		['lifetime'] = 3,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 2, ['height'] = 1,
			['color'] = Color.new(33, 3, 5)
		}
	},
	['machine_gun'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/machine_gun.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 300,
		['lifetime'] = 3,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 2, ['height'] = 1,
			['color'] = Color.new(33, 3, 5)
		}
	},
	['rifle'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/rifle.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 600,
		['lifetime'] = 2,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = {
			['type'] = 'rect',
			['width'] = 2, ['height'] = 1,
			['color'] = Color.new(33, 3, 5)
		}
	},
	['laser'] = {
		['resource'] = {
			['type'] = 'line',
			['color'] = Color.new(255, 0, 0)
		},
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 1500,
		['lifetime'] = 2,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = false,
		['shell_case'] = nil
	},
	['disc_gun'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/disc_gun.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16), ['max_box'] = nil,
		['move_speed'] = 200,
		['lifetime'] = 2,
		['penetrable'] = false,
		['bouncy'] = true,
		['explosive'] = false,
		['shell_case'] = nil
	},
	['mines'] = {
		['resource'] = Resources.load('assets/sprites/objects/bullets/mines.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10), ['max_box'] = nil,
		['move_speed'] = 200,
		['lifetime'] = 0.75,
		['penetrable'] = false,
		['bouncy'] = false,
		['explosive'] = true,
		['shell_case'] = nil
	}
}
