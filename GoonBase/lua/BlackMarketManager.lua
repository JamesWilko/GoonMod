
CloneClass( BlackMarketManager )

local INV_TO_CRAFT = Idstring("inventory_to_crafted")
local CRAFT_TO_INV = Idstring("crafted_to_inventroy")
local INV_ADD = Idstring("add_to_inventory")
local INV_REMOVE = Idstring("remove_from_inventory")
local CRAFT_ADD = Idstring("add_to_crafted")
local CRAFT_REMOVE = Idstring("remove_from_crafted")

function BlackMarketManager.get_mods_on_weapon(self, category, slot)
	local _global = Global.blackmarket_manager
	if not _global.crafted_items[category] or not _global.crafted_items[category][slot] then
		return
	end
	return _global.crafted_items[category][slot].blueprint
end

-- Hooks:Add("TradingAttemptTradeWeapon", "TradingAttemptTradeWeapon_BlackMarketTest", function(weapon)
-- 	PrintTable( BlackMarketManager:get_mods_on_weapon(weapon.category, weapon.slot) )
-- end)

function BlackMarketManager.on_traded_weapon(self, category, slot, remove_mods, skip_verification)

	local _global = Global.blackmarket_manager
	if not _global.crafted_items[category] or not _global.crafted_items[category][slot] then
		return
	end

	local global_values = _global.crafted_items[category][slot].global_values or {}
	local blueprint = _global.crafted_items[category][slot].blueprint
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id( _global.crafted_items[category][slot].factory_id )
	
	for i, default_part in ipairs(default_blueprint) do
		table.delete(blueprint, default_part)
	end

	-- Remove mods if we traded them
	if remove_mods then

		for k, part_id in pairs(blueprint) do
			local global_value = global_values[part_id] or "normal"
			self:add_to_inventory(global_value, "weapon_mods", part_id, true)
			self:alter_global_value_item(global_value, category, slot, part_id, CRAFT_REMOVE)
		end

	end

	_global.crafted_items[category][slot] = nil
	if not skip_verification then
		self:_verfify_equipped_category(category)
		if category == "primaries" then
			self:_update_menu_scene_primary()
		elseif category == "secondaries" then
			self:_update_menu_scene_secondary()
		end

	end

end
