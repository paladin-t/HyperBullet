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
		['offset'] = 8,
		['shape'] = {
			['type'] = 'circle',
			['r'] = 8
		}
	},
	['pistol'] = {
		['name'] = 'Pistol',
		['atk'] = 1,
		['recoil'] = 0.1,
		['capacity'] = 120,
		['interval'] = 0.25,
		['offset'] = 8
	}
}
