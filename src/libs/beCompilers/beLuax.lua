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

--[[
Functions.
]]

local function trim(str)
	return str:match'^%s*(.*%S)' or ''
end

--[[
Compiler.
]]

-- Compiles Luax source code to regular Lua from an asset.
local function compile(asset)
	-- Prepare.
	if not asset then
		error('Invalid asset.')
	end

	-- Read source.
	local bytes = Project.main:read(asset)
	if not bytes then
		error('Invalid asset.')
	end
	bytes:poke(1)
	local src = bytes:readString()

	-- Read compatibility layer.
	bytes = Project.main:read('libs/beCompilers/beLuax_Compatible.lua')
	if not bytes then
		error('Invalid asset.')
	end
	bytes:poke(1)
	local com = bytes:readString()

	-- Compile source.
	local dst = ''
	for ln in src:gmatch('([^\n]*)\n?') do
		if #ln > 0 then
			ln = ln:gsub('\'', '"')
			local inc, dec =
				ln:find('+='), ln:find('-=')
			if inc then
				local head = ln:sub(1, inc - 1)
				local tail = ln:sub(inc + 2)
				local token = trim(head)
				ln = head .. '= ' .. token .. ' +' .. tail -- Concat parts.
			elseif dec then
				local head = ln:sub(1, dec - 1)
				local tail = ln:sub(dec + 2)
				local token = trim(head)
				ln = head .. '= ' .. token .. ' -' .. tail -- Concat parts.
			end
			dst = dst .. ln .. '\n'                        -- Concat lines.
		else
			dst = dst .. ln .. '\n'
		end
	end

	-- Finish.
	local full = com .. '\n' .. dst

	return load(full, asset) -- Return loaded and parsed Lua chunk.
end

--[[
Exporting.
]]

return {
	compile = compile
}
