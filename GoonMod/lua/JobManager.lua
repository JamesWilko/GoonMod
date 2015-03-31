
CloneClass( JobManager )

Hooks:RegisterHook("JobManagerOnSetNextInteruptStage")
function JobManager.set_next_interupt_stage(self, interupt)
	self.orig.set_next_interupt_stage(self, interupt)
	Hooks:Call("JobManagerOnSetNextInteruptStage", self, interupt)
end
