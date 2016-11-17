
CloneClass( BlackMarketTweakData )

Hooks:RegisterHook("BlackMarketTweakDataPostInitWeaponSkins")
function BlackMarketTweakData._init_weapon_skins(self)
	self.orig._init_weapon_skins(self)
	Hooks:Call("BlackMarketTweakDataPostInitWeaponSkins", self)
end
