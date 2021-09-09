--[[
A top-down shoot'em up game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

--[[ Maths. ]]

function NaN(val)
	return 0 / 0
end

function isNaN(val)
	return val ~= val
end

function sign(val)
	if val > 0 then
		return 1
	elseif val < 0 then
		return -1
	else
		return 0
	end
end

function round(val)
	if val >= 0 then
		return math.floor(val + 0.5)
	else
		return math.ceil(val - 0.5)
	end
end

function clamp(val, min, max)
	if val < min then
		val = min
	elseif val > max then
		val = max
	end

	return val
end

function lerp(val1, val2, factor)
	return val1 + (val2 - val1) * factor
end

--[[ String. ]]

function startsWith(str, part)
	return part == '' or string.sub(str, 1, #part) == part
end

function endsWith(str, part)
	return part == '' or string.sub(str, -#part) == part
end

function format(key, ...)
	local fmt = key
	if fmt == nil then
		return nil
	end

	local args = table.pack(...)
	for i = 1, #args do
		fmt = fmt:gsub('%' .. '{' .. tostring(i) .. '}', tostring(args[i]))
	end

	return fmt
end

function characters(str)
	if not str then
		return nil, nil, nil
	end
	local tbl = { }
	for _, cp in utf8.codes(str) do
		local ch = utf8.char(cp)
		table.insert(tbl, ch)
	end
	local next_ = function (tbl, i)
		i = i + 1
		local v = tbl[i]
		if v ~= nil then
			return i, v
		end
	end

	return next_, tbl, 0
end

--[[ List. ]]

function car(lst)
	if not lst or #lst == 0 then
		return nil
	end

	return lst[1]
end

function cdr(lst)
	if not lst or #lst == 0 then
		return { }
	end
	lst = table.pack(table.unpack(lst))
	table.remove(lst, 1)

	return lst
end

function rep(elem, n)
	local result = { }
	for i = 1, n, 1 do
		table.insert(result, elem)
	end

	return result
end

function concat(first, second)
	if first == nil and second == nil then
		return nil
	end
	local result = { }
	if first ~= nil then
		for _, v in ipairs(first) do
			table.insert(result, v)
		end
	end
	if second ~= nil then
		for _, v in ipairs(second) do
			table.insert(result, v)
		end
	end

	return result
end

function indexOf(lst, elem)
	if not lst then
		return -1
	end
	for i, v in ipairs(lst) do
		if v == elem then
			return i
		end
	end

	return -1
end

function exists(lst, elem)
	if not lst then
		return false
	end
	for _, v in ipairs(lst) do
		if v == elem then
			return true
		end
	end

	return false
end

function remove(lst, elem)
	if not lst then
		return false
	end
	for i, v in ipairs(lst) do
		if v == elem then
			table.remove(lst, i)

			return true
		end
	end

	return false
end

function clear(lst)
	if not lst then
		return
	end
	while #lst > 0 do
		table.remove(lst)
	end
end

function once(lst, idx)
	local item = lst[idx]
	table.remove(lst, idx)

	return item, idx
end

function any(lst, random)
	if not lst or #lst == 0 then
		return nil, nil
	end
	local idx = 0
	if random then
		idx = random:next(#lst)
	else
		idx = math.random(#lst)
	end
	local item = lst[idx]

	return item, idx
end

function anyOnce(lst, random)
	if not lst or #lst == 0 then
		return nil, nil
	end
	local idx = 0
	if random then
		idx = random:next(#lst)
	else
		idx = math.random(#lst)
	end

	return once(lst, idx)
end

function shuffle(lst, random)
	local result = concat(lst, nil)
	for i = 1, #result do
		local idx1, idx2 = 0, 0
		if random then
			idx1 = random:next(#lst)
			idx2 = random:next(#lst)
		else
			idx1 = math.random(#lst)
			idx2 = math.random(#lst)
		end
		result[idx1], result[idx2] = result[idx2], result[idx1]
	end

	return result
end

function associate(lst, pred)
	if not lst then
		return nil
	end
	local result = { }
	for i, v in ipairs(lst) do
		local key, val = pred(v, i)
		if key ~= nil and val ~= nil then
			result[key] = val
		end
	end

	return result
end

function transform(lst, pred)
	if not lst then
		return nil
	end
	local result = { }
	for i, v in ipairs(lst) do
		table.insert(result, pred(v, i))
	end

	return result
end

function reduce(lst, pred, initial)
	if not lst then
		return nil
	end
	local result = initial
	for i, v in ipairs(lst) do
		result = pred(v, i, result)
	end

	return result
end

function filter(lst, pred)
	if not lst then
		return nil
	end
	local result = { }
	for _, v in ipairs(lst) do
		if pred and pred(v) then
			table.insert(result, v)
		elseif not pred and not v then
			return { }
		end
	end

	return result
end

function find(lst, pred, proc)
	if not lst then
		return nil, nil
	end
	for i, v in ipairs(lst) do
		if pred and pred(v) then
			if proc then
				proc(v, i)
			end

			return v, i
		end
	end

	return nil, nil
end

function forEach(lst, pred)
	if not lst or not pred then
		return
	end
	for i, v in ipairs(lst) do
		if pred then
			pred(v, i)
		end
	end
end

function take(lst, n)
	local result = { }
	if lst ~= nil then
		for i = 1, math.min(#lst, n) do
			table.insert(result, lst[i])
		end
	end

	return result
end

function skip(lst, n)
	local result = { }
	if lst ~= nil then
		for i = n + 1, math.min(#lst) do
			table.insert(result, lst[i])
		end
	end

	return result
end

--[[ Dictionary. ]]

function clone(dict)
	if dict == nil then
		return nil
	end
	local result = { }
	if dict then
		for k, v in pairs(dict) do
			result[k] = v
		end
	end

	return result
end

function merge(first, second)
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

function flat(dict, pred)
	if not dict then
		return nil
	end
	local result = { }
	for k, v in pairs(dict) do
		local val = pred(k, v)
		if val ~= nil then
			table.insert(result, val)
		end
	end

	return result
end

--[[ Misc. ]]

if not DEBUG then
	function assert(cond, msg)
		if not cond then
			warn(msg)
		end
	end
end
