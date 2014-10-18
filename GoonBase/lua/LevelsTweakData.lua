----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( LevelsTweakData )

Hooks:RegisterHook("LevelsTweakDataInit")
function LevelsTweakData.init(self)
	self.orig.init(self)
	Hooks:Call("LevelsTweakDataInit", self)
end

-- END OF FILE
