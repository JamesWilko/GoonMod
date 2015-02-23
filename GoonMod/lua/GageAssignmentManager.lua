
CloneClass( GageAssignmentManager )

Hooks:RegisterHook("GageAssignmentManagerOnMissionCompleted")
function GageAssignmentManager.on_mission_completed(self)
	Hooks:Call("GageAssignmentManagerOnMissionCompleted", self)
	return self.orig.on_mission_completed(self)
end
