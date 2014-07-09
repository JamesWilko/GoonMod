
CloneClass( PrePlanningManager )

function PrePlanningManager._current_location_data(this)
	local data = this.orig._current_location_data(this)
	return data
end
