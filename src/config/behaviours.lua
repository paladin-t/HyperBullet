--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Behaviours = {
	['chase'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Prepare.
				::again::
				local goal = (this._goals ~= nil and #this._goals > 0) and this._goals[1] or nil
				local dst = nil
				if goal == nil then
					dst = Vec2.new(hero.x, hero.y)
				else
					dst = goal
				end

				-- Walk through way points or chase.
				local src = Vec2.new(this.x, this.y)
				local diff = dst - src
				local l = diff.length
				local epsilon = 4
				if goal ~= nil and l <= epsilon then
					table.remove(this._goals, 1)

					goto again
				elseif goal == nil and l <= epsilon * 4 then
					-- Do nothing.
				else
					if l >= epsilon * 2 then
						if diff.x <= -epsilon then
							this:moveLeft(delta)
						elseif diff.x >= epsilon then
							this:moveRight(delta)
						end
						if diff.y <= -epsilon then
							this:moveUp(delta)
						elseif diff.y >= epsilon then
							this:moveDown(delta)
						end
					else
						this._moving = diff
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end,
	['besiege'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- TODO

				-- Finish.
				return src, dst
			end
		}
	end,
	['pass_by'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Prepare.
				::again::
				local goal = (this._goals ~= nil and #this._goals > 0) and this._goals[1] or nil
				local dst = nil
				if goal == nil then
					this:kill('disappeared') -- Disappear.

					return src, dst
				else
					dst = goal
				end

				-- Walk through way points.
				local src = Vec2.new(this.x, this.y)
				local diff = dst - src
				local l = diff.length
				local epsilon = 4
				if goal ~= nil and l <= epsilon then
					table.remove(this._goals, 1)

					goto again
				elseif goal == nil and l <= epsilon * 4 then
					-- Do nothing.
				else
					if l >= epsilon * 2 then
						if diff.x <= -epsilon then
							this:moveLeft(delta)
						elseif diff.x >= epsilon then
							this:moveRight(delta)
						end
						if diff.y <= -epsilon then
							this:moveUp(delta)
						elseif diff.y >= epsilon then
							this:moveDown(delta)
						end
					else
						this._moving = diff
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end,

	['attack'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Look at the hero.
				this:lookAt(hero.x, hero.y)

				-- Attack.
				local pos, idx = this:_raycast(src, Vec2.new(hero.x, hero.y) - src) -- Sight intersects with tile.
				if pos == nil then
					this:attack(nil)
				end

				if DEBUG then
					if pos then
						line(src.x, src.y, pos.x, pos.y, Color.new(255, 255, 255, 128))
					else
						line(src.x, src.y, hero.x, hero.y, Color.new(255, 0, 0, 128))
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end
}
