--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Stack = class({
	_threshold = nil,
	_stack = nil,

	ctor = function (self, threshold)
		self._threshold = threshold
		self._stack = { }
	end,

	__tostring = function (self)
		return 'Stack'
	end,

	__len = function (self)
		if self._stack == nil then
			return 0
		end

		return #self._stack
	end,

	push = function (self, data)
		table.insert(self._stack, data)
		if self._threshold ~= nil and #self._stack > self._threshold then
			table.remove(self._stack, 1)
		end

		return self
	end,
	pop = function (self)
		if #self._stack == 0 then
			return nil
		end
		local result = self._stack[1]
		table.remove(self._stack, 1)

		return result
	end,
	top = function (self)
		if #self._stack == 0 then
			return nil
		end

		return self._stack[1]
	end,
	count = function (self)
		return #self._stack
	end,
	get = function (self, index)
		if index < 1 or index > #self._stack then
			return nil
		end

		return self._stack[index]
	end,
	set = function (self, index, data)
		if index < 1 or index > #self._stack then
			return self
		end

		self._stack[index] = data

		return self
	end
})
