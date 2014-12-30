----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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
