--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

require 'class'

-- Coroutine class.
Coroutine = class({
	_cos = nil,

	waitFor = function (sec)
		local start = DateTime.ticks()
		sec = DateTime.fromSeconds(sec)

		while DateTime.ticks() - start < sec do
			coroutine.yield()
		end
	end,

	ctor = function (self)
		self._cos = nil
	end,

	__len = function (self)
		return #self._cos
	end,

	count = function (self)
		return #self._cos
	end,
	empty = function (self)
		return self._cos == nil or #self._cos == 0
	end,
	clear = function (self)
		self._cos = nil

		return self
	end,

	start = function (self, co, ...)
		if type(co) == 'function' then
			co = coroutine.create(co)
		end

		if type(co) ~= 'thread' then
			error('Unexpected data: ' .. tostring(co) .. '.')
		end

		if self._cos == nil then
			self._cos = { }
		end
		table.insert(self._cos, co)

		if coroutine.status(co) ~= 'dead' then
			local ret, msg = coroutine.resume(co, ...)
			if not ret then
				error(msg)
			end
		end

		return self
	end,

	update = function (self, ...)
		if self._cos == nil or #self._cos == 0 then
			return false
		end

		local dead = nil
		for i = 1, #self._cos do
			local co = self._cos[i]
			if coroutine.status(co) ~= 'dead' then
				local ret, msg = coroutine.resume(co, ...)
				if not ret then
					error(msg)
				end
			end
			if coroutine.status(co) == 'dead' then
				if dead == nil then
					dead = { }
				end
				table.insert(dead, i)
			end
			if self._cos == nil then
				return false
			end
		end
		if dead ~= nil then
			for i = #dead, 1, -1 do
				table.remove(self._cos, dead[i])
			end
		end

		return true
	end
})
