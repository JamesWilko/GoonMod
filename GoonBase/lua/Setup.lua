----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( Setup )

Hooks:RegisterHook("SetupOnQuit")
function Setup.quit(self)
	Hooks:Call("SetupOnQuit", self)
	return self.orig.quit(self)
end
-- END OF FILE
