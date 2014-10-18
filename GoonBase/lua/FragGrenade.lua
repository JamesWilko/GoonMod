----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( FragGrenade )

Hooks:RegisterHook("FragGrenadePostInit")
function FragGrenade.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("FragGrenadePostInit", self, unit)	
end

Hooks:RegisterHook("FragGrenadeDetonate")
function FragGrenade._detonate(self)
	self._detonate(self)
	Hooks:Call("FragGrenadeDetonate")
end

-- END OF FILE
