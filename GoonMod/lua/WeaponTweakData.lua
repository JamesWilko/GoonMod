
CloneClass( WeaponTweakData )

Hooks:RegisterHook("WeaponTweakDataInitNewWeapons")
function WeaponTweakData._init_new_weapons(self, ...)
	self.orig._init_new_weapons(self, arg)
	Hooks:Call("WeaponTweakDataInitNewWeapons")
end
