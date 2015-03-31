
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
