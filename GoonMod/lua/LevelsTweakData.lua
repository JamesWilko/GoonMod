
CloneClass( LevelsTweakData )

Hooks:RegisterHook("LevelsTweakDataInit")
function LevelsTweakData.init(self)
	self.orig.init(self)
	Hooks:Call("LevelsTweakDataInit", self)
end
