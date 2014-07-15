
CloneClass( QuickSmokeGrenade )

QuickSmokeGrenade.waypoint = "GoonHUDGrenadeWaypoint_"

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

Hooks:Add( "QuickSmokeGrenadeActivate", "QuickSmokeGrenadeActivate_Marker", function( this, pos, duration )

	if GoonHUD.Options.EnemyManager.ShowGrenadeMarker then
		this.grenadeID = tostring(math.random(0, 10000))
		managers.hud:add_waypoint(
			QuickSmokeGrenade.waypoint .. this.grenadeID,
			{ icon = 'pd2_kill', distance = true, position = pos, no_sync = false, present_timer = 0, state = "present", radius = 100, color = Color.yellow, blend_mode = "add" } 
		)
	end

end )

Hooks:Add( "QuickSmokeGrenadeDetonate", "QuickSmokeGrenadeDetonate_Marker", function( this )

	if GoonHUD.Options.EnemyManager.ShowGrenadeMarker then
		managers.hud:remove_waypoint( QuickSmokeGrenade.waypoint .. this.grenadeID )
	end

end )
