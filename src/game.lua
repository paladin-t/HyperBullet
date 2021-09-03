--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local DATE_FILE = Path.combine(Path.writableDirectory, 'hyper_bullet_data.txt')
local CONFIG_FILE = Path.combine(Path.writableDirectory, 'hyper_bullet_config.txt')
local HUD_HEIGHT = 40

Game = class({
	co = nil,
	bgm = nil,
	background = nil, building = nil, foreground = nil,
	backgroundOffsetX = 0, backgroundOffsetY = 0,
	sceneWidth = 0, sceneHeight = 0,
	isHeroBlocked = nil, isEnemyBlocked = nil, isWeaponBlocked = nil, isBulletBlocked = nil,
	raycaster = nil,
	camera = nil,

	hero = nil,
	objects = nil, pending = nil,
	clearColors = nil,
	backgroundEffects = nil, foregroundEffects = nil,
	enemyCount = 0,
	pool = nil,

	room = nil,
	levelIndex = nil, tutorialIndex = nil,
	killingCount = 0,
	score = 0,
	highscore = 0, newHighscore = false,
	state = nil,

	_blankImage = nil, _cursor = nil,
	_clearColor = nil, _hudColor = nil,

	_data = nil,
	_options = nil,

	ctor = function (self, co)
		self.co = co
		self.bgm = Resources.load('assets/bgms/bgm.ogg', Music)
		local WALKABLE_CEL = 768
		local BORDER_CEL = -1
		self.isHeroBlocked, self.isEnemyBlocked, self.isWeaponBlocked, self.isBulletBlocked =
			function (pos) -- Is hero blocked?
				local cel = mget(self.building, pos.x, pos.y)
				if cel ~= WALKABLE_CEL then
					return true
				end
				if self.foreground ~= nil then
					cel = mget(self.foreground, pos.x, pos.y)
					if cel ~= WALKABLE_CEL then
						return true
					end
				end

				return false
			end,
			function (pos) -- Is enemy blocked?
				local cel = mget(self.building, pos.x, pos.y)
				if cel ~= WALKABLE_CEL and cel ~= BORDER_CEL then
					return true
				end
				if self.foreground ~= nil then
					cel = mget(self.foreground, pos.x, pos.y)
					if cel ~= WALKABLE_CEL and cel ~= BORDER_CEL then
						return true
					end
				end

				return false
			end,
			function (pos) -- Is weapon blocked?
				local cel = mget(self.building, pos.x, pos.y)
				if cel ~= WALKABLE_CEL then
					return true
				end

				return false
			end,
			function (pos) -- Is bullet blocked?
				local cel = mget(self.building, pos.x, pos.y)
				if cel ~= WALKABLE_CEL and cel ~= BORDER_CEL then
					return true
				end

				return false
			end
		self.raycaster = Raycaster.new()
		self.raycaster.tileSize = Vec2.new(16, 16)
		self.camera = Camera.new()

		self._blankImage = Image.new()
		self._blankImage:resize(1, 1)
		self._blankImage:set(0, 0, Color.new(255, 255, 255, 1))
		self._clearColor, self._hudColor =
			Color.new(80, 80, 80), Color.new(30, 30, 30)

		self.state = States['title'](self)

		self._data = {
			['highscore'] = 0
		}
		self._options = {
			['audio/sfx/volume'] = 0.8,
			['audio/bgm/volume'] = 0.8,
			['video/canvas/scale'] = 2,
			['gameplay/blood/show'] = true
		}
	end,

	-- Gets data of the specific key.
	getData = function (self, key)
		return self._data[key]
	end,
	-- Sets data of the specific key.
	setData = function (self, key, val)
		self._data[key] = val

		return self
	end,
	-- Gets option value of the specific key.
	getOption = function (self, key)
		return self._options[key]
	end,
	-- Sets option value of the specific key.
	setOption = function (self, key, val)
		self._options[key] = val

		return self
	end,

	-- Adds the specific number of killing to the current game.
	addKilling = function (self, num)
		if num == nil then
			num = 1
		end
		self.killingCount = self.killingCount + num

		self.room.finished(self)

		return self
	end,
	-- Adds the specific number of score to the current game.
	addScore = function (self, num)
		self.score = self.score + num
		if self.score > self.highscore then
			self.highscore = self.score
			self.newHighscore = true
		end

		self.room.finished(self)

		return self
	end,

	-- Loads game data.
	load = function (self)
		local file = File.new()
		if file:open(DATE_FILE, Stream.Read) then
			local str = file:readString()
			file:close()
			local json = Json.new()
			json:fromString(str)
			self._data = json:toTable()
			if type(self._data) ~= 'table' then
				self._data = { }
			end
			self.highscore = self._data['highscore']
		end

		file = File.new()
		if file:open(CONFIG_FILE, Stream.Read) then
			local str = file:readString()
			file:close()
			local json = Json.new()
			json:fromString(str)
			self._options = json:toTable()
			if not type(self._options) == 'table' then
				self._options = { }
			end
		end

		return self
	end,
	-- Saves game data.
	save = function (self)
		local file = File.new()
		if file:open(DATE_FILE, Stream.Write) then
			self._data['highscore'] = self.highscore
			local json = Json.new()
			json:fromTable(self._data)
			local str = json:toString()
			file:writeLine(str)
			file:close()
		end

		file = File.new()
		if file:open(CONFIG_FILE, Stream.Write) then
			local json = Json.new()
			json:fromTable(self._options)
			local str = json:toString()
			file:writeLine(str)
			file:close()
		end

		return self
	end,

	-- Loads initial resources, setups environments.
	setup = function (self)
		local sfxVol, bgmVol =
			self:getOption('audio/sfx/volume') or 0.8, self:getOption('audio/bgm/volume') or 0.8
		volume(sfxVol, bgmVol)
		play(self.bgm, true, 2)

		self:play(false, true)

		return self
	end,
	-- Builds a scene.
	build = function (self, background, building, foreground, lingeringPoints, passingByPoints, initialWeapons, enemySequence, options, clearColors, effects)
		return {
			background = background, building = building, foreground = foreground,
			wave = function ()
				-- Prepare.
				local WEAPON_ORIGIN = Vec2.new(building.width * 16 * 0.5, building.height * 16 * 0.5)
				local WEAPON_VECTOR = Vec2.new(100, 0)
				local weapons = { }
				local initialWeaponsAngle = options.initialWeaponsAngle or (math.pi * 0.07)
				forEach(initialWeapons, function (w, i)
					local weapon = (w.class == 'Gun' and Gun or Melee).new(
						self.isWeaponBlocked,
						{
							type = w.type,
							game = self,
						}
					)
						:setDisappearable(false)
						:float(2)
						:on('picked', function (sender, owner)
							sender:off('picked')
							remove(weapons, sender)
							if owner == self.hero then
								forEach(weapons, function (w, _)
									w:kill('disappeared', nil)

									local fx = self.pool:effect('disappearance', w.x, w.y, self)
									table.insert(self.foregroundEffects, fx)
								end)
							end
						end)
					if w.capacity ~= nil then
						weapon:setCapacity(w.capacity)
					end
					table.insert(weapons, weapon)
					local pos = w.position
					if pos == nil then
						pos = WEAPON_ORIGIN + WEAPON_VECTOR:rotated(
							math.pi * 2 * ((i - 1) / #initialWeapons) + initialWeaponsAngle
						)
					end
					weapon.x, weapon.y = pos.x, pos.y
					table.insert(self.objects, weapon)

					local fx = self.pool:effect('appearance', pos.x, pos.y, self)
					table.insert(self.foregroundEffects, fx)
				end)

				forEach(clearColors, function (c, _)
					table.insert(self.clearColors, c)
				end)
				if #self.clearColors == 1 then
					self._clearColor = self.clearColors[1]
				end

				forEach(effects, function (e, _)
					local fx = self.pool:effect(e.type, self.sceneWidth * e.x, self.sceneHeight * e.y, self)
						:setContent(e.content)
					if e.layer == 'background' then
						table.insert(self.backgroundEffects, fx)
					elseif e.layer == 'foreground' then
						table.insert(self.foregroundEffects, fx)
					end
				end)

				-- Delay.
				Coroutine.waitFor(3.5)

				-- Spawn enemies.
				local pointIndex = 1
				while self.state.playing do
					-- Delay.
					Coroutine.waitFor(1.5)

					-- Spawn.
					if self.enemyCount < options.maxEnemyCount and not DEBUG_PAUSE_SPAWNING then
						-- Generate enemy.
						local _, type_ = coroutine.resume(enemySequence)
						if type_ ~= nil then
							-- Create enemy.
							local cfg = Enemies[type_]
							local enemy = Enemy.new(
								transform(cfg['assets'], function (asset, _)
									return Resources.load(asset)
								end),
								cfg['box'],
								self.isEnemyBlocked, self.isBulletBlocked,
								{
									game = self,
									hp = cfg['hp'],
									behaviours = cfg['behaviours'],
									lookAtTarget = cfg['look_at_target'],
									moveSpeed = cfg['move_speed']
								}
							)
							local isLingering, isPassingBy =
								exists(cfg['behaviours'], 'chase') or exists(cfg['behaviours'], 'besiege'),
								exists(cfg['behaviours'], 'pass_by')
							local points = nil
							if isLingering then
								points = lingeringPoints
							elseif isPassingBy then
								points = passingByPoints
							end
							local goal = points[pointIndex]
							local pos = car(goal)
							enemy.x, enemy.y = pos.x, pos.y
							enemy:setGoals(cdr(goal))
							enemy:reset()
							table.insert(self.objects, enemy)

							local fx = self.pool:effect('appearance', pos.x, pos.y, self)
							table.insert(self.foregroundEffects, fx)

							-- Setup event handler.
							enemy:on('dead', function (sender, reason, byWhom)
								self.enemyCount = self.enemyCount - 1
								if reason == 'killed' then
									self:addKilling(1)
									self:addScore(cfg['score'])
									if self:getOption('gameplay/blood/show') then
										local corpse = Corpse.new(
											sender:corpse(),
											Recti.byXYWH(0, 0, 16, 32)
										)
										corpse.x, corpse.y = sender.x, sender.y
										corpse:setAngle(sender:angle() - math.pi * 0.5)
										table.insert(self.backgroundEffects, corpse)
										for i = 1, 3 do
											local fx = self.pool:effect('blood', sender.x + math.random() * 32 - 16, sender.y + math.random() * 32 - 16, self)
											table.insert(self.backgroundEffects, 1, fx)
										end
									else
										local fx = self.pool:effect('disappearance', sender.x, sender.y, self)
										table.insert(self.foregroundEffects, fx)
									end
								else
									local fx = self.pool:effect('disappearance', sender.x, sender.y, self)
									table.insert(self.foregroundEffects, fx)
								end
							end)
							self.enemyCount = self.enemyCount + 1

							-- Equip with weapon.
							if cfg['weapon'] ~= nil then
								local weaponCfg = Weapons[cfg['weapon']]
								local weapon = (weaponCfg['class'] == 'Gun' and Gun or Melee).new(
									self.isBulletBlocked,
									{
										type = cfg['weapon'],
										game = self,
									}
								)
									:float(2)
								enemy:setWeapon(weapon)
								weapon:kill('picked', nil)
							end

							-- Equip with armour.
							if cfg['armour'] ~= nil then
								local armourCfg = Armours[cfg['armour']]
								local armour = BodyArmour.new(
									{
										type = cfg['armour'],
										game = self,
									}
								)
								enemy:setArmour(armour)
								armour:kill('picked', nil)
							end

							-- Finish.
							pointIndex = pointIndex + 1
							if pointIndex > #points then
								pointIndex = 1
							end
						end
					end
				end
			end,
			finished = function ()
				return options.finishingCondition(self)
			end
		}
	end,
	-- Starts a new game.
	play = function (self, toGame, restart)
		-- Pick a room.
		if restart then
			self.levelIndex = 1
		else
			self.levelIndex = self.levelIndex + 1
		end
		self.tutorialIndex = nil
		local types = flat(Scenes, function (k, _)
			return k
		end)
		local type_ = any(types)
		self.room = Scenes[type_](self, self.levelIndex)

		-- Load map.
		self.background, self.building, self.foreground =
			self.room.background, self.room.building, self.room.foreground
		self.backgroundOffsetX, self.backgroundOffsetY =
			(self.building.width - self.background.width) * 0.5 * 16, (self.building.height - self.background.height) * 0.5 * 16
		self.sceneWidth, self.sceneHeight =
			self.building.width * 16, self.building.height * 16

		-- Initialize objects.
		self.objects, self.pending = { }, { }
		self.clearColors = { }
		self.backgroundEffects, self.foregroundEffects = { }, { }
		self.enemyCount = 0
		self.pool = Pool.new()

		-- Load hero.
		if restart then
			local cfg = Heroes['hero1']
			local hero = Hero.new(
				transform(cfg['assets'], function (asset, _)
					return Resources.load(asset)
				end),
				cfg['box'],
				self.isHeroBlocked, self.isBulletBlocked,
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

			hero:on('dead', function (sender, reason, byWhom)
				self.state = States['gameover'](self)
				self.co:clear()
				if self:getOption('gameplay/blood/show') then
					local corpse = Corpse.new(
						sender:corpse(),
						Recti.byXYWH(0, 0, 16, 32)
					)
					corpse.x, corpse.y = sender.x, sender.y
					corpse:setAngle(sender:angle() - math.pi * 0.5)
					table.insert(self.backgroundEffects, corpse)
					for i = 1, 3 do
						local fx = self.pool:effect('blood', sender.x + math.random() * 32 - 16, sender.y + math.random() * 32 - 16, self)
						table.insert(self.backgroundEffects, 1, fx)
					end
				else
					local fx = self.pool:effect('disappearance', sender.x, sender.y, self)
					table.insert(self.foregroundEffects, fx)
				end
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
				:start(wave)
		end

		-- Finish.
		collectgarbage()
		Resources.collect()

		return self
	end,
	-- Starts the tutorial.
	tutorial = function (self, index)
		-- Pick a room.
		self.levelIndex = nil
		self.tutorialIndex = index
		local type_ = 'tutorial' .. tostring(self.tutorialIndex)
		self.room = Tutorials[type_](self, self.tutorialIndex)

		-- Load map.
		self.background, self.building, self.foreground =
			self.room.background, self.room.building, self.room.foreground
		self.backgroundOffsetX, self.backgroundOffsetY =
			(self.building.width - self.background.width) * 0.5 * 16, (self.building.height - self.background.height) * 0.5 * 16
		self.sceneWidth, self.sceneHeight =
			self.building.width * 16, self.building.height * 16

		-- Initialize objects.
		self.objects, self.pending = { }, { }
		self.clearColors = { }
		self.backgroundEffects, self.foregroundEffects = { }, { }
		self.enemyCount = 0
		self.pool = Pool.new()

		-- Load hero.
		local cfg = Heroes['hero1']
		local hero = Hero.new(
			transform(cfg['assets'], function (asset, _)
				return Resources.load(asset)
			end),
			cfg['box'],
			self.isHeroBlocked, self.isBulletBlocked,
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

		self.hero = hero

		-- Initialize states.
		self.killingCount = 0
		if self.tutorialIndex == 1 then
			self.score = 0
		end
		self.state = States['tutorial_next'](self)
		self.camera:reset()

		-- Start a wave.
		local wave = coroutine.create(self.room.wave)
		self.co
			:clear()
			:start(wave)

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
		if cameraX == nil --[[ or cameraY == nil ]] then
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
				hero:attack(1, nil)
			end
			if mmb or keyp(beInput.KeyCode.R) then
				hero:pick()
			elseif rmb or keyp(beInput.KeyCode.F) then
				hero:throw()
			end
		end

		-- Update objects and draw everything.
		self.camera:prepare(delta)
		map(self.background, self.backgroundOffsetX, self.backgroundOffsetY)
		for _, v in ipairs(self.backgroundEffects) do
			v:update(delta)
		end
		map(self.building, 4, 4, COLOR_SHADOW)
		map(self.building, 0, 0)
		map(self.foreground, 3, 3, COLOR_SHADOW)
		map(self.foreground, 0, 0)
		if self.state.playing then
			for _, v in ipairs(self.objects) do
				v:behave(delta, hero)
			end
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
		local weaponAndArmourCount, firstWeapon = 0, nil
		local dead = nil
		for i = 1, #self.objects do
			local obj = self.objects[i]
			if obj:dead() then
				if dead == nil then
					dead = { }
				end
				table.insert(dead, 1, i)
			elseif obj.group == 'weapon' or obj.group == 'armour' then
				weaponAndArmourCount = weaponAndArmourCount + 1
				if firstWeapon == nil and obj:disappearable() then
					firstWeapon = obj
				end
			end
		end
		if weaponAndArmourCount > 5 and firstWeapon ~= nil then -- Up to 5.
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
		local weapon, armour = hero:weapon(), hero:armour()
		clip(0, 0, canvasWidth, HUD_HEIGHT)
		rect(0, 0, canvasWidth, HUD_HEIGHT, true, self._hudColor)

		-- Information.
		font(FONT_NORMAL_TEXT)

		if self.levelIndex ~= nil then
			text('LEVEL', 10, 7, COLOR_NORMAL_TEXT)
			text(self.levelIndex, 70, 7, COLOR_NORMAL_TEXT)
		elseif self.tutorialIndex ~= nil then
			text('TUTORIAL', 10, 7, COLOR_NORMAL_TEXT)
			text(self.tutorialIndex, 94, 7, COLOR_NORMAL_TEXT)
		else
			text('LEVEL', 10, 7, COLOR_NORMAL_TEXT)
			text(0, 70, 7, COLOR_NORMAL_TEXT)
		end
		text('EQUIP.', 10, 26, COLOR_NORMAL_TEXT)
		if weapon == nil and armour == nil then
			text('NONE', 70, 26, COLOR_NORMAL_TEXT)
		else
			local x = 70
			if weapon ~= nil then
				circ(x + 8, 30, 9, true, Color.new(13, 108, 174))
				spr(weapon.icon, x, 22)
				x = x + 24
				local txt = weapon:name()
				if weapon:capacity() ~= nil then
					if weapon:capacity() >= 0 then
						txt = txt .. ' [' .. tostring(weapon:capacity()) .. ']'
					else
						txt = txt .. ' [INF.]'
					end
				end
				local weaponWidth, _ = measure(txt, FONT_NORMAL_TEXT)
				text(txt, x, 26, COLOR_NORMAL_TEXT)
				x = x + weaponWidth + 8
			end
			if armour ~= nil then
				circ(x + 8, 30, 9, true, Color.new(13, 108, 174))
				spr(armour.icon, x, 22)
				x = x + 24
			end
		end

		local scoreWidth, _ = measure(self.score, FONT_NORMAL_TEXT)
		local highscoreWidth, _ = measure(self.highscore, FONT_NORMAL_TEXT)
		local maxScoreWidth = math.max(scoreWidth, highscoreWidth)
		local textWidth, _ = measure('HIGHSCORE', FONT_NORMAL_TEXT)
		text('HIGHSCORE', canvasWidth - textWidth - maxScoreWidth - 10 - 8, 7, COLOR_NORMAL_TEXT)
		text(self.highscore, canvasWidth - maxScoreWidth - 10, 7, self.newHighscore and Color.new(255, 100, 100) or COLOR_NORMAL_TEXT)
		textWidth, _ = measure('SCORE', FONT_NORMAL_TEXT)
		text('SCORE', canvasWidth - textWidth - maxScoreWidth - 10 - 8, 22, COLOR_NORMAL_TEXT)
		text(self.score, canvasWidth - maxScoreWidth - 10, 22, COLOR_NORMAL_TEXT)

		if DEBUG_SHOW_WIREFRAME then
			local txt = 'POS: ' .. tostring(math.floor(self.hero.x + 0.5)) .. ', ' .. tostring(math.floor(self.hero.y + 0.5))
			text(txt, 128, 7)
		end

		font(nil)

		-- Finish.
		clip(0, HUD_HEIGHT, canvasWidth, canvasHeight - HUD_HEIGHT)

		return self
	end
})
