--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

Corpse = class({
	--[[ Variables. ]]

	group = 'corpse',

	_dual = false,

	--[[ Constructor. ]]

	ctor = function (self, resource, box, options)
		Object.ctor(self, resource, box, nil)

		self._dual = options.dual
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Corpse'
	end,

	--[[ Methods. ]]

	dual = function (self)
		return self._dual
	end,

	behave = function (self, delta, _1)
		return self
	end,
	update = function (self, delta)
		self:shadow(delta, 1, 1)

		Object.update(self, delta)
	end
}, Object)
