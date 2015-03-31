
CloneClass( SkillTreeManager )

Hooks:RegisterHook("SkillTreeManagerPreInfamyReset")
function SkillTreeManager.infamy_reset(self)
	Hooks:Call("SkillTreeManagerPreInfamyReset", self)
	self.orig.infamy_reset(self)
end
