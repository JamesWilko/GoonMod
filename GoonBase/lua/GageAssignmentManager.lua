----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GageAssignmentManager )

Hooks:RegisterHook("GageAssignmentManagerOnMissionCompleted")
function GageAssignmentManager.on_mission_completed(self)
	Hooks:Call("GageAssignmentManagerOnMissionCompleted", self)
	return self.orig.on_mission_completed(self)
end
-- END OF FILE
