----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/3/2014 6:23:30 PM
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
