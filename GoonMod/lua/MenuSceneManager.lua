
CloneClass( MenuSceneManager )

Hooks:RegisterHook("MenuSceneManagerSpawnedItemWeapon")
function MenuSceneManager.spawn_item_weapon(self, factory_id, blueprint, cosmetics, texture_switches, custom_data)
	local unit = self.orig.spawn_item_weapon(self, factory_id, blueprint, cosmetics, texture_switches, custom_data)
	Hooks:Call("MenuSceneManagerSpawnedItemWeapon", self, factory_id, blueprint, cosmetics, texture_switches, custom_data, unit)
	return unit
end

Hooks:RegisterHook("MenuSceneManagerSpawnedMeleeWeapon")
function MenuSceneManager.spawn_melee_weapon_clbk(self, melee_weapon_id)
	local unit = self.orig.spawn_melee_weapon_clbk(self, melee_weapon_id)
	Hooks:Call("MenuSceneManagerSpawnedMeleeWeapon", self, melee_weapon_id, unit)
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
