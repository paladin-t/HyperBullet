--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Enemies = {
	['enemy1_pass_by_none'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'pass_by', 'look_at' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = nil,
		['armour'] = nil,
		['score'] = 1
	},
	['enemy1_chase_knife'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'knife',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_besiege_knife'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'besiege', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'knife',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_pistol'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'pistol',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_dual_pistols'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'dual_pistols',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_shotgun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'shotgun',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_submachine_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'submachine_gun',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy2_chase_submachine_gun_body_armour'] = {
		['assets'] = {
			'assets/sprites/characters/enemy2.spr',
			'assets/sprites/characters/legs2.spr',
			'assets/sprites/characters/enemy2_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 80,
		['weapon'] = 'submachine_gun',
		['armour'] = 'body_armour',
		['score'] = 20
	},
	['enemy1_chase_machine_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'machine_gun',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy2_chase_machine_gun_body_armour'] = {
		['assets'] = {
			'assets/sprites/characters/enemy2.spr',
			'assets/sprites/characters/legs2.spr',
			'assets/sprites/characters/enemy2_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 80,
		['weapon'] = 'machine_gun',
		['armour'] = 'body_armour',
		['score'] = 20
	},
	['enemy1_pass_by_rifle'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'pass_by', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'rifle',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_pass_by_laser'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'pass_by', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'laser',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_disc_gun'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'disc_gun',
		['armour'] = nil,
		['score'] = 10
	},
	['enemy1_chase_mines'] = {
		['assets'] = {
			'assets/sprites/characters/enemy1.spr',
			'assets/sprites/characters/legs1.spr',
			'assets/sprites/characters/enemy1_dead.spr'
		},
		['hp'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['behaviours'] = { 'chase', 'look_at', 'attack' },
		['look_at_target'] = 'hero',
		['move_speed'] = 130,
		['weapon'] = 'mines',
		['armour'] = nil,
		['score'] = 10
	}
}
