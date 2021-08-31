--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local function restart(self)
	return keyp(beInput.KeyCode.R)
end
local function navPrev(self)
	return keyp(beInput.KeyCode.Up)
end
local function navNext(self)
	return keyp(beInput.KeyCode.Down)
end
local function navConfirm(self)
	return keyp(beInput.KeyCode.Return)
end
local function navCancel(self)
	return keyp(beInput.KeyCode.Esc)
end

States = {
	['title'] = function (game)
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 1)
			:put(P(50), P(90))
			:resize(200, 60)
			:addChild(
				beGUI.Button.new('PLAY')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:play(true, true)
					end)
			)
			:addChild(
				beGUI.Button.new('TUTORIAL')
					:anchor(0, 0)
					:put(0, 17)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:tutorial(1)
					end)
			)
			:addChild(
				beGUI.Button.new('OPTIONS')
					:anchor(0, 0)
					:put(0, 34)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game.state = States['options'](game)
					end)
			)
			:addChild(
				beGUI.Button.new('EXIT')
					:anchor(0, 0)
					:put(0, 51)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						exit()
					end)
			)

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'Hyper Bullet'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, COLOR_TITLE_TEXT)
				font(nil)

				if navPrev() then
					widgets:navigate('prev')
				elseif navNext() then
					widgets:navigate('next')
				elseif navConfirm() then
					if widgets.context and widgets.context.focus == nil then
						game:play(true, true)
					else
						widgets:navigate('press')
					end
				elseif navCancel() then
					widgets:navigate('cancel')
				end
				font(theme['font'].resource)
				widgets:update(theme, delta)
				font(nil)

				return self
			end
		}
	end,
	['options'] = function (game)
		return {
			playing = false,
			update = function (self, delta)
				-- TODO

				return self
			end
		}
	end,

	['playing'] = function (game)
		return {
			playing = true,
			update = function (self, delta)
				return self
			end
		}
	end,
	['next'] = function (game)
		local ticks = 0

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'LEVEL ' .. tostring(game.levelIndex)
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, COLOR_TITLE_TEXT)
				font(nil)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					game.state = States['playing'](game)
				end

				return self
			end
		}
	end,
	['gameover'] = function (game)
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 1)
			:put(P(50), P(90))
			:resize(200, 60)
			:addChild(
				beGUI.Button.new('PRESS R TO RESTART')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:save()
						game:play(true, true)
					end)
			)
		local ticks = 0

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'GAME OVER'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, COLOR_TITLE_TEXT)
				font(nil)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					if restart() then
						game:save()
						game:play(true, true)
					elseif navPrev() then
						widgets:navigate('prev')
					elseif navNext() then
						widgets:navigate('next')
					elseif navConfirm() then
						if widgets.context and widgets.context.focus == nil then
							game:save()
							game:play(true, true)
						else
							widgets:navigate('press')
						end
					elseif navCancel() then
						widgets:navigate('cancel')
					end
					font(theme['font'].resource)
					widgets:update(theme, delta)
					font(nil)
				end

				return self
			end
		}
	end,

	['tutorial_playing'] = function (game)
		return {
			playing = true,
			update = function (self, delta)
				return self
			end
		}
	end,
	['tutorial_next'] = function (game)
		local ticks = 0

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'TUTORIAL ' .. tostring(game.tutorialIndex)
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, COLOR_TITLE_TEXT)
				font(nil)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					game.state = States['tutorial_playing'](game)
				end

				return self
			end
		}
	end,
	['tutorial_win'] = function (game)
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 1)
			:put(P(50), P(90))
			:resize(200, 60)
			:addChild(
				beGUI.Button.new('PRESS R TO CONTINUE')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:save()
						game.state = States['title'](game)
					end)
			)
		local ticks = 0

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'TUTORIAL COMPLETED'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, COLOR_TITLE_TEXT)
				font(nil)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					if restart() then
						game:save()
						game.state = States['title'](game)
					elseif navPrev() then
						widgets:navigate('prev')
					elseif navNext() then
						widgets:navigate('next')
					elseif navConfirm() then
						if widgets.context and widgets.context.focus == nil then
							game:save()
							game.state = States['title'](game)
						else
							widgets:navigate('press')
						end
					elseif navCancel() then
						widgets:navigate('cancel')
					end
					font(theme['font'].resource)
					widgets:update(theme, delta)
					font(nil)
				end

				return self
			end
		}
	end
}
