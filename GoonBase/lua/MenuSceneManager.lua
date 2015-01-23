----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/4/2015 2:00:55 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuSceneManager )

Hooks:RegisterHook("MenuSceneManagerSpawnedItemWeapon")
function MenuSceneManager.spawn_item_weapon(self, factory_id, blueprint, texture_switches)
	local unit = self.orig.spawn_item_weapon(self, factory_id, blueprint, texture_switches)
	Hooks:Call("MenuSceneManagerSpawnedItemWeapon", factory_id, blueprint, texture_switches, unit)
	return unit
end

Hooks:RegisterHook("MenuSceneManagerOverrideSceneTemplate")
function MenuSceneManager.set_scene_template(self, template, data, custom_name, skip_transition)
	local r = Hooks:ReturnCall("MenuSceneManagerOverrideSceneTemplate", self, template, data, custom_name, skip_transition)
	if r then
		template = r
	end
	self.orig.set_scene_template(self, template, data, custom_name, skip_transition)
end
-- END OF FILE
