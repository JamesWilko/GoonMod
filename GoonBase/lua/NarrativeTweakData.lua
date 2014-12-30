----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NarrativeTweakData )

Hooks:RegisterHook("NarrativeTweakDataInit")
function NarrativeTweakData.init(self)
	self.orig.init(self)
	Hooks:Call("NarrativeTweakDataInit", self)
end
-- END OF FILE
