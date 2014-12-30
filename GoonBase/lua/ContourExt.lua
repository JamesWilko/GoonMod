----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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
