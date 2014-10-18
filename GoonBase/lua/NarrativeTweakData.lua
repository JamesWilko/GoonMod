----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NarrativeTweakData )

Hooks:RegisterHook("NarrativeTweakDataInit")
function NarrativeTweakData.init(self)
	self.orig.init(self)
	Hooks:Call("NarrativeTweakDataInit", self)
end

-- END OF FILE
