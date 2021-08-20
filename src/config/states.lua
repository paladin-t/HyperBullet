--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

States = {
	['title'] = function ()
		return {
			playing = false,
			update = function (self, game, delta)
				local canvasWidth, canvasHeight = Canvas.main:size()
	
				font(TITLE_FONT)
				local txt = 'Hyper Bullet'
				local textWidth, textHeight = measure(txt, TITLE_FONT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 - 20, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 - 20, Color.new(200, 220, 210))
				font(nil)
	
				font(NORMAL_FONT)
				txt = 'Press ENTER to start'
				textWidth, textHeight = measure(txt, NORMAL_FONT)
				text(txt, (canvasWidth - textWidth) * 0.5 + 2, (canvasHeight - textHeight) * 0.5 + 2 + 10, Color.new(0, 0, 0))
				text(txt, (canvasWidth - textWidth) * 0.5, (canvasHeight - textHeight) * 0.5 + 10, Color.new(255, 255, 255))
				font(nil)
	
				if keyp(KeyCode.Return) then -- Return/Enter key.
					game:save()
					game:start(true)
				end
	
				return self
			end
		}
	end,
	['playing'] = function ()
		return {
			playing = true,
			update = function (self, game, delta)
				return self
			end
		}
	end,
	['gameover'] = function ()
		return {
			playing = false,
			update = function (self, game, delta)
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
					game:save()
					game:start(true)
				end
	
				return self
			end
		}
	end
}
