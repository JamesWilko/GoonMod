----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/3/2014 6:23:30 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GameSetup )

Hooks:RegisterHook("GameSetupUpdate")
function GameSetup.update(this, t, dt)
	Hooks:Call("GameSetupUpdate", t, dt)
	return this.orig.update(this, t, dt)
end

-- END OF FILE
