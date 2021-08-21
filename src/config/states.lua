--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

local navPrev = function (self)
	return keyp(beInput.KeyCode.Up)
end
local navNext = function (self)
	return keyp(beInput.KeyCode.Down)
end
local navConfirm = function (self)
	return keyp(beInput.KeyCode.Return)
end
local navCancel = function (self)
	return keyp(beInput.KeyCode.Esc)
end

States = {
	['title'] = function (game)
		local P = beGUI.percent
		local theme = beTheme.default()
		local widgets = beGUI.Widget.new()
			:anchor(0.5, 1)
			:put(P(50), P(90))
			:resize(100, 60)
			:addChild(
				beGUI.Button.new('PLAY')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:save()
						game:start(true)
					end)
			)

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(TITLE_FONT)
				local txt = 'Hyper Bullet'
				local textWidth, textHeight = measure(txt, TITLE_FONT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, Color.new(200, 220, 210))
				font(nil)

				if navPrev() then
					widgets:navigate('prev')
				elseif navNext() then
					widgets:navigate('next')
				elseif navConfirm() then
					widgets:navigate('press')
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
	['playing'] = function (game)
		return {
			playing = true,
			update = function (self, delta)
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
			:resize(100, 60)
			:addChild(
				beGUI.Button.new('RESTART')
					:anchor(0, 0)
					:put(0, 0)
					:resize(P(100), 16)
					:on('clicked', function (sender)
						game:save()
						game:start(true)
					end)
			)
		local ticks = 0

		return {
			playing = false,
			update = function (self, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()

				font(TITLE_FONT)
				local txt = 'GAME OVER'
				local textWidth, textHeight = measure(txt, TITLE_FONT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, Color.new(200, 220, 210))
				font(nil)

				if ticks ~= nil then
					ticks = ticks + delta
					if ticks >= 1 then
						ticks = nil
					end
				else
					if navPrev() then
						widgets:navigate('prev')
					elseif navNext() then
						widgets:navigate('next')
					elseif navConfirm() then
						widgets:navigate('press')
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
