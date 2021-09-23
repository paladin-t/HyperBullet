--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

local function toIndex(pos)
	local x, y = math.floor(pos.x / 16), math.floor(pos.y / 16)

	return Vec2.new(x, y)
end

local function fromIndex(idx)
	local x, y = (idx.x + 0.5) * 16, (idx.y + 0.5) * 16

	return Vec2.new(x, y)
end

local function redirect(this, delta, hero, src, dst)
	if this._moving.length == 0 then
		return
	end
	local m = this:_move(this._moving)
	if m.length ~= 0 then
		return
	end
	local dst = Vec2.new(hero.x, hero.y)
	local path = this:findpath(toIndex(src), toIndex(dst))
	for i, idx in ipairs(path) do
		table.insert(this._goals, fromIndex(idx))
		if i >= 6 then
			break
		end
	end
end

Behaviours = {
	--[[ Moving. ]]

	['chase'] = function ()
		return {
			penetrative = false,
			behave = function (self, this, delta, hero, src, dst, penetrative)
				-- Prepare.
				::consume::
				local empty = this._goals == nil or #this._goals == 0
				local goal = not empty and this._goals[1] or nil
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

					goto consume
				elseif goal == nil and l <= EPSILON * 3 then
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
					if empty then
						redirect(this, delta, hero, src, dst)
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end,
	['besiege'] = function ()
		return {
			penetrative = false,
			behave = function (self, this, delta, hero, src, dst, penetrative)
				-- Prepare.
				::consume::
				local empty = this._goals == nil or #this._goals == 0
				local goal = not empty and this._goals[1] or nil
				local dst = nil
				if goal == nil then
					dst = Vec2.new(hero.x, hero.y) - hero:facing() * 16 -- Besiege.
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

					goto consume
				elseif goal == nil and l <= EPSILON * 3 then
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
					if empty then
						redirect(this, delta, hero, src, dst)
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end,
	['pass_by'] = function ()
		return {
			penetrative = true,
			behave = function (self, this, delta, hero, src, dst, penetrative)
				-- Prepare.
				::consume::
				local empty = this._goals == nil or #this._goals == 0
				local goal = not empty and this._goals[1] or nil
				local dst = nil
				if goal == nil then
					this:kill('disappeared', nil) -- Disappear.

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

					goto consume
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

	--[[ Sight. ]]

	['look_at'] = function ()
		return {
			penetrative = false,
			behave = function (self, this, delta, hero, src, dst, penetrative)
				-- Look at the target.
				local lookAtTarget = this:lookAtTarget()
				if lookAtTarget == 'hero' then
					this:lookAt(hero.x, hero.y)
				elseif lookAtTarget == 'vertical' then
					this:lookAt(this.x, this._game.sceneHeight * 0.5)
				elseif lookAtTarget == 'horizontal' then
					this:lookAt(this._game.sceneWidth * 0.5, this.y)
				else
					this:lookAt(lookAtTarget.x, lookAtTarget.y)
				end

				-- Finish.
				return src, dst
			end
		}
	end,

	--[[ Offense. ]]

	['attack'] = function ()
		local ticks = 0
		local count = 0

		return {
			penetrative = false,
			behave = function (self, this, delta, hero, src, dst, penetrative)
				-- Prepare.
				if src == nil then
					return src, dst
				end

				-- Check attack rest.
				local weapon = this:weapon()
				local attackTempo = this:attackTempo()
				if attackTempo ~= nil then
					local active, rest = attackTempo['active'], attackTempo['rest']
					local total = active + rest
					ticks = ticks + delta
					if ticks >= total then
						ticks = ticks - total
					end
					if ticks >= active then
						return src, dst
					end
				end

				-- Check interval.
				local limit = nil
				if weapon ~= nil and weapon.type == 'mines' then
					limit = 1
				end

				-- Attack.
				local pos, _ = this:raycast(src, Vec2.new(hero.x, hero.y) - src, this._game.isBulletBlocked) -- Sight intersects with tile.
				if (pos == nil or penetrative) and not hero:dead() then
					if limit == nil or count < limit then
						local accuracy = nil
						local weapon = this:weapon()
						if weapon ~= nil then
							accuracy = weapon:accuracy()
						end
						local bullet = this:attack(nil, accuracy, false)
						if bullet ~= nil then
							bullet
								:on('dead', function (sender, _2, _3)
									count = count - 1
								end)
						end
						if bullet ~= nil then
							count = count + 1
						end
					end
				end

				if DEBUG_SHOW_WIREFRAME then
					if pos == nil then
						line(src.x, src.y, hero.x, hero.y, Color.new(255, 0, 0, 128))
					else
						line(src.x, src.y, pos.x, pos.y, Color.new(255, 255, 255, 128))
					end
				end

				-- Finish.
				return src, dst
			end
		}
	end
}
