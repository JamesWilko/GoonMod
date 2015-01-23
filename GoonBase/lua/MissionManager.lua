Hooks:RegisterHook("ClientMissionElementPost")
function MissionManager:to_server_area_event(event_id, id, unit)
   this.orig.to_server_area_event(id, unit, orientation_element_index)
   Hooks:Call("ClientMissionElementPost", this, event_id, id, unit)
end
