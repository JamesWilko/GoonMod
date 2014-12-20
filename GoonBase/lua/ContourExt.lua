----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( ContourExt )

Hooks:RegisterHook("ContourExtPreInitialize")
Hooks:RegisterHook("ContourExtPostInitialize")
function ContourExt.init(self, unit)
	Hooks:Call("ContourExtPreInitialize", self, unit)
	self.orig.init(self, unit)
	Hooks:Call("ContourExtPostInitialize", self, unit)
end

Hooks:RegisterHook("ContourExtPreAdd")
function ContourExt.add(self, type, sync, multiplier)
	local r = Hooks:ReturnCall("ContourExtPreAdd", self, type, sync, multiplier)
	if r ~= nil then
		return
	end
	return self.orig.add(self, type, sync, multiplier)
end

-- END OF FILE
