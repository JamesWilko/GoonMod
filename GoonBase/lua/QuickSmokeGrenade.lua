----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( QuickSmokeGrenade )

Hooks:RegisterHook( "QuickSmokeGrenadeActivate" )
function QuickSmokeGrenade.activate(this, pos, duration)
	this.orig.activate(this, pos, duration)
	Hooks:Call("QuickSmokeGrenadeActivate", this, pos, duration)
end

Hooks:RegisterHook( "QuickSmokeGrenadeDetonate" )
function QuickSmokeGrenade.detonate(this)
	this.orig.detonate(this)
	Hooks:Call("QuickSmokeGrenadeDetonate", this)
end

-- END OF FILE
