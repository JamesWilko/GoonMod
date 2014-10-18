----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( JobManager )

Hooks:RegisterHook("JobManagerOnSetNextInteruptStage")
function JobManager.set_next_interupt_stage(self, interupt)
	self.orig.set_next_interupt_stage(self, interupt)
	Hooks:Call("JobManagerOnSetNextInteruptStage", self, interupt)
end

-- END OF FILE
