--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Heroes = {
	['hero'] = {
		['resource'] = Resources.load('hero.spr'),
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['move_speed'] = 100
	}
}
