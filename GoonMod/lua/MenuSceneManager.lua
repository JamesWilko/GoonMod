
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

Hooks:RegisterHook("MenuSceneManagerOnSetCharacterEquippedWeapon")
function MenuSceneManager.set_character_equipped_weapon(self, unit, factory_id, blueprint, type, cosmetics)
	self.orig.set_character_equipped_weapon(self, unit, factory_id, blueprint, type, cosmetics)
	Hooks:Call("MenuSceneManagerOnSetCharacterEquippedWeapon", self, unit, factory_id, blueprint, type, cosmetics)
end

Hooks:RegisterHook("MenuSceneManagerOnCallbackWeaponBaseUnitLoaded")
function MenuSceneManager.clbk_weapon_base_unit_loaded(self, params, status, asset_type, asset_name)
	self.orig.clbk_weapon_base_unit_loaded(self, params, status, asset_type, asset_name)
	Hooks:Call("MenuSceneManagerOnCallbackWeaponBaseUnitLoaded", self, params, status, asset_type, asset_name)
end

Hooks:RegisterHook("MenuSceneManagerOnSetCharacterOutfitVisibility")
function MenuSceneManager._set_character_and_outfit_visibility(self, char_unit, state)
	self.orig._set_character_and_outfit_visibility(self, char_unit, state)
	Hooks:Call("MenuSceneManagerOnSetCharacterOutfitVisibility", self, char_unit, state)
end
