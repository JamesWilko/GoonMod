----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
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
