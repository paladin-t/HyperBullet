--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local function refreshParticles(emitter)
	local x, y = nil, nil

	return function (self, that, delta)
		if x == nil --[[ or y == nil ]] then
			x, y = that.x, that.y
		end
		local diffX, diffY = that.x - x, that.y - y
		x, y = that.x, that.y
		for _, particle in ipairs(emitter.particles) do
			particle.pos.x, particle.pos.y =
				particle.pos.x + diffX, particle.pos.y + diffY
		end
	end
end

Weapons = {
	['knife'] = {
		['class'] = 'Melee',
		['name'] = 'Knife',
		['entry'] = 'assets/sprites/objects/weapon_knife.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = nil,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['pre_interval'] = 0.05, ['post_interval'] = 0.05,
		['interval'] = 0.15,
		['throwing_speed'] = 550, ['throwing_interval'] = nil,
		['offset'] = 12,
		['shape'] = {
			['type'] = 'circle',
			['r'] = 8
		},
		['effect'] = nil
	},

	['pistol'] = {
		['class'] = 'Gun',
		['name'] = 'Pistol',
		['entry'] = 'assets/sprites/objects/weapon_pistol.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 40,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 45, 60, 20)
			beParticles.ps_set_angle(emitter, angle_ - 2, 4)
			beParticles.ps_set_life(emitter, 0.5, 0.8)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 143, 255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)

			return emitter, 0.8
		end,
		['dual'] = false
	},
	['dual_pistols'] = {
		['class'] = 'Gun',
		['name'] = 'Dual Pistols',
		['entry'] = 'assets/sprites/objects/weapon_dual_pistols.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 45, 60, 20)
			beParticles.ps_set_angle(emitter, angle_ - 2, 4)
			beParticles.ps_set_life(emitter, 0.5, 0.8)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 143, 255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)

			return emitter, 0.8
		end,
		['dual'] = true
	},
	['shotgun'] = {
		['class'] = 'Gun',
		['name'] = 'Shotgun',
		['entry'] = 'assets/sprites/objects/weapon_shotgun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 20)
			beParticles.ps_set_size(emitter, 0, 2, 0, 2)
			beParticles.ps_set_speed(emitter, 45, 100, 20)
			beParticles.ps_set_angle(emitter, angle_ - 7, 14)
			beParticles.ps_set_life(emitter, 0.5, 1)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(255, 0,   77,  255),
					Color.new(255, 163, 0,   255),
					Color.new(255, 236, 39,  200),
					Color.new(95,  87,  79,  128)
				}
			)
			emitter.refresh = refreshParticles(emitter)

			return emitter, 1
		end,
		['dual'] = false
	},
	['submachine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Submachine Gun',
		['entry'] = 'assets/sprites/objects/weapon_submachine_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.06,
		['capacity'] = 45,
		['interval'] = 0.15,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 50, 150, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 143, 255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 128),
					Color.new(224, 225, 229, 64)
				}
			)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['machine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Machine Gun',
		['entry'] = 'assets/sprites/objects/weapon_machine_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.07,
		['capacity'] = 55,
		['interval'] = 0.05,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 40)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 50, 150, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 143, 255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 128),
					Color.new(224, 225, 229, 64)
				}
			)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['rifle'] = {
		['class'] = 'Gun',
		['name'] = 'Rifle',
		['entry'] = 'assets/sprites/objects/weapon_rifle.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.75,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 50, 80, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 143, 255),
					Color.new(131, 118, 156, 255),
					Color.new(255, 236, 39,  200),
					Color.new(95,  87,  79,  128)
				}
			)
			emitter.refresh = refreshParticles(emitter)

			return emitter, 0.6
		end,
		['dual'] = false
	},
	['laser'] = {
		['class'] = 'Gun',
		['name'] = 'Laser',
		['entry'] = 'assets/sprites/objects/weapon_laser.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 25,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			return nil, nil
		end,
		['dual'] = false
	},
	['disc_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Disc Gun',
		['entry'] = 'assets/sprites/objects/weapon_disc_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.45,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 84, 60)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 50, 100, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(89,  103, 123, 255),
					Color.new(101, 118, 156, 255),
					Color.new(124, 165, 199, 200),
					Color.new(104, 185, 219, 128)
				}
			)

			return emitter, 0.6
		end,
		['dual'] = false
	},
	['mines'] = {
		['class'] = 'Gun',
		['name'] = 'Mines',
		['entry'] = 'assets/sprites/objects/weapon_mines.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['accuracy'] = 0.2,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 5,
		['interval'] = 0.55,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['effect'] = nil,
		['dual'] = false
	}
}
