----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( WeaponTweakData )

Hooks:RegisterHook("WeaponTweakDataInitNewWeapons")
function WeaponTweakData._init_new_weapons(self, ...)
	self.orig._init_new_weapons(self, arg)
	Hooks:Call("WeaponTweakDataInitNewWeapons")
end
-- END OF FILE
