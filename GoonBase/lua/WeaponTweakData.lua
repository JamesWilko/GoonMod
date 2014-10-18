----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( WeaponTweakData )

Hooks:RegisterHook("WeaponTweakDataInitNewWeapons")
function WeaponTweakData._init_new_weapons(self, ...)
	self.orig._init_new_weapons(self, arg)
	Hooks:Call("WeaponTweakDataInitNewWeapons")
end

-- END OF FILE
