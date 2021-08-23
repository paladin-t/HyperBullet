--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
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
					dst = Vec2.new(hero.x, hero.y) -- Chase.
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
	['besiege'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Prepare.
				::again::
				local goal = (this._goals ~= nil and #this._goals > 0) and this._goals[1] or nil
				local dst = nil
				if goal == nil then
					dst = Vec2.new(hero.x, hero.y) - hero:facing() * 32 -- Besiege.
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

	['look_at'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Look at the hero.
				local lookAtTarget = this:lookAtTarget()
				if lookAtTarget == 'hero' then
					this:lookAt(hero.x, hero.y)
				else
					this:lookAt(lookAtTarget.x, lookAtTarget.y)
				end

				-- Finish.
				return src, dst
			end
		}
	end,

	['attack'] = function ()
		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Attack.
				local pos, idx = this:_raycast(src, Vec2.new(hero.x, hero.y) - src) -- Sight intersects with tile.
				if pos == nil and not hero:dead() then
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
