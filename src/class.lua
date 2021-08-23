--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

-- Declares a class.
function class(kls, base)
	if not base then
		base = { }
	end

	kls.new = function (...)
		local obj = { }
		setmetatable(obj, kls)
		if obj.ctor then
			obj:ctor(...)
		end

		return obj
	end

	kls.__index = kls

	setmetatable(kls, base)

	return kls
end

-- Determines whether an object is instance of a specific class.
function is(obj, kls)
	repeat
		if obj == kls then
			return true
		end
		obj = getmetatable(obj)
	until not obj

	return false
end
