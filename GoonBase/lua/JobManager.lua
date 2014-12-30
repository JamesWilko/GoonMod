----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( JobManager )

Hooks:RegisterHook("JobManagerOnSetNextInteruptStage")
function JobManager.set_next_interupt_stage(self, interupt)
	self.orig.set_next_interupt_stage(self, interupt)
	Hooks:Call("JobManagerOnSetNextInteruptStage", self, interupt)
end
-- END OF FILE
