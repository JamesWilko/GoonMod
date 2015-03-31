
CloneClass( NarrativeTweakData )

Hooks:RegisterHook("NarrativeTweakDataInit")
function NarrativeTweakData.init(self)
	self.orig.init(self)
	Hooks:Call("NarrativeTweakDataInit", self)
end
