----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CriminalsManager )

Hooks:Call("CriminalsManagerNumberOfTakenCriminals")
function CriminalsManager.nr_taken_criminals(self)
	local orig = self.orig.nr_taken_criminals(self)
	local r = Hooks:ReturnCall("CriminalsManagerNumberOfTakenCriminals", self)
	if r ~= nil then
		return r
	end
	return orig
end
-- END OF FILE
