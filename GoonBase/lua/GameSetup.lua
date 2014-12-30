----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GameSetup )

Hooks:RegisterHook("GameSetupUpdate")
function GameSetup.update(this, t, dt)
	Hooks:Call("GameSetupUpdate", t, dt)
	return this.orig.update(this, t, dt)
end
-- END OF FILE
