
TweakData.orig = {}
TweakData.orig.init = TweakData.init

Hooks:RegisterHook("TweakDataPostInit")
function TweakData.init(this)
	this.orig.init(this)
	Hooks:Call("TweakDataPostInit")
end
