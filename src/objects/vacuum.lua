--[[
A top-down shoot'em up game for the Bitty Engine

Copyright (C) 2020 - 2021 Tony Wang, all rights reserved

Homepage: https://paladin-t.github.io/bitty/
]]

Vacuum = class({
	--[[ Constructor. ]]

	ctor = function (self, asset, box)
		if not asset then asset = 'assets/sprites/vacuum.spr' end
		local res = Resources.load(asset)
		if not box then box = Recti.byXYWH(0, 0, 32, 32) end
		Object.ctor(self, res, box)

		self:play(
			'idle',
			false, false,
			function ()
				self:kill()

				Resources.unload(self._sprite)
				self._sprite = nil
			end
		)
	end,

	--[[ Meta methods. ]]

	__tostring = function (self)
		return 'Vacuum'
	end,

	--[[ Methods. ]]

	behave = function (self, delta, _1)
		-- Do nothing.
	end,

	update = function (self, delta)
		Object.update(self, delta, true)
	end
}, Object)
