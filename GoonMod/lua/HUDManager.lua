
CloneClass( HUDManager )

Hooks:RegisterHook("HUDManagerPreAddWaypoint")
function HUDManager.add_waypoint(self, id, data)
	local r = Hooks:ReturnCall("HUDManagerPreAddWaypoint", self, id, data)
	if r then
		return
	end
	return self.orig.add_waypoint(self, id, data)
end

Hooks:RegisterHook("HUDManagerPreAddNameLabel")
function HUDManager._add_name_label(self, data)
	Hooks:Call("HUDManagerPreAddNameLabel", self, data)
	return self.orig._add_name_label(self, data)
end
