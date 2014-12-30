----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( BlackMarketTweakData )

Hooks:RegisterHook("BlackMarketTweakDataPostInitGrenades")
function BlackMarketTweakData._init_grenades(self)
	self.orig._init_grenades(self)
	Hooks:Call("BlackMarketTweakDataPostInitGrenades", self)
end
-- END OF FILE
