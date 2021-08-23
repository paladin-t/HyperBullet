--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Weapons = {
	['knife'] = {
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
		['name'] = 'Pistol',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 120,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8
	},
	['dual_pistols'] = {
	},
	['revolver'] = {
	},
	['shotgun'] = {
		['name'] = 'Shotgun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 120,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8
	},
	['submachine_gun'] = {
	},
	['machine_gun'] = {
	},
	['rifle'] = {
		['name'] = 'Rifle',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.05,
		['capacity'] = 120,
		['interval'] = 0.35,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 8
	},
	['laser'] = {
	},
	['disc_gun'] = {
	}
}
