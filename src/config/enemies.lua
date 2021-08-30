--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Enemies = {
	['enemy1_chase_knife'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'knife',
		['score'] = 10
	},
	['enemy1_besiege_knife'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'besiege', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'knife',
		['score'] = 10
	},
	['enemy1_chase_pistol'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'pistol',
		['score'] = 10
	},
	['enemy1_chase_dual_pistols'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'dual_pistols',
		['score'] = 10
	},
	['enemy1_chase_shotgun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'shotgun',
		['score'] = 10
	},
	['enemy1_chase_submachine_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'submachine_gun',
		['score'] = 10
	},
	['enemy1_chase_machine_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'machine_gun',
		['score'] = 10
	},
	['enemy1_pass_by_rifle'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'pass_by', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'rifle',
		['score'] = 10
	},
	['enemy1_pass_by_laser'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'pass_by', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'laser',
		['score'] = 10
	},
	['enemy1_chase_disc_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'disc_gun',
		['score'] = 10
	},
	['enemy1_chase_mines'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'mines',
		['score'] = 10
	}
}
