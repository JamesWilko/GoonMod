----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GameSetup )

Hooks:RegisterHook("GameSetupUpdate")
function GameSetup.update(this, t, dt)
	this.orig.update(this, t, dt)
	Hooks:Call("GameSetupUpdate", t, dt)
end

-- END OF FILE
