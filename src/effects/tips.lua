--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Tips = class({
	--[[ Variables. ]]

	_game = nil,
	_content = nil,

	--[[ Constructor. ]]

	ctor = function (self, options)
		Object.ctor(self, nil, nil, nil)

		self._game = options.game
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Tips'
	end,

	--[[ Methods. ]]

	content = function (self)
		return self._content
	end,
	setContent = function (self, content)
		self._content = content

		return self
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		if self._game.state.playing then
			font(FONT_NORMAL_TEXT)
			local txt = self._content
			local textWidth, textHeight = measure(txt, FONT_NORMAL_TEXT)
			text(txt, self.x - textWidth * 0.5 + 1, self.y - textHeight - 15, Color.new(0, 0, 0))
			text(txt, self.x - textWidth * 0.5, self.y - textHeight - 16, COLOR_NORMAL_TEXT)
			font(nil)
		end
	end
}, Object)
