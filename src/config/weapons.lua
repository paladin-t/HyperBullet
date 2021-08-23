--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Weapons = {
	['knife'] = {
		['class'] = 'Melee',
		['name'] = 'Knife',
		['entry'] = 'assets/sprites/objects/knife.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['pre_interval'] = 0.05, ['post_interval'] = 0.05,
		['interval'] = 0.15,
		['throwing_speed'] = 550, ['throwing_interval'] = nil,
		['offset'] = 8,
		['shape'] = {
			['type'] = 'circle',
			['r'] = 8
		}
	},

	['pistol'] = {
		['class'] = 'Gun',
		['name'] = 'Pistol',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 40,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['dual'] = false
	},
	['dual_pistols'] = {
		['class'] = 'Gun',
		['name'] = 'Dual Pistols',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['dual'] = true
	},
	['shotgun'] = {
		['class'] = 'Gun',
		['name'] = 'Shotgun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['dual'] = false
	},
	['submachine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Submachine Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 50,
		['interval'] = 0.15,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['dual'] = false
	},
	['machine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Machine Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.25,
		['capacity'] = 60,
		['interval'] = 0.05,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['dual'] = false
	},
	['rifle'] = {
		['class'] = 'Gun',
		['name'] = 'Rifle',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.75,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['dual'] = false
	},
	['laser'] = {
		['class'] = 'Gun',
		['name'] = 'Laser',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 35,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['dual'] = false
	},
	['disc_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Disc Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 25,
		['interval'] = 0.45,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['dual'] = false
	},
	['mines'] = {
		['class'] = 'Gun',
		['name'] = 'Mines',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 5,
		['interval'] = 0.55,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['dual'] = false
	}
}
