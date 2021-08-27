--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local function refreshParticle(emitter)
	local x, y = nil, nil

	return function (self, that, delta)
		if x == nil then
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
		},
		['effect'] = nil
	},

	['pistol'] = {
		['class'] = 'Gun',
		['name'] = 'Pistol',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 40,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 10)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 350, 20)
			beParticles.ps_set_angle(emitter, angle_ - 2, 4)
			beParticles.ps_set_life(emitter, 0.5, 1)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.8
		end,
		['dual'] = false
	},
	['dual_pistols'] = {
		['class'] = 'Gun',
		['name'] = 'Dual Pistols',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 10)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 350, 20)
			beParticles.ps_set_angle(emitter, angle_ - 2, 4)
			beParticles.ps_set_life(emitter, 0.5, 1)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.8
		end,
		['dual'] = true
	},
	['shotgun'] = {
		['class'] = 'Gun',
		['name'] = 'Shotgun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 20)
			beParticles.ps_set_size(emitter, 0, 2, 0, 2)
			beParticles.ps_set_speed(emitter, 15, 250, 20)
			beParticles.ps_set_angle(emitter, angle_ - 7, 14)
			beParticles.ps_set_life(emitter, 0.5, 1)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(255, 0,   77,  255),
					Color.new(255, 163, 0,   255),
					Color.new(255, 236, 39,  255),
					Color.new(95,  87,  79,  255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 1
		end,
		['dual'] = false
	},
	['submachine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Submachine Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 50,
		['interval'] = 0.15,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 550, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['machine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Machine Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.25,
		['capacity'] = 60,
		['interval'] = 0.05,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 20)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 550, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['rifle'] = {
		['class'] = 'Gun',
		['name'] = 'Rifle',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.75,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 5)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 550, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['laser'] = {
		['class'] = 'Gun',
		['name'] = 'Laser',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 35,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			return nil, nil
		end,
		['dual'] = false
	},
	['disc_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Disc Gun',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 25,
		['interval'] = 0.45,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 4, 15)
			beParticles.ps_set_size(emitter, 1, 0, 1, 0)
			beParticles.ps_set_speed(emitter, 15, 250, 20)
			beParticles.ps_set_angle(emitter, angle_ - 1, 2)
			beParticles.ps_set_life(emitter, 0.5, 0.3)
			beParticles.ps_set_colours(
				emitter,
				{
					Color.new(29,  43,  83,  255),
					Color.new(131, 118, 156, 255),
					Color.new(194, 195, 199, 255)
				}
			)
			emitter.refresh = refreshParticle(emitter)

			return emitter, 0.3
		end,
		['dual'] = false
	},
	['mines'] = {
		['class'] = 'Gun',
		['name'] = 'Mines',
		['entry'] = 'assets/sprites/objects/gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursor.spr'),
		['atk'] = 1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 5,
		['interval'] = 0.55,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.2,
		['offset'] = 8,
		['effect'] = function (this, x, y, dir, angle)
			return nil, nil
		end,
		['dual'] = false
	}
}
