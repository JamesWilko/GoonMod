----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuSetup )

Hooks:RegisterHook("MenuUpdate")
function MenuSetup.update(self, t, dt)
	self.orig.update(self, t, dt)
	Hooks:Call("MenuUpdate", t, dt)
end

Hooks:RegisterHook("SetupOnQuit")
function MenuSetup.quit(self)
	Hooks:Call("SetupOnQuit", self)
	return self.orig.quit(self)
end
-- END OF FILE
