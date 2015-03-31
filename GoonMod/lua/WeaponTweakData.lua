
CloneClass( WeaponTweakData )

Hooks:RegisterHook("WeaponTweakDataPostInitPlayerWeaponData")
function WeaponTweakData._init_data_player_weapons(self, tweak_data)
	self.orig._init_data_player_weapons(self, tweak_data)
	Hooks:Call("WeaponTweakDataPostInitPlayerWeaponData", self, tweak_data)
end
