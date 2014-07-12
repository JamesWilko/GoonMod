
CloneClass( QuickSmokeGrenade )

QuickSmokeGrenade.waypoint = "GoonHUDGrenadeWaypoint_"

function QuickSmokeGrenade.activate(this, pos, duration)

	this.orig.activate(this, pos, duration)
	if GoonHUD.Options.EnemyManager.UseDefaultGrenadeTimer == false then
		this._timer = 2
	end

	if GoonHUD.Options.EnemyManager.ShowGrenadeMarker then
		this.grenadeID = tostring(math.random(0, 10000))
		managers.hud:add_waypoint(
			QuickSmokeGrenade.waypoint .. this.grenadeID,
			{ icon = 'pd2_kill', distance = true, position = pos, no_sync = false, present_timer = 0, state = "present", radius = 100, color = Color.yellow, blend_mode = "add" } 
		)
	end

end

function QuickSmokeGrenade.detonate(this)
	if GoonHUD.Options.EnemyManager.ShowGrenadeMarker then
		managers.hud:remove_waypoint( QuickSmokeGrenade.waypoint .. this.grenadeID )
	end
	this.orig.detonate(this)
end
