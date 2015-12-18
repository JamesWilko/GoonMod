
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "BlackmarketModShop"
Mod.Name = "Gage's Mod Shop"
Mod.Desc = "Gage will sell you weapon parts, masks, and mask customization items in return for Gage Coins"
Mod.Requirements = { "ExtendedInventory", "GageCoins" }
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mod Shop
_G.GoonBase.ModShop = _G.GoonBase.ModShop or {}
local ModShop = _G.GoonBase.ModShop
local ExtendedInv = _G.GoonBase.ExtendedInventory

ModShop.PurchaseCurrency = "gage_coin"
ModShop.CostRegular = 1
ModShop.CostInfamous = 3
ModShop.MaskPricing = {
	["default"] = 5,
	["dlc"] = 5,
	["normal"] = 5,
	["pd2_clan"] = 3,
	["halloween"] = 8,
	["infamous"] = 20,
	["infamy"] = 20,
}

ModShop.ExclusionList = {
	["nothing"] = true,
	["no_color_no_material"] = true,
	["no_color_full_material"] = true,
	["plastic"] = true,
	["character_locked"] = true,
}

ModShop.NonDLCGlobalValues = {
	["normal"] = true,
	["pd2_clan"] = true,
	["halloween"] = true,
	["infamous"] = true,
	["infamy"] = true,
}

ModShop.MaskMods = {
	["materials"] = true,
	["textures"] = true,
	["colors"] = true,
}

ModShop.NamePriceOverrides = {
	["wpn_fps_upg_"] = 5,
}

function ModShop:IsItemExluded( item )
	return ModShop.ExclusionList[item] or false
end

function ModShop:IsGlobalValueDLC( gv )
	if not ModShop.NonDLCGlobalValues[gv] then
		return true
	end
	return false
end

function ModShop:IsInfamyLocked( data )

	local infamy_lock = data.tweak_data.infamy_lock
	if infamy_lock then
		local is_unlocked = managers.infamy:owned(infamy_lock)
		if not is_unlocked then
			return true
		end
	end

	return false

end

function ModShop:IsItemMaskMod( item )
	return ModShop.MaskMods[item.category] or false
end

function ModShop:GetItemPrice( data )

	if data.category == "masks" then
		local gv = self:IsGlobalValueDLC( data.global_value ) and "dlc" or data.global_value
		return ModShop.MaskPricing[ gv ]
	end

	if data.global_value == "infamy" or data.global_value == "infamous" then
		return ModShop.CostInfamous
	end

	for pattern, cost_override in pairs(self.NamePriceOverrides) do
		if data.name and string.find(data.name, pattern) then
			return cost_override
		end
	end

	return ModShop.CostRegular

end

function ModShop:_ReloadBlackMarket()
	local blackmarket_gui = managers.menu_component._blackmarket_gui
	if blackmarket_gui then
		blackmarket_gui:reload()
		blackmarket_gui:on_slot_selected( blackmarket_gui._selected_slot )
	end
end

function ModShop:AttemptItemPurchase( data, weapon_part )

	if not data then
		return
	end

	local verified, purchase_data = self:VerifyItemPurchase( data, weapon_part )
	if verified then
		if purchase_data.price <= GoonBase.ExtendedInventory:GetItem( ModShop.PurchaseCurrency ).amount then
			self:ShowItemPurchaseMenu( purchase_data )
		else
			self:ShowItemCannotAffordMenu( purchase_data )
		end
	end

end

function ModShop:VerifyItemPurchase( data, weapon_part )

	if not data then
		return
	end

	local name = data.name
	local category = weapon_part and "parts" or data.category

	local entry
	if weapon_part then
		entry = tweak_data:get_raw_value("weapon", "factory", category, name)
	else
		entry = tweak_data:get_raw_value("blackmarket", category, name)
	end

	if not entry then
		local str = "[Error] Could not retrieve tweak_data for {1} item '{2}', weapon_part: {3}"
		str = str:gsub("{1}", tostring(category))
		str = str:gsub("{2}", tostring(name))
		str = str:gsub("{3}", tostring(weapon_part or false))
		Print(str)
		return
	end

	local global_value = entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"
	local purchase_data = {
		name = data.name,
		name_localized = data.name_localized,
		category = weapon_part and "weapon_mods" or data.category,
		is_weapon_part = weapon_part,
		bitmap_texture = data.bitmap_texture,
		global_value = global_value,
		tweak_data = entry,
		price = 1,
	}
	purchase_data.price = self:GetItemPrice( purchase_data )

	if self:IsItemExluded( purchase_data.name ) then
		return false
	end

	if self:IsGlobalValueDLC( purchase_data.global_value ) and not managers.dlc:is_dlc_unlocked( purchase_data.global_value ) then
		return false
	end

	if self:IsInfamyLocked( purchase_data ) then
		return false
	end

	for k, v in pairs( tweak_data.dlc ) do
		if v.achievement_id ~= nil and v.content ~= nil and v.content.loot_drops ~= nil then
			for i, loot in pairs( v.content.loot_drops ) do
				if loot.item_entry ~= nil and loot.item_entry == purchase_data.name and loot.type_items == purchase_data.category then

					if not managers.achievment.handler:has_achievement(v.achievement_id) then

						local achievement_tracker = tweak_data.achievement[ purchase_data.is_weapon_part and "weapon_part_tracker" or "mask_tracker" ]
						local achievement_progress = achievement_tracker[purchase_data.name]
						if achievement_progress then
							return false
						end

						if not purchase_data.is_weapon_part then
							return false
						end
						
					end

				end
			end
		end
	end

	if purchase_data.tweak_data.is_a_unlockable then
		return false
	end

	return true, purchase_data

end

function ModShop:ShowItemPurchaseMenu( purchase_data )

	local currency_name = GoonBase.ExtendedInventory:GetItem( ModShop.PurchaseCurrency ).name
	local title = managers.localization:text("gm_gms_purchase_window_title")
	local message = managers.localization:text("gm_gms_purchase_window_message")
	message = message:gsub("{1}", purchase_data.name_localized)
	message = message:gsub("{2}", tostring(purchase_data.price))
	message = message:gsub("{3}", managers.localization:text(currency_name) .. (purchase_data.price > 1 and "s" or ""))

	local dialog_data = {}
	dialog_data.title = title
	dialog_data.text = message
	dialog_data.id = "gms_purchase_item_window"

	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_yes")
	ok_button.callback_func = callback( self, self, "_PurchaseItem", purchase_data )

	local cancel_button = {}
	cancel_button.text = managers.localization:text("dialog_no")
	cancel_button.cancel_button = true

	dialog_data.button_list = {ok_button, cancel_button}
	dialog_data.purchase_data = purchase_data
	managers.system_menu:show( dialog_data )

end

function ModShop:ShowItemCannotAffordMenu( purchase_data )

	local currency_name = GoonBase.ExtendedInventory:GetItem( ModShop.PurchaseCurrency ).name
	local title = managers.localization:text("gm_gms_purchase_failed")
	local message = managers.localization:text("gm_gms_cannot_afford_message")
	message = message:gsub("{1}", purchase_data.name_localized)
	message = message:gsub("{2}", tostring(purchase_data.price))
	message = message:gsub("{3}", managers.localization:text(currency_name) .. (purchase_data.price > 1 and "s" or ""))

	local dialog_data = {}
	dialog_data.title = title
	dialog_data.text = message
	dialog_data.id = "gms_purchase_item_window"

	local cancel_button = {}
	cancel_button.text = managers.localization:text("dialog_ok")
	cancel_button.cancel_button = true

	dialog_data.button_list = { cancel_button }
	managers.system_menu:show( dialog_data )

end


function ModShop:_PurchaseItem( purchase_data )

	if not purchase_data then
		return
	end

	local name = purchase_data.name
	local category = purchase_data.category
	local global_value = purchase_data.global_value
	local price = purchase_data.price

	log(string.format( "Purchased item with gage-coins:\n\tItem name: %s\n\tCategory: %s", tostring(name), tostring(category) ))
	managers.blackmarket:add_to_inventory(global_value, category, name, true)

	ExtendedInv:TakeItem( ModShop.PurchaseCurrency, price )

	-- Record mask mods that were purchased so we can immediately add them to the gui when it reloads
	if self:IsItemMaskMod( purchase_data ) then
		self._purchased_mask_mods = ModShop._purchased_mask_mods or {}
		self._purchased_mask_mods[category] = self._purchased_mask_mods[category] or {}
		table.insert(self._purchased_mask_mods[category], name)
	end

	self:_ReloadBlackMarket()
	if Global.wallet_panel then
		WalletGuiObject.refresh()
	end

end

-- Hooks
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_" .. Mod:ID(), function(gui, is_start_page, component_data)

	gui.modshop_purchase_weaponmod_callback = function(self, data)
		ModShop:AttemptItemPurchase( data, true )
	end

	gui.modshop_purchase_mask_callback = function(self, data)
		ModShop:AttemptItemPurchase( data )
	end

	gui.modshop_purchase_mask_part_callback = function(self, data)
		ModShop:AttemptItemPurchase( data )
	end

	local wm_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = Idstring("toggle_chat"),
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_weaponmod_callback")
	}

	local bm_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = Idstring("toggle_chat"),
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_mask_callback")
	}

	local mp_modshop = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = Idstring("toggle_chat"),
		name = "gm_gms_purchase",
		callback = callback(gui, gui, "modshop_purchase_mask_part_callback")
	}

	local btn_x = 10
	gui._btns["wm_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, wm_modshop, btn_x)
	gui._btns["bm_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, bm_modshop, btn_x)
	gui._btns["mp_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, mp_modshop, btn_x)

end)

Hooks:Add("BlackMarketGUIOnPopulateModsActionList", "BlackMarketGUIOnPopulateModsActionList_" .. Mod:ID(), function(gui, data)
	if ModShop:VerifyItemPurchase( data, true ) then
		table.insert(data, "wm_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateBuyMasksActionList", "BlackMarketGUIOnPopulateBuyMasksActionList_" .. Mod:ID(), function(gui, data)
	if ModShop:VerifyItemPurchase( data, false ) then
		table.insert(data, "bm_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateMaskModsActionList", "BlackMarketGUIOnPopulateMaskModsActionList_" .. Mod:ID(), function(gui, data)
	if ModShop:VerifyItemPurchase( data, false ) then
		table.insert(data, "mp_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateMaskMods", "BlackMarketGUIOnPopulateMaskMods_" .. Mod:ID(), function(gui, data)

	local category = data.category

	-- If we've purchased an item from this category then forcefully add that item when we force reload the gui
	-- That way we don't have to stop customizing the mask and reload the gui for it to appear anymore
	if data.on_create_data and ModShop._purchased_mask_mods and ModShop._purchased_mask_mods[category] then

		for k, v in pairs( ModShop._purchased_mask_mods[category] ) do

			for i, mods in pairs(data.on_create_data) do
				if mods.id == v then
					mods.amount = mods.amount + 1
				end
			end

		end

		ModShop._purchased_mask_mods[category] = nil

		-- Search compatibility, repopulate our inventory and then re-filter it
		if gui._search_bar and gui._search_bar:has_search() then
			gui._search_bar:do_search()
		end

	end

end)

Hooks:Add("BlackMarketManagerModifyGetInventoryCategory", "BlackMarketManagerModifyGetInventoryCategory_" .. Mod:ID(), function(blackmarket, category, data)

	local blackmarket_table = {}
	for k, v in pairs( tweak_data.blackmarket[category] ) do

		local already_in_table = blackmarket_table[v.id]
		for x, y in pairs( data ) do
			blackmarket_table[y.id] = true
			if y.id == k then
				already_in_table = true
			end
		end

		local global_value = v.infamous and "infamous" or v.global_value or v.dlc or v.dlcs and v.dlcs[math.random(#v.dlcs)] or "normal"
		if not already_in_table and not ModShop:IsItemExluded(k) then
			
			local add_item = true
			if ModShop:IsGlobalValueDLC( global_value ) and not managers.dlc:is_dlc_unlocked( global_value ) then
				add_item = false
			end

			if add_item then
				local item_data = {
					id = k,
					global_value = global_value,
					amount = 0
				}
				table.insert(data, item_data)
			end

		end
		
	end

end)
