----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

TweakData.orig = {}
TweakData.orig.init = TweakData.init

Hooks:RegisterHook("TweakDataPostInit")
function TweakData.init(this)
	this.orig.init(this)
	Hooks:Call("TweakDataPostInit")
end

-- END OF FILE
