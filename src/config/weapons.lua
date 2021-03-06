--[[
A top-down action game made with Bitty Engine

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
		local diffX, diffY = (that.x - x) * 0.3, (that.y - y) * 0.3
		x, y = that.x, that.y
		for _, particle in ipairs(emitter.particles) do
			particle.pos.x, particle.pos.y =
				particle.pos.x + diffX, particle.pos.y + diffY
		end
	end
end

local function stopEmitter(emitter, interval)
	local ticks = 0

	return function (self, that, delta)
		if ticks == nil then
			return
		end
		ticks = ticks + delta
		if ticks >= interval then
			emitter:stop_emit()
			ticks = nil
		end
	end
end

Weapons = {
	['knife'] = {
		['class'] = 'Melee',
		['name'] = 'Knife',
		['acronym'] = 'K',
		['entry'] = 'assets/sprites/objects/weapons/knife.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/knife.spr'),
		['atk'] = 1,
		['accuracy'] = nil,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['blade'] = true,
		['pre_interval'] = 0.05, ['post_interval'] = 0.05,
		['interval'] = 0.15,
		['throwing_speed'] = 550, ['throwing_interval'] = nil,
		['offset'] = 12,
		['dual'] = false,
		['shape'] = {
			['type'] = 'circle',
			['r'] = 8
		},
		['effect'] = nil,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = { 'pick/knife1', 'pick/knife2' },
			['attack'] = { 'attack/knife1', 'attack/knife2' }
		}
	},

	['pistol'] = {
		['class'] = 'Gun',
		['name'] = 'Pistol',
		['acronym'] = 'P',
		['entry'] = 'assets/sprites/objects/weapons/pistol.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/pistol.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 40,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = false,
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
			emitter.refresh = stopEmitter(emitter, 0.5)

			return emitter, 0.8
		end,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm2',
			['attack'] = { 'attack/pistol1', 'attack/pistol2', 'attack/pistol3' }
		}
	},
	['dual_pistols'] = {
		['class'] = 'Gun',
		['name'] = 'Dual Pistols',
		['acronym'] = 'D',
		['entry'] = 'assets/sprites/objects/weapons/dual_pistols.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/dual_pistols.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.25,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = true,
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
			emitter.refresh = stopEmitter(emitter, 0.5)

			return emitter, 0.8
		end,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm2',
			['attack'] = { 'attack/pistol1', 'attack/pistol2', 'attack/pistol3' }
		}
	},
	['shotgun'] = {
		['class'] = 'Gun',
		['name'] = 'Shotgun',
		['acronym'] = 'S',
		['entry'] = 'assets/sprites/objects/weapons/shotgun.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/shotgun.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['dual'] = false,
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
			emitter.refresh = chain(
				refreshParticles(emitter),
				stopEmitter(emitter, 0.5)
			)

			return emitter, 1
		end,
		['shocking'] = {
			['interval'] = 0.05,
			['amplitude'] = 2
		},
		['sfxs'] = {
			['pick'] = 'pick/firearm3',
			['attack'] = { 'attack/shotgun1', 'attack/shotgun2', 'attack/shotgun3' }
		}
	},
	['submachine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Submachine Gun',
		['acronym'] = 'B',
		['entry'] = 'assets/sprites/objects/weapons/submachine_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/submachine_gun.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.04,
		['capacity'] = 45,
		['interval'] = 0.15,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['dual'] = false,
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
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm4',
			['attack'] = 'attack/submachine_gun1'
		}
	},
	['machine_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Machine Gun',
		['acronym'] = 'M',
		['entry'] = 'assets/sprites/objects/weapons/machine_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/machine_gun.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.04,
		['capacity'] = 55,
		['interval'] = 0.05,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = false,
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
		['shocking'] = {
			['interval'] = 0.05,
			['amplitude'] = 1
		},
		['sfxs'] = {
			['pick'] = 'pick/firearm4',
			['attack'] = { 'attack/machine_gun1', 'attack/machine_gun2', 'attack/machine_gun3' }
		}
	},
	['rifle'] = {
		['class'] = 'Gun',
		['name'] = 'Rifle',
		['acronym'] = 'R',
		['entry'] = 'assets/sprites/objects/weapons/rifle.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/rifle.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0.15,
		['capacity'] = 15,
		['interval'] = 0.75,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = false,
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
			emitter.refresh = chain(
				refreshParticles(emitter),
				stopEmitter(emitter, 0.4)
			)

			return emitter, 0.6
		end,
		['shocking'] = {
			['interval'] = 0.05,
			['amplitude'] = 2
		},
		['sfxs'] = {
			['pick'] = 'pick/firearm1',
			['attack'] = { 'attack/rifle1', 'attack/rifle2', 'attack/rifle3' }
		}
	},
	['laser'] = {
		['class'] = 'Gun',
		['name'] = 'Laser',
		['acronym'] = 'L',
		['entry'] = 'assets/sprites/objects/weapons/laser.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/laser.spr'),
		['atk'] = 1,
		['accuracy'] = 0.1,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 25,
		['interval'] = 0.65,
		['throwing_speed'] = 350, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = false,
		['effect'] = function (this, x, y, dir, angle)
			return nil, nil
		end,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm4',
			['attack'] = { 'attack/laser1', 'attack/laser2' }
		}
	},
	['disc_gun'] = {
		['class'] = 'Gun',
		['name'] = 'Disc Gun',
		['acronym'] = 'D',
		['entry'] = 'assets/sprites/objects/weapons/disc_gun.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/disc_gun.spr'),
		['atk'] = 1,
		['accuracy'] = 0.3,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 20,
		['interval'] = 0.45,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.4,
		['offset'] = 12,
		['dual'] = false,
		['effect'] = function (this, x, y, dir, angle)
			local angle_ = -math.deg(angle)
			local emitter = beParticles.emitter.create(x, y, 8, 20)
			beParticles.ps_set_size(emitter, 0, 2, 0, 2)
			beParticles.ps_set_speed(emitter, 45, 100, 20)
			beParticles.ps_set_angle(emitter, angle_ - 7, 14)
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
			emitter.refresh = stopEmitter(emitter, 0.4)

			return emitter, 0.6
		end,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm3',
			['attack'] = 'attack/disc_gun1'
		}
	},
	['mines'] = {
		['class'] = 'Gun',
		['name'] = 'Mines',
		['acronym'] = 'E',
		['entry'] = 'assets/sprites/objects/weapons/mines.spr',
		['cursor'] = Resources.load('assets/sprites/cursors/mines.spr'),
		['atk'] = 1,
		['accuracy'] = 0.2,
		['box'] = Recti.byXYWH(0, 0, 16, 16),
		['recoil'] = 0,
		['capacity'] = 5,
		['interval'] = 0.55,
		['throwing_speed'] = 450, ['throwing_interval'] = 0.3,
		['offset'] = 12,
		['dual'] = false,
		['effect'] = nil,
		['shocking'] = nil,
		['sfxs'] = {
			['pick'] = 'pick/firearm4',
			['attack'] = 'attack/mines1'
		}
	}
}
