--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

-- Usage:
--   press W, A, S, D on keyboard to move;
--   press R or MMB to pick up a weapon, F or RMB to throw;
--   move mouse to look around, LMB to attack (with weapon equipped).

require 'libs/beInput/beInput'
require 'libs/beGUI/beGUI'

require 'utils'
require 'class'
require 'co'
require 'probabilistic'
require 'event'
require 'object'
require 'character'
require 'camera'
require 'pool'

require 'config/bullets'
require 'config/weapons'
require 'config/behaviours'
require 'config/enemies'
require 'config/hero'
require 'config/scenes'
require 'config/states'
require 'characters/hero'
require 'characters/enemy'
require 'objects/weapon'
require 'objects/melee'
require 'objects/gun'
require 'objects/bullet'
require 'objects/mine'
require 'game'

--[[
Constant.
]]

DEBUG = true -- Enable to show collision boxes.
IMMORTAL = false -- Enable to make the hero unkillable.
PAUSE_SPAWNING = false -- Enable to pause enemy spawning.

TITLE_FONT = Font.new('assets/fonts/college.ttf', 30)
NORMAL_FONT = Font.new('assets/fonts/ascii 8x8.png', Vec2.new(8, 8))

Canvas.main:resize(0, 320)

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
	local WALKABLE_CEL = 97
	local BORDER_CEL = -1
	game = Game.new(
		Coroutine.new(),
		function (pos)
			local cel = mget(game.map, pos.x, pos.y)

			return cel ~= WALKABLE_CEL
		end,
		function (pos)
			local cel = mget(game.map, pos.x, pos.y)

			return cel ~= WALKABLE_CEL and cel ~= BORDER_CEL
		end
	)
		:load()
		:setup()
end

function update(delta)
	delta = math.min(delta, 0.02)

	beInput.update(delta)

	game:update(delta)
end
