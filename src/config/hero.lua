--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Heroes = {
	['hero1'] = {
		['assets'] = {
			'assets/sprites/characters/hero1.spr',
			'assets/sprites/characters/hero1_legs.spr',
			'assets/sprites/characters/hero1_dead.spr',
			'assets/sprites/characters/hero1_split1.spr',
			'assets/sprites/characters/hero1_split2.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['move_speed'] = 150
	}
}
