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
			:put(P(50), 320)
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
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
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
		local numberOptionToBoolean = function (key)
			local val = game:getOption(key)
			if not val then
				return 0
			end

			return val > 0
		end
		local booleanToNumberOption = function (key, val, trueVal)
			local val_ = val and trueVal or 0
			game:setOption(key, val_)
		end
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 1)
			:put(P(50), 230)
			:resize(200, 60)
			:addChild(
				beGUI.Label.new('AUDIO', 'left', false, 'label', 'label_shadow')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
			)
			:addChild(
				beGUI.Button.new('SFX: ' .. (numberOptionToBoolean('audio/sfx/volume') and 'ON ' or 'OFF'))
					:anchor(0, 0)
					:put(0, 17)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						booleanToNumberOption('audio/sfx/volume', not numberOptionToBoolean('audio/sfx/volume'), 0.8)
						local sfxVol, bgmVol =
							game:getOption('audio/sfx/volume') or 0.8, game:getOption('audio/bgm/volume') or 0.8
						volume(sfxVol, bgmVol)
						sender:setValue('SFX: ' .. (numberOptionToBoolean('audio/sfx/volume') and 'ON ' or 'OFF'))
					end)
			)
			:addChild(
				beGUI.Button.new('BGM: ' .. (numberOptionToBoolean('audio/bgm/volume') and 'ON ' or 'OFF'))
					:anchor(0, 0)
					:put(0, 34)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						booleanToNumberOption('audio/bgm/volume', not numberOptionToBoolean('audio/bgm/volume'), 0.8)
						local sfxVol, bgmVol =
							game:getOption('audio/sfx/volume') or 0.8, game:getOption('audio/bgm/volume') or 0.8
						volume(sfxVol, bgmVol)
						sender:setValue('BGM: ' .. (numberOptionToBoolean('audio/bgm/volume') and 'ON ' or 'OFF'))
					end)
			)
			:addChild(
				beGUI.Label.new('VIDEO', 'left', false, 'label', 'label_shadow')
					:anchor(0, 0)
					:put(0, 51)
					:resize(P(100), 16)
			)
			:addChild(
				beGUI.Button.new('x1')
					:anchor(0, 0)
					:put(0, 68)
					:resize(P(32), 16)
					:on('clicked', function (sender)
						local w, h = 640, 360
						Application.resize(w, h)
						game:setOption('video/canvas/scale', 1)
					end)
			)
			:addChild(
				beGUI.Button.new('x2')
					:anchor(0.5, 0)
					:put(P(50), 68)
					:resize(P(32), 16)
					:on('clicked', function (sender)
						local w, h = 640, 360
						Application.resize(w * 2, h * 2)
						game:setOption('video/canvas/scale', 2)
					end)
			)
			:addChild(
				beGUI.Button.new('x3')
					:anchor(1, 0)
					:put(P(100), 68)
					:resize(P(32), 16)
					:on('clicked', function (sender)
						local w, h = 640, 360
						Application.resize(w * 3, h * 3)
						game:setOption('video/canvas/scale', 3)
					end)
			)
			:addChild(
				beGUI.Button.new('FULL SCREEN')
					:anchor(0, 0)
					:put(0, 85)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						Application.resize('fullscreen')
						game:setOption('video/canvas/scale', 'full')
					end)
			)
			:addChild(
				beGUI.Label.new('GAMEPLAY', 'left', false, 'label', 'label_shadow')
					:anchor(0, 0)
					:put(0, 102)
					:resize(P(100), 16)
			)
			:addChild(
				beGUI.Button.new('SHOW BLOOD: ' .. (game:getOption('gameplay/blood/show') and 'ON ' or 'OFF'))
					:anchor(0, 0)
					:put(0, 119)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:setOption('gameplay/blood/show', not game:getOption('gameplay/blood/show'))
						sender:setValue('SHOW BLOOD: ' .. (game:getOption('gameplay/blood/show') and 'ON ' or 'OFF'))
					end)
			)
			:addChild(
				beGUI.Button.new('BACK')
					:anchor(0, 0)
					:put(0, 141)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:save()
						game.state = States['title'](game)
					end)
			)

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(FONT_TITLE_TEXT)
				local txt = 'Hyper Bullet'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
				font(nil)

				if navPrev() then
					widgets:navigate('prev')
				elseif navNext() then
					widgets:navigate('next')
				elseif navConfirm() then
					widgets:navigate('press')
				elseif navCancel() then
					if widgets.context and widgets.context.focus == nil then
						game.state = States['title'](game)
					else
						game:save()
						widgets:navigate('cancel')
					end
				end
				font(theme['font'].resource)
				widgets:update(theme, delta)
				font(nil)

				return self
			end
		}
	end,
	['wait'] = function (game, interval, txt, next)
		local ticks = 0
		clear(game.pending)

		return {
			playing = false,
			update = function (self, delta)
				if txt ~= nil then
					local canvasWidth, canvasHeight = Canvas.main:size()

					font(FONT_TITLE_TEXT)
					local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
					text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
					text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
					font(nil)
				end

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= interval then
						ticks = nil
					end
				else
					next()
				end

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
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
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
			:put(P(50), 320)
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
			:addChild(
				beGUI.Button.new('BACK')
					:anchor(0, 0)
					:put(0, 17)
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
				local txt = 'GAME OVER'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
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
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
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
			:put(P(50), 320)
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
				local txt = 'FINISH'
				local textWidth, textHeight = measure(txt, FONT_TITLE_TEXT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 70, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 70, COLOR_TITLE_TEXT)
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
