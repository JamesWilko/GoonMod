----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( BlackMarketTweakData )

Hooks:RegisterHook("BlackMarketTweakDataPostInitGrenades")
function BlackMarketTweakData._init_grenades(self)
	self.orig._init_grenades(self)
	Hooks:Call("BlackMarketTweakDataPostInitGrenades", self)
end

-- END OF FILE
