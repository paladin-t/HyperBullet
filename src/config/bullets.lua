--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Bullets = {
	['pistol'] = {
		['resource'] = Resources.load('bullet.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(3, 3, 10, 10),
		['move_speed'] = 200,
		['lifetime'] = 10
	}
}
