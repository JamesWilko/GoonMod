
CloneClass( SkillTreeTweakData )

Hooks:RegisterHook("SkillTreeTweakDataPostInit")
function SkillTreeTweakData.init( self )
	self.orig.init( self )
	Hooks:Call("SkillTreeTweakDataPostInit", self)
end
