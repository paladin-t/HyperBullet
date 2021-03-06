--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

-- Usage:
--   press W, A, S, D on keyboard to move;
--   press R or MMB to pick up a weapon, F or RMB to throw;
--   move mouse to look around, LMB to attack (with weapon equipped).

require 'libs/beInput/beInput'
require 'libs/beParticles/beParticles'
require 'libs/beGUI/beGUI'

require 'utils'
require 'class'
require 'co'
require 'tween'
require 'stack'
require 'probabilistic'
require 'event'
require 'object'
require 'camera'
require 'pool'

require 'config/audio'
require 'config/bullets'
require 'config/weapons'
require 'config/armours'
require 'config/behaviours'
require 'config/enemies'
require 'config/hero'
require 'config/environments'
require 'config/scenes'
require 'config/tutorials'
require 'characters/character'
require 'characters/enemy'
require 'characters/hero'
require 'objects/weapon'
require 'objects/melee'
require 'objects/gun'
require 'objects/armour'
require 'objects/body_armour'
require 'objects/bullet'
require 'objects/mine'
require 'objects/environment'
require 'objects/corpse'
require 'effects/painter'
require 'effects/clip'
require 'effects/shell_case'
require 'effects/blood'
require 'effects/tips'
require 'effects/text'
require 'states'
require 'game'

--[[
Constant.
]]

DEBUG                = false and Debug.available -- Enable for debug.
DEBUG_SHOW_WIREFRAME = DEBUG and false           -- Enable to show wireframes.
DEBUG_IMMORTAL       = DEBUG and false           -- Enable to make the hero unkillable.
DEBUG_PAUSE_SPAWNING = DEBUG and false           -- Enable to pause enemy spawning.

FONT_TITLE_TEXT      = Font.new('assets/fonts/college.ttf', 48)
FONT_SUBTITLE_TEXT   = Font.new('assets/fonts/college.ttf', 24)
FONT_SMALL_TEXT      = Font.new('assets/fonts/ascii 4x6.png', Vec2.new(4, 6))
FONT_NORMAL_TEXT     = Font.new('assets/fonts/ascii 8x8.png', Vec2.new(8, 8))

COLOR_NEON_TEXT      = { Color.new(10, 191, 150), Color.new(235, 117, 206) }
COLOR_BLEEDING_TEXT  = { Color.new(226, 114, 196), Color.new(203, 94, 41) }
COLOR_CLEAR_TEXT     = Color.new(200, 220, 210)
COLOR_INVERT_TEXT    = Color.new(30, 30, 30)
COLOR_SHADOW         = Color.new(0, 0, 0, 100)

Canvas.main:resize(DEBUG and 640 or 0, 360)

--[[
Variables.
]]

local game = nil

--[[
Functions.
]]

function quit()
	game:save()
end

function setup()
	beParticles.setup()
	game = Game.new(Coroutine.new())
		:load()
		:setup()
end

function update(delta)
	delta = math.min(delta, 0.02)
	beInput.update(delta)
	beParticles.update_time()
	game:update(delta)
end
