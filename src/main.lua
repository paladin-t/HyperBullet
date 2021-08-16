--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

-- Usage:
--   press W, A, S, D on keyboard to move;
--   press R or MMB to pick up a weapon, F or RMB to throw;
--   move mouse to look around, LMB to attack (with weapon equipped).

require 'co'
require 'keycode'

require 'utils'
require 'config/weapons'
require 'config/bullets'
require 'config/enemies'
require 'config/scenes'
require 'characters/hero'
require 'characters/enemy'
require 'objects/melee'
require 'objects/gun'
require 'objects/bullet'
require 'objects/vacuum'

--[[
Constant.
]]

DEBUG = true -- Enable to show collision boxes.
IMMORTAL = false -- Enable to make the hero unkillable.

TITLE_FONT = Font.new('college.ttf', 30)
NORMAL_FONT = Font.new('ascii 8x8.png', Vec2.new(8, 8))

local WALKABLE_CEL = 97
local BORDER_CEL = -1

local SAVE_FILE = Path.combine(Path.writableDirectory, 'hyper_bullet.txt')

--[[
Variables.
]]

local co = nil

local bgm = nil
local bank = nil
local heroSpr = nil

local map_ = nil
local hero = nil
local context = {
	objects = nil, pending = nil,
	enemyCount = 0,
	score = 0,
	highscore = 0,
	newHighscore = false,
	gameover = false,

	-- Loads highscore from file.
	loadHighscore = function (self)
		local file = File.new()
		if file:open(SAVE_FILE, Stream.Read) then
			local score = file:readLine()
			self.highscore = tonumber(score)
			file:close()
		end
	end,
	-- Saves highscore to file.
	saveHighscore = function (self)
		local file = File.new()
		if file:open(SAVE_FILE, Stream.Write) then
			file:writeLine(tostring(self.highscore))
			file:close()
		end
	end,
	-- Adds a number of score.
	addScore = function (self, num)
		self.score = self.score + num
		if self.score > self.highscore then
			self.highscore = self.score
			self.newHighscore = true
		end
	end
}

--[[
Functions.
]]

-- Removes all dead ones from the objects collection.
local function removeDeadObjects()
	local weaponCount, firstWeapon = 0, nil
	local dead = nil
	for i = #context.objects, 1, -1 do
		local obj = context.objects[i]
		if obj:dead() then
			if dead == nil then
				dead = { }
			end
			table.insert(dead, i)
		elseif obj.group == 'weapon' then
			weaponCount = weaponCount + 1
			if firstWeapon == nil then
				firstWeapon = obj
			end
		end
	end

	if weaponCount > 2 and firstWeapon ~= nil then
		firstWeapon:disappear()
	end

	if dead then
		for _, idx in ipairs(dead) do
			table.remove(context.objects, idx)
		end
	end
end

-- Commits all pending objects to the objects collection.
local function commitPendingObjects()
	for i = 1, #context.pending do
		local obj = context.pending[i]
		table.insert(context.objects, obj)
	end
	clear(context.pending)
end

-- Checks whether it's blocked on map at a specific position.
local function isBlocked(pos)
	local cel = mget(map_, pos.x, pos.y)

	return cel ~= WALKABLE_CEL and cel ~= BORDER_CEL
end

-- Starts a new game.
local function start(toGame, pos)
	-- Load map.
	map_ = Resources.load('map1.map')

	-- Load hero.
	context.objects = { }
	context.pending = { }
	hero = Hero.new(
		heroSpr,
		Recti.byXYWH(0, 0, 16, 16),
		isBlocked,
		{
			co = co,
			context = context,
			hp = 1,
			moveSpeed = 100
		}
	)
	hero.x, hero.y = pos.x, pos.y
	hero:reset()
	table.insert(context.objects, hero)

	hero:on('dead', function (sender)
		context.gameover = true
	end)

	-- Generate weapon.
	local weapon = Gun.new(
		Resources.load('gun.spr'),
		Recti.byXYWH(0, 0, 16, 16),
		isBlocked,
		{
			type = 'pistol',
			co = co,
			context = context,
		}
	)
	weapon.x, weapon.y = 130, 130
	table.insert(context.objects, weapon)
	weapon = Melee.new(
		Resources.load('knife.spr'),
		Recti.byXYWH(0, 0, 16, 16),
		isBlocked,
		{
			type = 'knife',
			co = co,
			context = context,
		}
	)
	weapon.x, weapon.y = 350, 190
	table.insert(context.objects, weapon)

	-- Initial states.
	if context.gameover then
		context.enemyCount = 0
		context.score = 0
		context.highscore = 0
		context.newHighscore = false
		context.gameover = false
	end

	-- Start a wave.
	local wave = coroutine.create(Scenes['wave1'](co, context, isBlocked))
	co:start(wave)

	-- Finish.
	collectgarbage()
	Resources.collect()
end

-- Draws the HUD.
local function hud(delta)
	-- Information.
	font(NORMAL_FONT)

	local txt = 'WEAPON'
	text(txt, 10, 300, Color.new(200, 220, 210))
	local weapon = hero:weapon()
	if weapon == nil then
		txt = 'NONE'
		text(txt, 70, 300, Color.new(200, 220, 210))
	else
		txt = weapon:name()
		local cap = weapon:capacity()
		if cap ~= nil then
			txt = txt .. ' [' .. tostring(cap) .. ']'
		end
		text(txt, 70, 300, Color.new(200, 220, 210))
	end

	txt = 'HIGHSCORE'
	text(txt, 344, 295, Color.new(200, 220, 210))
	txt = context.highscore
	text(txt, 430, 295, context.newHighscore and Color.new(255, 100, 100) or Color.new(200, 220, 210))
	txt = 'SCORE'
	text(txt, 380, 308, Color.new(200, 220, 210))
	txt = context.score
	text(txt, 430, 308, Color.new(200, 220, 210))

	font(nil)

	-- Gameover.
	if context.gameover then
		local canvasWidth, canvasHeight = Canvas.main:size()

		font(TITLE_FONT)
		local txt = 'GAME OVER'
		local textWidth, textHeight = measure(txt, TITLE_FONT)
		text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
		text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, Color.new(200, 220, 210))
		font(nil)

		font(NORMAL_FONT)
		txt = 'Press ENTER to restart'
		textWidth, textHeight = measure(txt, NORMAL_FONT)
		text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 + 10, Color.new(0, 0, 0))
		text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 + 10, Color.new(255, 255, 255))
		font(nil)

		if keyp(KeyCode.Return) then -- Return/Enter key.
			context:saveHighscore()
			start(true, Vec2.new(canvasWidth * 0.5, canvasHeight * 0.5))
		end
	end
end

function quit()
	context:saveHighscore()
end

function setup()
	co = Coroutine.new()

	bgm = Resources.load('bgm.ogg', Music)
	volume(1, 0.5)
	--play(bgm, true, 2)

	bank = Resources.load('bank.png')
	heroSpr = Resources.load('hero.spr')

	context:loadHighscore()

	local canvasWidth, canvasHeight = Canvas.main:size()
	start(false, Vec2.new(canvasWidth * 0.5, canvasHeight * 0.5))
end

function update(delta)
	-- Prevent penetrating.
	delta = math.min(delta, 0.02)

	-- Update coroutines.
	co:update(delta)

	-- Game logic.
	if not context.gameover then
		if key(KeyCode.W) then
			hero:moveUp(delta)
		elseif key(KeyCode.S) then
			hero:moveDown(delta)
		end
		if key(KeyCode.A) then
			hero:moveLeft(delta)
		elseif key(KeyCode.D) then
			hero:moveRight(delta)
		end
		local x, y, lmb, rmb, mmb = mouse()
		hero:lookAt(x, y)
		if lmb then
			hero:attack(1)
		end
		if mmb or keyp(KeyCode.R) then
			hero:pick()
		elseif rmb or keyp(KeyCode.F) then
			hero:throw()
		end
	end

	-- Update objects and draw everything.
	map(map_, 0, 0)
	for i, v in ipairs(context.objects) do
		v:behave(delta, hero)
	end
	for _, v in ipairs(context.objects) do
		v:update(delta)
	end
	removeDeadObjects()
	commitPendingObjects()

	hud(delta)
end
