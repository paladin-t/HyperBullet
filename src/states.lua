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
		local version = game:getInfo('version')
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 0.5)
			:put(P(50), P(50))
			:resize(P(100), P(100))
			:addChild(
				beGUI.Widget.new()
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

								game:playSfx('gui/play')
							end)
					)
					:addChild(
						beGUI.Button.new('TUTORIAL')
							:anchor(0, 0)
							:put(0, 17)
							:resize(P(100), 16)
							:on('clicked', function (sender)
								game:tutorial(1)

								game:playSfx('gui/tutorial')
							end)
					)
					:addChild(
						beGUI.Button.new('OPTIONS')
							:anchor(0, 0)
							:put(0, 34)
							:resize(P(100), 16)
							:on('clicked', function (sender)
								game.state = States['options'](game)

								game:playSfx('gui/ok')
							end)
					)
					:addChild(
						beGUI.Button.new('EXIT')
							:anchor(0, 0)
							:put(0, 51)
							:resize(P(100), 16)
							:on('clicked', function (sender)
								game:playSfx('gui/ok')

								exit()
							end)
					)
			)
		widgets
			:addChild(
				beGUI.Label.new('v' .. version, nil, false, 'font_white')
					:anchor(1, 1)
					:put(P(98), P(98))
					:resize(-1, 12)
			)
			:addChild(
				beGUI.Label.new('Powered by ', nil, false, 'font_white')
					:anchor(0, 1)
					:put(P(2), P(98))
					:resize(-1, 12)
					:addChild(
						beGUI.Custom.new()
							:anchor(0, 0)
							:put(0, P(100))
							:resize(P(100), P(100))
							:on('updated', function (sender, x, y, w, h)
								local lblBittyEngine = widgets:find('url_bitty_engine')
								lblBittyEngine.x = sender.x + w + 12
							end)
					)
			)
			:addChild(
				beGUI.Url.new('Bitty Engine')
					:setId('url_bitty_engine')
					:anchor(0, 1)
					:put(110, P(98))
					:resize(-1, 12)
					:on('clicked', function (sender)
						Platform.surf('https://paladin-t.github.io/bitty?f=hdc')
					end)
			)
		local text_ = Text.new(
			0.5, 0.3,
			'Hyper Bullet',
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if navPrev() then
					widgets:navigate('prev')
				elseif navNext() then
					widgets:navigate('next')
				elseif navConfirm() then
					if widgets.context and widgets.context.focus == nil then
						game:play(true, true)

						game:playSfx('gui/play')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
					end)
			)
		local text_ = Text.new(
			0.5, 0.3,
			'Hyper Bullet',
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if navPrev() then
					widgets:navigate('prev')
				elseif navNext() then
					widgets:navigate('next')
				elseif navConfirm() then
					widgets:navigate('press')
				elseif navCancel() then
					if widgets.context and widgets.context.focus == nil then
						game.state = States['title'](game)

						game:playSfx('gui/ok')
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
		local text_ = txt and Text.new(
			0.5, 0.3,
			txt,
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		) or nil

		return {
			playing = false,
			update = function (self, delta)
				if text_ ~= nil then
					text_:update(delta)
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
		local ticks = nil
		local text_ = nil

		return {
			playing = true,
			combo = nil,
			scored = function (self)
				if self.combo == nil then
					self.combo = 1
					ticks = 0
				else
					self.combo = self.combo + 1
					ticks = 0
					text_ = Text.new(
						0.98, 0.15,
						'COMBO x' .. tostring(self.combo),
						{
							worldSpace = false,
							font = FONT_SUBTITLE_TEXT,
							color = COLOR_BLEEDING_TEXT,
							pivot = Vec2.new(1, 0),
							style = 'blink',
							depth = 5,
							lifetime = nil,
							interval = 1
						}
					)
				end

				return self
			end,
			update = function (self, delta)
				if text_ ~= nil then
					text_:update(delta)
				end

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						self.combo = nil
						ticks = nil
						text_ = nil
					end
				end

				return self
			end
		}
	end,
	['next'] = function (game)
		local ticks = 0
		local text_ = Text.new(
			0.5, 0.3,
			'LEVEL ' .. tostring(game.levelIndex),
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 3 then
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

						game:playSfx('gui/ok')
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

						game:playSfx('gui/ok')
					end)
			)
		local ticks = 0
		local text_ = Text.new(
			0.5, 0.3,
			'GAME OVER',
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		game:playSfx('gameover')

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					if restart() then
						game:save()
						game:play(true, true)

						game:playSfx('gui/ok')
					elseif navPrev() then
						widgets:navigate('prev')
					elseif navNext() then
						widgets:navigate('next')
					elseif navConfirm() then
						if widgets.context and widgets.context.focus == nil then
							game:save()
							game:play(true, true)

							game:playSfx('gui/ok')
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
		local text_ = Text.new(
			0.5, 0.3,
			'TUTORIAL ' .. tostring(game.tutorialIndex),
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 3 then
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

						game:playSfx('gui/ok')
					end)
			)
		local ticks = 0
		local text_ = Text.new(
			0.5, 0.3,
			'FINISH',
			{
				worldSpace = false,
				font = FONT_TITLE_TEXT,
				color = COLOR_NEON_TEXT,
				pivot = Vec2.new(0.5, 0.5),
				style = 'wave',
				depth = 10,
				lifetime = nil,
				interval = 1
			}
		)

		return {
			playing = false,
			update = function (self, delta)
				text_:update(delta)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 3 then
						ticks = nil
					end
				else
					if restart() then
						game:save()
						game.state = States['title'](game)

						game:playSfx('gui/ok')
					elseif navPrev() then
						widgets:navigate('prev')
					elseif navNext() then
						widgets:navigate('next')
					elseif navConfirm() then
						if widgets.context and widgets.context.focus == nil then
							game:save()
							game.state = States['title'](game)

							game:playSfx('gui/ok')
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
