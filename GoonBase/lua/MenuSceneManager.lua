----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuSceneManager )

Hooks:RegisterHook("MenuSceneManagerSpawnedItemWeapon")
function MenuSceneManager.spawn_item_weapon(self, factory_id, blueprint, texture_switches)
	local unit = self.orig.spawn_item_weapon(self, factory_id, blueprint, texture_switches)
	Hooks:Call("MenuSceneManagerSpawnedItemWeapon", factory_id, blueprint, texture_switches, unit)
	return unit
end
-- END OF FILE
