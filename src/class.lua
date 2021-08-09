--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
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
