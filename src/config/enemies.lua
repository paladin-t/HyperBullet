--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Enemies = {
	['enemy1_chase_pistol'] = {
		['resource'] = Resources.load('assets/sprites/characters/enemy1.spr'),
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 80,
		['weapon'] = 'pistol',
		['score'] = 10
	}
}
