--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Armour = class({
	--[[ Variables. ]]

	type = nil,
	group = 'armour',

	icon = nil,

	_game = nil,
	_owner = nil,
	_name = nil, _acronym = nil,

	_sfxs = nil,

	--[[ Constructor. ]]

	ctor = function (self, options)
		local cfg = Armours[options.type]
		local resource = Resources.load(cfg['entry'])
		local box = cfg['box']
		self.type = options.type
		self.icon = Resources.load(cfg['entry'])
		self.icon:play('idle', true, true, true)

		Object.ctor(self, resource, box, nil)

		self.maxHp, self.hp = cfg['hp'], cfg['hp']

		self._game = options.game
		self._name, self._acronym = cfg['name'], cfg['acronym']

		self._sfxs = cfg['sfxs']
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Armour'
	end,

	--[[ Methods. ]]

	owner = function (self)
		return self._owner
	end,
	setOwner = function (self, owner)
		self._owner = owner
		self._disappearing, self._disappearingTicks = nil, 0

		if owner ~= nil then
			self:trigger('picked', owner)
		end

		return self
	end,

	name = function (self)
		return self._name
	end,
	acronym = function (self)
		return self._acronym
	end,

	sfxs = function (self)
		return self._sfxs
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		-- Draw shadow effect.
		local owner = self._owner
		if owner == nil then
			self:shadow(delta, 3, 3) -- Draw shadow effect.
		end

		-- Base update.
		Object.update(self, delta)

		-- Draw information text.
		if not owner then
			if self._acronym ~= nil then
				self._game:acronymArmourBackground(self.x, self.y - 20)
				font(FONT_NORMAL_TEXT)
				local txt = self._acronym
				local textWidth, textHeight = measure(txt, FONT_NORMAL_TEXT)
				text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
				text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, COLOR_CLEAR_TEXT)
				font(nil)
			elseif self._game.state.playing then
				font(FONT_NORMAL_TEXT)
				local txt = self._name
				local textWidth, textHeight = measure(txt, FONT_NORMAL_TEXT)
				text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
				text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, COLOR_CLEAR_TEXT)
				font(nil)
			end
		end
	end,

	_build = function (self, dstX, dstY, dstW, dstH)
		local dstX, dstY, dstW, dstH =
			self.x - (self.box:xMin() + self.box:width() * 0.5), self.y - (self.box:yMin() + self.box:height() * 0.5),
			self._spriteWidth, self._spriteHeight
		self._collider = Vec3.new(
			dstX + dstW * 0.5, dstY + dstH * 0.5,
			self.box:width() * 0.5
		)

		return dstX, dstY, dstW, dstH
	end
}, Object)
