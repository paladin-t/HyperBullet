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

require 'libs/beCompilers/beCompilers'

-- Helper functions.
local function merge(first, second)
	if first == nil and second == nil then
		return nil
	end
	local result = { }
	if first then
		for k, v in pairs(first) do
			result[k] = v
		end
	end
	if second then
		for k, v in pairs(second) do
			result[k] = v
		end
	end

	return result
end

-- Compile the particle system implementation.
local chunk, env = beCompilers.compileLuax(
	-- Implementation source.
	-- Credits:
	--   pico-ps created by Maxwell Dexter
	--     https://github.com/MaxwellDexter/pico-ps
	--     https://maxwelldexter.itch.io/pico-ps
	'libs/beParticles/pico-ps.lua',
	-- Custom environment.
	{
		print = print, warn = warn, error = error,
		ipairs = ipairs, pairs = pairs,
		getmetatable = getmetatable, setmetatable = setmetatable,
		math = math, table = table,
		Color = Color,
		DateTime = DateTime,
		circ = circ, rect = rect, spr = spr
	}
)
-- Inject the particle system to global scope.
chunk()

--[[
Exporting.
]]

beParticles = merge(
	{
		version = '1.0.1',

		setup = function ()
			local now = DateTime.toSeconds(DateTime.ticks())
			env.prev_time = now
			env.delta_time = now - env.prev_time
		end
	},
	env
)
