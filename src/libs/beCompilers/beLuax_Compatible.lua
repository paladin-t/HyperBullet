--[[
The MIT License

Copyright (C) 2021 Tony Wang

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- [[ Math. ]]

local cos = function (x)
	return math.cos(x * -math.pi * 2)
end
local flr = math.floor
local rnd = function (x)
	return math.random() * x
end
local sgn = function (x)
	return x >= 0 and 1 or -1
end
local sin = function (x)
	return math.sin(x * -math.pi * 2)
end
local time = function ()
	return DateTime.toSeconds(DateTime.ticks())
end

-- [[ List. ]]

local add = function (lst, elem, index)
	if index == nil then
		table.insert(lst, elem)
	else
		table.insert(lst, index, elem)
	end
end
local all = function (lst)
	local index = 0
	local count = #lst

	return function ()
		index = index + 1

		if index <= count then
			return lst[index]
		end
	end
end
local del = function (lst, elem)
	if not lst then
		return
	end
	for i, v in ipairs(lst) do
		if v == elem then
			table.remove(lst, i)

			return
		end
	end
end
local foreach = function (lst, pred)
	for _, elem in ipairs(lst) do
		pred(elem)
	end
end

--[[ Graphics. ]]

local _circ, _rect = circ, rect
local circ = function (x, y, r, col)
	_circ(x, y, r, false, col)
end
local circfill = function (x, y, r, col)
	_circ(x, y, r, true, col)
end
local rect = function (x0, y0, x1, y1, col)
	_rect(x0, y0, x1, y1, false, col)
end
local rectfill = function (x0, y0, x1, y1, col)
	_rect(x0, y0, x1, y1, true, col)
end

-- Prefilled color values.
local _palettes = {
	Color.new(0,   0,   0,   255), Color.new(29,  43,  83,  255), Color.new(126, 37,  83,  255), Color.new(0,   135, 81,  255),
	Color.new(171, 82,  54,  255), Color.new(95,  87,  79,  255), Color.new(194, 195, 199, 255), Color.new(255, 241, 232, 255),
	Color.new(255, 0,   77,  255), Color.new(255, 163, 0,   255), Color.new(255, 236, 39,  255), Color.new(0,   228, 54,  255),
	Color.new(41,  173, 255, 255), Color.new(131, 118, 156, 255), Color.new(255, 119, 168, 255), Color.new(255, 204, 170, 255)
}
local C = function (index)
	return _palettes[index + 1]
end
