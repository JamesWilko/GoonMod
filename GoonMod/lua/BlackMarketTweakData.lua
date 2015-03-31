
CloneClass( BlackMarketTweakData )

Hooks:RegisterHook("BlackMarketTweakDataPostInitGrenades")
function BlackMarketTweakData._init_grenades(self)
	self.orig._init_grenades(self)
	Hooks:Call("BlackMarketTweakDataPostInitGrenades", self)
end
