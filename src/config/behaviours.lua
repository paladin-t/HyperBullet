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
				local EPSILON = 1
				local src = Vec2.new(this.x, this.y)
				local diff = dst - src
				local l = diff.length
				if goal ~= nil and l <= EPSILON then
					table.remove(this._goals, 1)

					goto again
				elseif goal == nil and l <= EPSILON * 4 then
					-- Do nothing.
				else
					if l >= EPSILON * 2 then
						if diff.x <= -EPSILON then
							this:moveLeft(delta)
						elseif diff.x >= EPSILON then
							this:moveRight(delta)
						end
						if diff.y <= -EPSILON then
							this:moveUp(delta)
						elseif diff.y >= EPSILON then
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
				local EPSILON = 1
				local src = Vec2.new(this.x, this.y)
				local diff = dst - src
				local l = diff.length
				if goal ~= nil and l <= EPSILON then
					table.remove(this._goals, 1)

					goto again
				elseif goal == nil and l <= EPSILON * 4 then
					-- Do nothing.
				else
					if l >= EPSILON * 2 then
						if diff.x <= -EPSILON then
							this:moveLeft(delta)
						elseif diff.x >= EPSILON then
							this:moveRight(delta)
						end
						if diff.y <= -EPSILON then
							this:moveUp(delta)
						elseif diff.y >= EPSILON then
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
				local EPSILON = 1
				local src = Vec2.new(this.x, this.y)
				local diff = dst - src
				local l = diff.length
				if goal ~= nil and l <= EPSILON then
					table.remove(this._goals, 1)

					goto again
				elseif goal == nil and l <= EPSILON * 4 then
					-- Do nothing.
				else
					if l >= EPSILON * 2 then
						if diff.x <= -EPSILON then
							this:moveLeft(delta)
						elseif diff.x >= EPSILON then
							this:moveRight(delta)
						end
						if diff.y <= -EPSILON then
							this:moveUp(delta)
						elseif diff.y >= EPSILON then
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
				-- Look at the target.
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
		local count = 0

		return {
			behave = function (self, this, delta, hero, src, dst)
				-- Prepare.
				if src == nil then
					return src, dst
				end

				-- Check interval.
				local limit = nil
				local weapon = this:weapon()
				if weapon ~= nil and weapon.type == 'mines' then
					limit = 1
				end

				-- Attack.
				local pos, idx = this:_raycast(src, Vec2.new(hero.x, hero.y) - src) -- Sight intersects with tile.
				if pos == nil and not hero:dead() then
					if limit == nil or count < limit then
						local accuracy = nil
						local weapon = this:weapon()
						if weapon ~= nil then
							accuracy = weapon:accuracy()
						end
						local bullet = this:attack(nil, accuracy)
						if bullet ~= nil then
							bullet
								:on('dead', function (sender, _)
									count = count - 1
								end)
						end
						if bullet ~= nil then
							count = count + 1
						end
					end
				end

				if DEBUG_SHOW_WIREFRAME then
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
