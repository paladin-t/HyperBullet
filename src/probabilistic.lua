--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Probabilistic = class({
	_candidates = nil,
	_total = 0,

	ctor = function (self, ...)
		self._candidates = { }
		self._total = 0

		local args = table.pack(...)
		for i = 1, #args - 1, 2 do
			self:add(args[i], args[i + 1])
		end
	end,

	add = function (self, data, weight)
		table.insert(
			self._candidates,
			{
				data = data,
				weight = weight,
				possibility = self._total + weight
			}
		)
		self._total = self._total + weight

		return self
	end,
	estimate = function (self, type, count)
		for i, v in ipairs(self._candidates) do
			if v.data == type then
				return v.weight / self._total * count
			end
		end

		return 0
	end,

	next = function (self, random)
		local weight = nil
		if random then
			weight = random:next(1, self._total)
		else
			weight = math.random(1, self._total)
		end
		for i, v in ipairs(self._candidates) do
			if weight <= v.possibility then
				return v.data, i
			end
		end

		error('Impossible.')
	end
})
