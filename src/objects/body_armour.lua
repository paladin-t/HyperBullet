--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

BodyArmour = class({
	--[[ Constructor. ]]

	ctor = function (self, options)
		Armour.ctor(self, options)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'BodyArmour'
	end,

	--[[ Methods. ]]

	update = function (self, delta)
		Armour.update(self, delta)
	end
}, Armour)
