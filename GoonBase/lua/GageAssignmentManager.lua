----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GageAssignmentManager )

Hooks:RegisterHook("GageAssignmentManagerOnMissionCompleted")
function GageAssignmentManager.on_mission_completed(self)
	Hooks:Call("GageAssignmentManagerOnMissionCompleted", self)
	return self.orig.on_mission_completed(self)
end

-- END OF FILE
