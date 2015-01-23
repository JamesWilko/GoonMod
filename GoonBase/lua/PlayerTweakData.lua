CloneClass( PlayerTweakData )

Hooks:RegisterHook("PlayerTweakDataPostInit")
function PlayerTweakData.init(this)
    this.orig.init(this)
    Hooks:Call("PlayerTweakDataPostInit", this)
end
