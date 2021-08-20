--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Event = class({
	_events = nil,

	ctor = function (self)
	end,

	__tostring = function (self)
		return 'Event'
	end,

	on = function (self, event, handler)
		if not event then
			return self
		end
		if self._events == nil then
			self._events = { }
		end
		if self._events[event] == nil then
			self._events[event] = { }
		end
		if exists(self._events[event], handler) then
			error('Event handler already exists.')
		end
		table.insert(self._events[event], handler)

		return self
	end,
	off = function (self, event, handler)
		if not event then
			return self
		end
		if self._events == nil then
			return self
		end
		if self._events[event] == nil then
			return self
		end
		if handler then
			remove(self._events[event], handler)
		else
			self._events[event] = nil
		end
		if not next(self._events) then
			self._events = nil
		end

		return self
	end,

	trigger = function (self, event, ...)
		if not event then
			return nil
		end
		if self._events == nil then
			return nil
		end
		if self._events[event] == nil then
			return nil
		end
		if #self._events[event] == 1 then
			local ret = self._events[event][1](self, ...)

			return ret
		else
			local ret = { }
			for i, h in ipairs(self._events[event]) do
				table.insert(ret, h(self, ...) or false)
			end

			return table.unpack(ret)
		end
	end
})
