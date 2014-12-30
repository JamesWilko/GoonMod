----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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
