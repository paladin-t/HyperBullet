--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local SAVE_FILE = Path.combine(Path.writableDirectory, 'hyper_bullet.txt')
local HUD_HEIGHT = 32

Game = class({
	co = nil,
	bgm = nil,
	map = nil,
	sceneWidth = 0, sceneHeight = 0,
	isHeroBlocked = nil, isEnvironmentBlocked = nil,
	raycaster = nil,
	camera = nil,

	hero = nil,
	objects = nil, pending = nil,
	backgroundEffects = nil, foregroundEffects = nil,
	enemyCount = 0,
	pool = nil,

	room = nil,
	level = 1,
	killingCount = 0,
	score = 0,
	highscore = 0, newHighscore = false,
	state = nil,

	_blankImage = nil, _cursor = nil,
	_clearColor = nil, _hudColor = nil,

	ctor = function (self, co, isHeroBlocked, isEnvironmentBlocked)
		self.co = co
		self.bgm = Resources.load('assets/bgms/bgm.ogg', Music)
		volume(1, 0.5)
		--play(self.bgm, true, 2)
		self.isHeroBlocked = isHeroBlocked
		self.isEnvironmentBlocked = isEnvironmentBlocked
		self.raycaster = Raycaster.new()
		self.raycaster.tileSize = Vec2.new(16, 16)
		self.camera = Camera.new()

		self._blankImage = Image.new()
		self._blankImage:resize(1, 1)
		self._blankImage:set(0, 0, Color.new(255, 255, 255, 1))
		self._clearColor, self._hudColor =
			Color.new(80, 80, 80), Color.new(30, 30, 30)

		self.state = States['title'](self)
	end,

	-- Adds the specific number of killing to the current game.
	addKilling = function (self, num)
		if num == nil then
			num = 1
		end
		self.killingCount = self.killingCount + num

		if self.room.finished(self) then
			self:start(true, false)
		end

		return self
	end,
	-- Adds the specific number of score to the current game.
	addScore = function (self, num)
		self.score = self.score + num
		if self.score > self.highscore then
			self.highscore = self.score
			self.newHighscore = true
		end

		if self.room.finished(self) then
			self:start(true, false)
		end

		return self
	end,

	-- Loads game data.
	load = function (self)
		local file = File.new()
		if file:open(SAVE_FILE, Stream.Read) then
			local score = file:readLine()
			self.highscore = tonumber(score)
			file:close()
		end

		return self
	end,
	-- Saves game data.
	save = function (self)
		local file = File.new()
		if file:open(SAVE_FILE, Stream.Write) then
			file:writeLine(tostring(self.highscore))
			file:close()
		end

		return self
	end,

	-- Loads initial resources, setups environments.
	setup = function (self)
		self:start(false, true)

		return self
	end,

	-- Starts a new game.
	start = function (self, toGame, restart)
		-- Pick a room.
		if restart then
			self.level = 1
		else
			self.level = self.level + 1
		end
		local types = flat(Scenes, function (k, _)
			return k
		end)
		local type_ = any(types)
		self.room = Scenes[type_](self.level)

		-- Load map.
		self.map = self.room.map
		self.sceneWidth, self.sceneHeight =
			self.map.width * 16, self.map.height * 16

		-- Initialize objects.
		self.objects, self.pending = { }, { }
		self.backgroundEffects, self.foregroundEffects = { }, { }
		self.enemyCount = 0
		self.pool = Pool.new()

		-- Load hero.
		if restart then
			local cfg = Heroes['hero']
			local hero = Hero.new(
				cfg['resource'],
				cfg['box'],
				self.isHeroBlocked,
				{
					game = self,
					hp = cfg['hp'],
					moveSpeed = cfg['move_speed']
				}
			)
			local pos = Vec2.new(self.sceneWidth * 0.5, self.sceneHeight * 0.5)
			hero.x, hero.y = pos.x, pos.y
			hero:reset()
			table.insert(self.objects, hero)

			local fx = self.pool:effect('appearance', pos.x, pos.y, self)
			table.insert(self.foregroundEffects, fx)

			hero:on('dead', function (sender, _)
				self.state = States['gameover'](self)
				self.co:clear()

				local fx = self.pool:effect('disappearance', sender.x, sender.y, self)
				table.insert(self.foregroundEffects, fx)
			end)

			self.hero = hero
		else
			local hero = self.hero
			local pos = Vec2.new(self.sceneWidth * 0.5, self.sceneHeight * 0.5)
			hero.x, hero.y = pos.x, pos.y
			table.insert(self.objects, hero)
		end

		-- Initialize states.
		self.killingCount = 0
		if restart then
			self.score = 0
		end
		if toGame then
			self.state = States['next'](self)
		end
		self.camera:reset()

		-- Start a wave.
		if toGame then
			local wave = coroutine.create(self.room.wave)
			self.co
				:clear()
				:start(
					wave,
					self, self.isEnvironmentBlocked
				)
		end

		-- Finish.
		collectgarbage()
		Resources.collect()

		return self
	end,

	-- The main loop.
	update = function (self, delta)
		-- Prepare.
		cls(self._clearColor)
		local hero = self.hero

		-- Update all coroutines.
		self.co:update(delta)

		-- Game logic.
		local canvasWidth, canvasHeight = Canvas.main:size()
		local screenHalfWidth, screenHalfHeight = canvasWidth * 0.5, canvasHeight * 0.5
		local targetX, targetY = nil, nil
		if canvasWidth >= self.sceneWidth + 60 then
			local paddingX, paddingY =
				(canvasWidth - self.sceneWidth) * 0.5, 20
			targetX, targetY =
				-paddingX,
				clamp(hero.y - screenHalfHeight + HUD_HEIGHT * 0.5, -paddingY, paddingY) - HUD_HEIGHT
		else
			local paddingX, paddingY =
				30, 20
			targetX, targetY =
				clamp(hero.x - screenHalfWidth, -paddingX, self.sceneWidth - canvasWidth + paddingX),
				clamp(hero.y - screenHalfHeight + HUD_HEIGHT * 0.5, -paddingY, paddingY) - HUD_HEIGHT
		end
		local cameraX, cameraY = self.camera:get()
		if cameraX == nil or cameraY == nil then
			self.camera:set(targetX, targetY)
		else
			local diffX, diffY =
				targetX - cameraX,
				targetY - cameraY
			if diffX ~= 0 or diffY ~= 0 then
				self.camera
					:set(
						math.abs(diffX) >= 0.5 and cameraX + diffX * 0.2 or targetX,
						math.abs(diffY) >= 0.5 and cameraY + diffY * 0.2 or targetY
					)
			end
		end

		local x, y, lmb, rmb, mmb = mouse()
		if self.state.playing then
			if key(beInput.KeyCode.W) then
				hero:moveUp(delta)
			elseif key(beInput.KeyCode.S) then
				hero:moveDown(delta)
			end
			if key(beInput.KeyCode.A) then
				hero:moveLeft(delta)
			elseif key(beInput.KeyCode.D) then
				hero:moveRight(delta)
			end
			local cameraX, cameraY = self.camera:get()
			hero:lookAt(x + cameraX, y + cameraY)
			if lmb then
				hero:attack(1)
			end
			if mmb or keyp(beInput.KeyCode.R) then
				hero:pick()
			elseif rmb or keyp(beInput.KeyCode.F) then
				hero:throw()
			end
		end

		-- Update objects and draw everything.
		self.camera:prepare(delta)
		map(self.map, 0, 0)
		for i, v in ipairs(self.objects) do
			v:behave(delta, hero)
		end
		for _, v in ipairs(self.backgroundEffects) do
			v:update(delta)
		end
		for _, v in ipairs(self.objects) do
			v:update(delta)
		end
		for _, v in ipairs(self.foregroundEffects) do
			v:update(delta)
		end
		self.camera:finish(delta)

		self
			:_removeDeadEffects()
			:_removeDeadObjects()
			:_commitPendingObjects()

		self
			:_mouse(x, y)
			:_hud(delta)

		self.state:update(delta)
	end,

	-- Removes all dead effects from the effects collections.
	_removeDeadEffects = function (self)
		local dead = nil
		for i = 1, #self.backgroundEffects do
			local obj = self.backgroundEffects[i]
			if obj:dead() then
				if dead == nil then
					dead = { }
				end
				table.insert(dead, 1, i)
			end
		end
		if dead ~= nil then
			for _, idx in ipairs(dead) do
				table.remove(self.backgroundEffects, idx)
			end
		end

		dead = nil
		for i = 1, #self.foregroundEffects do
			local obj = self.foregroundEffects[i]
			if obj:dead() then
				if dead == nil then
					dead = { }
				end
				table.insert(dead, 1, i)
			end
		end
		if dead ~= nil then
			for _, idx in ipairs(dead) do
				table.remove(self.foregroundEffects, idx)
			end
		end

		return self
	end,
	-- Removes all dead objects from the objects collection.
	_removeDeadObjects = function (self)
		local weaponCount, firstWeapon = 0, nil
		local dead = nil
		for i = 1, #self.objects do
			local obj = self.objects[i]
			if obj:dead() then
				if dead == nil then
					dead = { }
				end
				table.insert(dead, 1, i)
			elseif obj.group == 'weapon' then
				weaponCount = weaponCount + 1
				if firstWeapon == nil and obj:disappearable() then
					firstWeapon = obj
				end
			end
		end
		if weaponCount > 2 and firstWeapon ~= nil then
			firstWeapon:disappear()
		end
		if dead ~= nil then
			for _, idx in ipairs(dead) do
				table.remove(self.objects, idx)
			end
		end

		return self
	end,
	-- Commits all pending objects to the objects collection.
	_commitPendingObjects = function (self)
		for i = 1, #self.pending do
			local obj = self.pending[i]
			table.insert(self.objects, obj)
		end
		clear(self.pending)

		return self
	end,

	-- Refreshes and draws front signt or regular mouse cursor.
	_mouse = function (self, x, y)
		-- Prepare.
		local hero = self.hero
		local weapon = hero:weapon()
		local target = nil
		if self.state.playing then
			if weapon == nil or weapon.cursor == nil then
				target = nil
			else
				target = self._blankImage
			end
		else
			target = nil
		end

		-- Refresh the mouse cursor.
		if target ~= self._cursor then
			self._cursor = target
			Application.setCursor(self._cursor)
		end

		-- Draw the cursor.
		if self._cursor ~= nil then
			spr(weapon.cursor, x - weapon.cursor.width * 0.5, y - weapon.cursor.height * 0.5)
		end

		-- Finish.
		return self
	end,
	-- Draws the HUD.
	_hud = function (self, delta)
		-- Prepare.
		local canvasWidth, canvasHeight = Canvas.main:size()
		local hero = self.hero
		local weapon = hero:weapon()
		clip(0, 0, canvasWidth, HUD_HEIGHT)
		rect(0, 0, canvasWidth, HUD_HEIGHT, true, self._hudColor)

		-- Information.
		font(NORMAL_FONT)

		text('LEVEL', 10, 7, Color.new(200, 220, 210))
		text(self.level, 70, 7, Color.new(200, 220, 210))
		text('WEAPON', 10, 20, Color.new(200, 220, 210))
		if weapon == nil then
			text('NONE', 70, 20, Color.new(200, 220, 210))
		else
			local txt = weapon:name()
			local cap = weapon:capacity()
			if cap ~= nil then
				txt = txt .. ' [' .. tostring(cap) .. ']'
			end
			text(txt, 70, 20, Color.new(200, 220, 210))
		end

		local scoreWidth, _ = measure(self.score, NORMAL_FONT)
		local highscoreWidth, _ = measure(self.highscore, NORMAL_FONT)
		local maxScoreWidth = math.max(scoreWidth, highscoreWidth)
		local textWidth, _ = measure('HIGHSCORE', NORMAL_FONT)
		text('HIGHSCORE', canvasWidth - textWidth - maxScoreWidth - 10 - 8, 7, Color.new(200, 220, 210))
		text(self.highscore, canvasWidth - maxScoreWidth - 10, 7, self.newHighscore and Color.new(255, 100, 100) or Color.new(200, 220, 210))
		textWidth, _ = measure('SCORE', NORMAL_FONT)
		text('SCORE', canvasWidth - textWidth - maxScoreWidth - 10 - 8, 20, Color.new(200, 220, 210))
		text(self.score, canvasWidth - maxScoreWidth - 10, 20, Color.new(200, 220, 210))

		font(nil)

		-- Finish.
		clip(0, HUD_HEIGHT, canvasWidth, canvasHeight - HUD_HEIGHT)

		return self
	end
})
