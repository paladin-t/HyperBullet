--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Weapons = {
	['knife'] = {
		['name'] = 'Knife',
		['atk'] = 1,
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
		['atk'] = 1,
		['recoil'] = 0,
		['capacity'] = 120,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8
	},
	['revolver'] = {
	},
	['shotgun'] = {
		['name'] = 'Shotgun',
		['atk'] = 1,
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
		['atk'] = 1,
		['recoil'] = 0.05,
		['capacity'] = 120,
		['interval'] = 0.35,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 8
	},
	['laser'] = {
	}
}
