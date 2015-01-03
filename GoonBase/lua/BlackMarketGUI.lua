----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/4/2015 2:00:55 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( BlackMarketGui )

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.6) / 8
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size

local Localization = GoonBase.Localization
Localization.bm_menu_amount_locked = "NONE IN STOCK"

function BlackMarketGui.init(self, ws, fullscreen_ws, node)

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._node = node
	local component_data = self._node:parameters().menu_component_data

	-- Fix for custom tabs crashing inventory
	if node._parameters.name == "blackmarket" then
		component_data = nil
	end

	local do_animation = not component_data and not self._data
	local is_start_page = not component_data and true or false

	managers.menu_component:close_contract_gui()
	self:_setup(is_start_page, component_data)
	if do_animation then
		local fade_me_in_scotty = function(o)
			over(0.1, function(p)
				o:set_alpha(p)
			end
)
		end

		self._panel:animate(fade_me_in_scotty)
		self._fullscreen_panel:animate(fade_me_in_scotty)
	end
	self:set_enabled(true)

end

Hooks:RegisterHook("BlackMarketGUIPreSetup")
Hooks:RegisterHook("BlackMarketGUIPostSetup")
function BlackMarketGui._setup(self, is_start_page, component_data)

	local psuccess, perror = pcall(function()
		
		Hooks:Call("BlackMarketGUIPreSetup", self, is_start_page, component_data)
		self.orig._setup(self, is_start_page, component_data)
		Hooks:Call("BlackMarketGUIPostSetup", self, is_start_page, component_data)
		self:on_slot_selected( self._selected_slot )

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end
	
end

Hooks:RegisterHook("BlackMarketGUIOnPopulateWeapons")
Hooks:RegisterHook("BlackMarketGUIOnPopulateWeaponActionList")
function BlackMarketGui.populate_weapon_category(self, category, data)

	Hooks:Call("BlackMarketGUIOnPopulateWeapons", self, category, data)

	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	local last_weapon = table.size(crafted_category) == 1
	local last_unlocked_weapon
	if not last_weapon then

		local category_size = table.size(crafted_category)
		for i, crafted in pairs(crafted_category) do
			if not managers.blackmarket:weapon_unlocked(crafted.weapon_id) then
				category_size = category_size - 1
			end
		end

		last_unlocked_weapon = category_size == 1

	end

	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == category
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.MAX_WEAPON_ROWS or 3

	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)
	for i = 1, max_items do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local weapon_data = Global.blackmarket_manager.weapons
	local new_data = {}
	local index = 0

	for i, crafted in pairs(crafted_category) do

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.weapon[crafted.weapon_id] and tweak_data.weapon[crafted.weapon_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = crafted.weapon_id
		new_data.name_localized = managers.blackmarket:get_weapon_name_by_category_slot(category, i)
		new_data.raw_name_localized = managers.weapon_factory:get_weapon_name_by_factory_id(crafted.factory_id)
		new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name(category, i, true)
		new_data.category = category
		new_data.slot = i
		new_data.unlocked = managers.blackmarket:weapon_unlocked(crafted.weapon_id)
		new_data.level = managers.blackmarket:weapon_level(crafted.weapon_id)
		new_data.can_afford = true
		new_data.equipped = crafted.equipped
		new_data.skill_based = weapon_data[crafted.weapon_id].skill_based
		new_data.skill_name = new_data.skill_based and "bm_menu_skill_locked_" .. new_data.name
		new_data.price = managers.money:get_weapon_slot_sell_value(category, i)
		local texture_name = tweak_data.weapon[crafted.weapon_id].texture_name or tostring(crafted.weapon_id)
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/weapons/" .. texture_name
		new_data.comparision_data = new_data.unlocked and managers.blackmarket:get_weapon_stats(category, i)
		new_data.global_value = tweak_data.weapon[new_data.name] and tweak_data.weapon[new_data.name].global_value or "normal"
		new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or nil
		new_data.lock_texture = self:get_lock_icon(new_data)
		new_data.holding = currently_holding and hold_crafted_item.slot == i

		local icon_list = managers.menu_component:create_weapon_mod_icon_list(crafted.weapon_id, category, crafted.factory_id, i)
		local icon_index = 1
		local new_parts = {}
		for k, part in pairs(managers.blackmarket:get_weapon_new_part_drops(crafted.factory_id) or {}) do
			local type = tweak_data.weapon.factory.parts[part].type
			new_parts[type] = true
		end

		if table.size(new_parts) > 0 then
			new_data.new_drop_data = {}
		end

		new_data.mini_icons = {}
		for k, icon in pairs(icon_list) do
			table.insert(new_data.mini_icons, {
				texture = icon.texture,
				right = (icon_index - 1) * 18,
				bottom = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false,
				alpha = icon.equipped and 1 or 0.25
			})
			if new_parts[icon.type] then
				table.insert(new_data.mini_icons, {
					texture = "guis/textures/pd2/blackmarket/inv_mod_new",
					right = (icon_index - 1) * 18,
					bottom = 16,
					layer = 1,
					w = 16,
					h = 8,
					stream = false,
					alpha = 1
				})
			end

			icon_index = icon_index + 1
		end

		if not new_data.unlocked then
			new_data.last_weapon = last_weapon
		else
			new_data.last_weapon = last_weapon or last_unlocked_weapon
		end

		if new_data.equipped then
			self._equipped_comparision_data = self._equipped_comparision_data or {}
			self._equipped_comparision_data[category] = new_data.comparision_data
		end

		if currently_holding then
			new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_weapon")
			if new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "w_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			local has_mods = managers.weapon_factory:has_weapon_more_than_default_parts(crafted.factory_id)
			if has_mods and new_data.unlocked then
				table.insert(new_data, "w_mod")
			end

			if not new_data.last_weapon then
				table.insert(new_data, "w_sell")
			end

			if not new_data.equipped and new_data.unlocked then
				table.insert(new_data, "w_equip")
			end

			if new_data.equipped and new_data.unlocked then
				table.insert(new_data, "w_move")
			end

			table.insert(new_data, "w_preview")

			Hooks:Call("BlackMarketGUIOnPopulateWeaponActionList", self, new_data)
			
		end

		data[i] = new_data
		index = i
	end

	for i = 1, max_items do
		if not data[i] then
			local can_buy_weapon = managers.blackmarket:is_weapon_slot_unlocked(category, i)
			new_data = {}
			if can_buy_weapon then

				new_data.name = "bm_menu_btn_buy_new_weapon"
				new_data.name_localized = managers.localization:text("bm_menu_empty_weapon_slot")
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3

				if not currently_holding or not new_data.mid_text.noselected_text then
				end

				new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_new_weapon")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = category
				new_data.slot = i
				new_data.unlocked = true
				new_data.can_afford = true
				new_data.equipped = false

				if currently_holding then
					new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_weapon")
					table.insert(new_data, "w_place")
					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "ew_buy")
				end

				if managers.blackmarket:got_new_drop(new_data.category, "weapon_buy_empty", nil) then
					new_data.mini_icons = new_data.mini_icons or {}
					table.insert(new_data.mini_icons, {
						name = "new_drop",
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						right = 0,
						top = 0,
						layer = 1,
						w = 16,
						h = 16,
						stream = false,
						visible = false
					})
					new_data.new_drop_data = {}
				end

			else

				new_data.name = "bm_menu_btn_buy_weapon_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_weapon_slot")
				new_data.empty_slot = true
				new_data.category = category
				new_data.slot = i
				new_data.unlocked = true
				new_data.equipped = false
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					h = 32,
					x = 0,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_weapon_slot_price())
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				new_data.mid_text.is_lock_same_color = true

				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color
					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_weapon_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_weapon_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2
					table.insert(new_data, "ew_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_weapon_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_weapon_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end

			end

			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMeleeWeapons")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMeleeWeaponActionList")
function BlackMarketGui.populate_melee_weapons(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateMeleeWeapons", self, data)

	local new_data = {}
	local sort_data = {}
	local xd, yd, x_td, y_td, x_sn, y_sn, x_gv, y_gv
	local m_tweak_data = tweak_data.blackmarket.melee_weapons
	local l_tweak_data = tweak_data.lootdrop.global_values
	local global_value

	for id, d in pairs(Global.blackmarket_manager.melee_weapons) do
		global_value = tweak_data.blackmarket.melee_weapons[id].dlc or tweak_data.blackmarket.melee_weapons[id].global_value or "normal"
		if d.unlocked or d.equipped or not tweak_data:get_raw_value("lootdrop", "global_values", global_value, "hide_unavailable") then
			table.insert(sort_data, {id, d})
		end
	end

	table.sort(sort_data, function(x, y)

		xd = x[2]
		yd = y[2]
		x_td = m_tweak_data[x[1]]
		y_td = m_tweak_data[y[1]]

		if not xd.is_favorite ~= not yd.is_favorite then
			return xd.is_favorite
		end
		if xd.unlocked ~= yd.unlocked then
			return xd.unlocked
		end
		if x_td.instant ~= y_td.instant then
			return x_td.instant
		end
		if xd.skill_based ~= yd.skill_based then
			return xd.skill_based
		end
		if x_td.free ~= y_td.free then
			return x_td.free
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = l_tweak_data[x_gv]
		y_sn = l_tweak_data[y_gv]
		x_sn = x_sn and x_sn.sort_number or 1
		y_sn = y_sn and y_sn.sort_number or 1

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end
		if xd.level ~= yd.level then
			return xd.level < yd.level
		end

		return x[1] < y[1]

	end)

	local max_items = math.ceil(#sort_data / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)
	local index = 0
	local guis_catalog, m_tweak_data, melee_weapon_id

	for i = 1, max_items do
		data[i] = nil
	end

	for i, melee_weapon_data in ipairs(sort_data) do

		melee_weapon_id = melee_weapon_data[1]
		m_tweak_data = tweak_data.blackmarket.melee_weapons[melee_weapon_data[1]] or {}
		guis_catalog = "guis/"

		local bundle_folder = m_tweak_data.texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = melee_weapon_id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.melee_weapons[new_data.name].name_id)
		new_data.category = "melee_weapons"
		new_data.slot = i
		new_data.unlocked = melee_weapon_data[2].unlocked
		new_data.equipped = melee_weapon_data[2].equipped
		new_data.level = melee_weapon_data[2].level
		new_data.stream = true
		new_data.global_value = m_tweak_data.dlc or "normal"
		new_data.skill_based = melee_weapon_data[2].skill_based
		new_data.skill_name = "bm_menu_skill_locked_" .. new_data.name

		if m_tweak_data and m_tweak_data.locks then

			local dlc = m_tweak_data.locks.dlc
			local achievement = m_tweak_data.locks.achievement
			local saved_job_value = m_tweak_data.locks.saved_job_value
			local level = m_tweak_data.locks.level
			new_data.dlc_based = true
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_community")
			if achievement and managers.achievment:get_info(achievement) and not managers.achievment:get_info(achievement).awarded then
				new_data.dlc_locked = "menu_bm_achievement_locked_" .. tostring(achievement)
			elseif dlc and not managers.dlc:is_dlc_unlocked(dlc) then
				new_data.dlc_locked = tweak_data.lootdrop.global_values[dlc] and tweak_data.lootdrop.global_values[dlc].unlock_id or "bm_menu_dlc_locked"
			else
				new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			end

		else
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. tostring(new_data.name)

		if melee_weapon_id == "weapon" then
			new_data.extra_bitmaps = {}
			new_data.extra_bitmaps_shape = {}
			local primary = managers.blackmarket:equipped_primary()
			local primary_id = primary.weapon_id
			guis_catalog = "guis/"
			local bundle_folder = tweak_data.weapon[primary_id] and tweak_data.weapon[primary_id].texture_bundle_folder
			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end
			table.insert(new_data.extra_bitmaps, guis_catalog .. "textures/pd2/blackmarket/icons/weapons/" .. tostring(primary_id))
			table.insert(new_data.extra_bitmaps_shape, {
				x = 0,
				y = -0.1,
				w = 0.75,
				h = 0.75
			})
			local secondary = managers.blackmarket:equipped_secondary()
			local secondary_id = secondary.weapon_id
			guis_catalog = "guis/"
			local bundle_folder = tweak_data.weapon[secondary_id] and tweak_data.weapon[secondary_id].texture_bundle_folder
			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end
			table.insert(new_data.extra_bitmaps, guis_catalog .. "textures/pd2/blackmarket/icons/weapons/" .. tostring(secondary_id))
			table.insert(new_data.extra_bitmaps_shape, {
				x = 0,
				y = 0.1,
				w = 0.75,
				h = 0.75
			})
		end

		if managers.blackmarket:got_new_drop("normal", "melee_weapons", melee_weapon_id) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				"normal",
				"melee_weapons",
				melee_weapon_id
			}
		end

		if new_data.unlocked then
			new_data.comparision_data = managers.blackmarket:get_melee_weapon_stats(melee_weapon_id)
		end
		if new_data.unlocked and not new_data.equipped then
			table.insert(new_data, "lo_mw_equip")
		end
		if new_data.unlocked and data.allow_preview and m_tweak_data.unit then
			table.insert(new_data, "lo_mw_preview")
		end

		Hooks:Call("BlackMarketGUIOnPopulateMeleeWeaponActionList", self, new_data)

		data[i] = new_data
		index = i

	end

	for i = 1, max_items do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = "melee_weapons"
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end
	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMasksActionList")
function BlackMarketGui.populate_masks(self, data)

	local success, err = pcall(function()

	Hooks:Call("BlackMarketGUIOnPopulateMasks", self, data)

	local NOT_WIN_32 = SystemInfo:platform() ~= Idstring("WIN32")
	local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.6) / 8

	local new_data = {}
	local crafted_category = managers.blackmarket:get_crafted_category("masks") or {}
	local mini_icon_helper = math.round((self._panel:h() - (tweak_data.menu.pd2_medium_font_size + 10) - 60) * GRID_H_MUL / 3) - 16
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local start_crafted_item = data.start_crafted_item or 1
	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == "masks"
	local max_rows = tweak_data.gui.MAX_MASK_ROWS
	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)
	for i = 1, max_items do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local index = 0
	for i, crafted in pairs(crafted_category) do

		index = i - start_crafted_item + 1
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.masks[crafted.mask_id] and tweak_data.blackmarket.masks[crafted.mask_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = crafted.mask_id
		new_data.name_localized = managers.blackmarket:get_mask_name_by_category_slot("masks", i)
		new_data.raw_name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name("masks", i, true)
		new_data.custom_name_text_right = crafted.modded and -55 or -20
		new_data.custom_name_text_width = crafted.modded and 0.6
		new_data.category = "masks"
		new_data.global_value = crafted.global_value
		new_data.slot = i
		new_data.unlocked = true
		new_data.equipped = crafted.equipped
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. new_data.name
		new_data.stream = false
		new_data.holding = currently_holding and hold_crafted_item.slot == i
		local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:has_dlc(new_data.global_value)
		local locked_parts = {}
		if not is_locked then
			for part, type in pairs(crafted.blueprint) do
				if tweak_data.lootdrop.global_values[part.global_value] and tweak_data.lootdrop.global_values[part.global_value].dlc and not tweak_data.dlc[part.global_value].free and not managers.dlc:has_dlc(part.global_value) then
					locked_parts[type] = part.global_value
					is_locked = true
				end
			end
		end

		if is_locked then
			new_data.unlocked = false
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		if currently_holding then
			if i ~= 1 then
				new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_mask")
			end

			if i ~= 1 and new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "m_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			if new_data.unlocked then
				if not new_data.equipped then
					table.insert(new_data, "m_equip")
					if GoonBase.Options.Trading ~= nil and GoonBase.Options.Trading.Enabled then
						table.insert(new_data, "m_trade")
					end
				end

				if i ~= 1 and new_data.equipped then
					table.insert(new_data, "m_move")
				end

				if not crafted.modded and managers.blackmarket:can_modify_mask(i) and i ~= 1 then
					table.insert(new_data, "m_mod")
				end

				if i ~= 1 then
					table.insert(new_data, "m_preview")
				end

			end

			Hooks:Call("BlackMarketGUIOnPopulateMasksActionList", self, new_data)

			if i ~= 1 then
				if 0 < managers.money:get_mask_sell_value(new_data.name, new_data.global_value) then
					table.insert(new_data, "m_sell")
				else
					table.insert(new_data, "m_remove")
				end

			end

		end

		if crafted.modded then
			new_data.mini_icons = {}
			local color_1 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[1]
			local color_2 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[2]
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 0,
				bottom = 0,
				layer = 1,
				color = color_2
			})
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 18,
				bottom = 0,
				layer = 1,
				color = color_1
			})
			if locked_parts.color then
				local texture = self:get_lock_icon({
					global_value = locked_parts.color
				})
				table.insert(new_data.mini_icons, {
					texture = texture,
					w = 32,
					h = 32,
					right = 2,
					bottom = -5,
					layer = 2,
					color = tweak_data.screen_colors.important_1
				})
			end

			local pattern = crafted.blueprint.pattern.id
			if pattern == "solidfirst" or pattern == "solidsecond" then
			else
				local material_id = crafted.blueprint.material.id
				guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket.materials[material_id] and tweak_data.blackmarket.materials[material_id].texture_bundle_folder
				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				local right = -3
				local bottom = 38 - (NOT_WIN_32 and 20 or 10)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. material_id,
					right = right,
					bottom = bottom,
					w = w,
					h = h,
					layer = 1,
					stream = true
				})
				if locked_parts.material then
					local texture = self:get_lock_icon({
						global_value = locked_parts.material
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			do
				local right = -3
				local bottom = math.round(mini_icon_helper - 6 - 6 - 42)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = tweak_data.blackmarket.textures[pattern].texture,
					right = right,
					bottom = bottom,
					w = h,
					h = w,
					layer = 1,
					stream = true,
					render_template = Idstring("VertexColorTexturedPatterns")
				})
				if locked_parts.pattern then
					local texture = self:get_lock_icon({
						global_value = locked_parts.pattern
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			new_data.mini_icons.borders = true
		elseif i ~= 1 and managers.blackmarket:can_modify_mask(i) and managers.blackmarket:got_new_drop("normal", "mask_mods", crafted.mask_id) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false,
				visible = true
			})
			new_data.new_drop_data = {}
		end

		data[index] = new_data

	end

	local can_buy_masks = true
	for i = 1, max_items do
		if not data[i] then
			index = i + start_crafted_item - 1
			can_buy_masks = managers.blackmarket:is_mask_slot_unlocked(i)
			new_data = {}
			if can_buy_masks then
				new_data.name = "bm_menu_btn_buy_new_mask"
				new_data.name_localized = managers.localization:text("bm_menu_empty_mask_slot")
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				if not currently_holding or not new_data.mid_text.noselected_text then
				end

				new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_new_mask")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.cannot_buy = not can_buy_masks
				if currently_holding then
					if i ~= 1 then
						new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_mask")
					end

					if i ~= 1 then
						table.insert(new_data, "m_place")
					end

					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "em_buy")
				end

				if index ~= 1 and managers.blackmarket:got_new_drop(nil, "mask_buy", nil) then
					new_data.mini_icons = new_data.mini_icons or {}
					table.insert(new_data.mini_icons, {
						name = "new_drop",
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						right = 0,
						top = 0,
						layer = 1,
						w = 16,
						h = 16,
						stream = false,
						visible = false
					})
					new_data.new_drop_data = {}
				end

			else
				new_data.name = "bm_menu_btn_buy_mask_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_mask_slot")
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					h = 32,
					x = 0,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_mask_slot_price())
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				new_data.mid_text.is_lock_same_color = true
				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color
					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_mask_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2
					table.insert(new_data, "em_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end

			end

			data[i] = new_data
		end

	end

	end)

	if not success then Print(err) end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateModsActionList")
function BlackMarketGui.populate_mods(self, data)

	local success, err = pcall(function()

	Hooks:Call("BlackMarketGUIOnPopulateMods", self, data)

	local new_data = {}
	local default_mod = data.on_create_data.default_mod
	local global_values = managers.blackmarket:get_crafted_category(data.prev_node_data.category)[data.prev_node_data.slot].global_values or {}
	local gvs = {}
	local mod_t = {}
	local num_steps = #data.on_create_data
	local achievement_tracker = tweak_data.achievement.weapon_part_tracker
	local guis_catalog = "guis/"

	for index, mod_t in ipairs(data.on_create_data) do

		local mod_name = mod_t[1]
		local mod_default = mod_t[2]
		local mod_global_value = mod_t[3] or "normal"
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.weapon_mods[mod_name] and tweak_data.blackmarket.weapon_mods[mod_name].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = mod_name or data.prev_node_data.name
		if not mod_name or not managers.weapon_factory:get_part_name_by_part_id(mod_name) then
		end

		new_data.name_localized = managers.weapon_factory:get_part_name_by_part_id(mod_name)
		new_data.category = data.prev_node_data.category
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/mods/" .. new_data.name
		new_data.slot = not data.slot and data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = mod_global_value
		new_data.unlocked = mod_default or managers.blackmarket:get_item_amount(new_data.global_value, "weapon_mods", new_data.name, true)
		new_data.equipped = false
		new_data.stream = true
		new_data.default_mod = default_mod
		new_data.is_internal = tweak_data.weapon.factory:is_part_internal(new_data.name)
		new_data.free_of_charge = tweak_data.blackmarket.weapon_mods[mod_name] and tweak_data.blackmarket.weapon_mods[mod_name].is_a_unlockable
		new_data.unlock_tracker = achievement_tracker[new_data.name] or false
		if tweak_data.lootdrop.global_values[mod_global_value] and tweak_data.lootdrop.global_values[mod_global_value].dlc and not tweak_data.dlc[mod_global_value].free and not managers.dlc:has_dlc(mod_global_value) then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.unlocked = new_data.unlocked ~= 0 and new_data.unlocked or false
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		local weapon_id = managers.blackmarket:get_crafted_category(new_data.category)[new_data.slot].weapon_id
		new_data.price = managers.money:get_weapon_modify_price(weapon_id, new_data.name, new_data.global_value)
		new_data.can_afford = managers.money:can_afford_weapon_modification(weapon_id, new_data.name, new_data.global_value)
		local font, font_size
		local no_upper = false
		if not new_data.lock_texture and (not new_data.unlocked or new_data.unlocked == 0) then
			local selected_text, noselected_text
			if not new_data.dlc_locked and new_data.unlock_tracker then
				local text_id = "bm_menu_no_items"
				local progress = ""
				local stat = new_data.unlock_tracker.stat or false
				local max_progress = new_data.unlock_tracker.max_progress or 0
				local award = new_data.unlock_tracker.award or false
				if new_data.unlock_tracker.text_id then
					if max_progress > 0 and stat then
						local progress_left = max_progress - (managers.achievment:get_stat(stat) or 0)
						if progress_left > 0 then
							progress = tostring(progress_left)
							text_id = new_data.unlock_tracker.text_id
							font = small_font
							font_size = small_font_size
							no_upper = true
						end

					elseif award then
						local achievement = managers.achievment:get_info(award)
						text_id = new_data.unlock_tracker.text_id
						font = small_font
						font_size = small_font_size
						no_upper = true
					end

					selected_text = managers.localization:text(text_id, {progress = progress})
				end

			end

			selected_text = selected_text or managers.localization:text("bm_menu_no_items")
			noselected_text = selected_text
			new_data.mid_text = {}
			new_data.mid_text.selected_text = selected_text
			new_data.mid_text.selected_color = tweak_data.screen_colors.text
			new_data.mid_text.noselected_text = noselected_text
			new_data.mid_text.noselected_color = tweak_data.screen_colors.text
			new_data.mid_text.vertical = "center"
			new_data.mid_text.font = font
			new_data.mid_text.font_size = font_size
			new_data.mid_text.no_upper = no_upper
			new_data.lock_texture = true
		end

		if mod_name then
			local forbid = managers.blackmarket:can_modify_weapon(new_data.category, new_data.slot, new_data.name)
			if forbid then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				else
					new_data.unlocked = false
				end

				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
				new_data.mid_text = nil
				new_data.conflict = managers.localization:text("bm_menu_" .. tostring(tweak_data.weapon.factory.parts[forbid].type))
			end

			local weapon = managers.blackmarket:get_crafted_category_slot(data.prev_node_data.category, data.prev_node_data.slot) or {}
			local gadget
			local mod_type = tweak_data.weapon.factory.parts[new_data.name].type
			local sub_type = tweak_data.weapon.factory.parts[new_data.name].sub_type
			local is_auto = weapon and tweak_data.weapon[weapon.weapon_id] and tweak_data.weapon[weapon.weapon_id].FIRE_MODE == "auto"
			if mod_type == "gadget" then
				gadget = sub_type
			end

			local silencer = sub_type == "silencer" and true
			local texture = managers.menu_component:get_texture_from_mod_type(mod_type, sub_type, gadget, silencer, is_auto)
			new_data.desc_mini_icons = {}
			if DB:has(Idstring("texture"), texture) then
				table.insert(new_data.desc_mini_icons, {
					texture = texture,
					right = 0,
					bottom = 0,
					w = 16,
					h = 16
				})
			end

			local is_gadget = false
			if not new_data.conflict and new_data.unlocked and not is_gadget and not new_data.dlc_locked then
				new_data.comparision_data = managers.blackmarket:get_weapon_stats_with_mod(new_data.category, new_data.slot, mod_name)
			end

			if managers.blackmarket:got_new_drop(mod_global_value, "weapon_mods", mod_name) then
				new_data.mini_icons = new_data.mini_icons or {}
				table.insert(new_data.mini_icons, {
					name = "new_drop",
					texture = "guis/textures/pd2/blackmarket/inv_newdrop",
					right = 0,
					top = 0,
					layer = 1,
					w = 16,
					h = 16,
					stream = false
				})
				new_data.new_drop_data = {
					new_data.global_value or "normal",
					"weapon_mods",
					mod_name
				}
			end

		end

		if mod_name and new_data.unlocked then
			if type(new_data.unlocked) ~= "number" or new_data.unlocked > 0 then
				if new_data.can_afford then
					table.insert(new_data, "wm_buy")
				end

				table.insert(new_data, "wm_preview")
				if not new_data.is_internal then
					table.insert(new_data, "wm_preview_mod")
				end

			else
				table.insert(new_data, "wm_preview")
			end

		end

		Hooks:Call("BlackMarketGUIOnPopulateModsActionList", self, new_data)

		data[index] = new_data

	end

	for i = 1, math.max(math.ceil(num_steps / 3), 3) * 3 do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

	local weapon_blueprint = managers.blackmarket:get_weapon_blueprint(data.prev_node_data.category, data.prev_node_data.slot) or {}
	local equipped
	for i, mod in ipairs(data) do
		for k, weapon_mod in ipairs(weapon_blueprint) do

			if mod.name == weapon_mod and (not global_values[weapon_mod] or global_values[weapon_mod] == data[i].global_value) then
				equipped = i
			end

		end
	end

	if equipped then

		data[equipped].equipped = true
		data[equipped].unlocked = data[equipped].unlocked or true
		data[equipped].mid_text = nil
		data[equipped].lock_texture = nil

		for i = 1, #data[equipped] do
			table.remove(data[equipped], 1)
		end

		data[equipped].price = 0
		data[equipped].can_afford = true

		table.insert(data[equipped], "wm_remove_buy")

		if not data[equipped].is_internal then
			table.insert(data[equipped], "wm_remove_preview_mod")
			table.insert(data[equipped], "wm_remove_preview")
		else
			table.insert(data[equipped], "wm_preview")
		end

		local factory = tweak_data.weapon.factory.parts[data[equipped].name]
		if data.name == "sight" and factory and factory.texture_switch then

			table.insert(data[equipped], "wm_reticle_switch_menu")
			local reticle_texture = managers.blackmarket:get_part_texture_switch(data[equipped].category, data[equipped].slot, data[equipped].name)
			if reticle_texture and reticle_texture ~= "" then
				data[equipped].mini_icons = data[equipped].mini_icons or {}
				table.insert(data[equipped].mini_icons, {
					texture = reticle_texture,
					right = 1,
					bottom = 1,
					layer = 2,
					w = 30,
					h = 30,
					stream = true,
					blend_mode = "add"
				})
				table.insert(data[equipped].mini_icons, {
					color = Color.black,
					right = -5,
					bottom = -5,
					layer = 0,
					alpha = 0.4,
					w = 42,
					h = 42,
					borders = true
				})
			end

		end

		if not data[equipped].conflict then

			if data[equipped].default_mod then
				data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_with_mod(data[equipped].category, data[equipped].slot, data[equipped].default_mod)
			else
				data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_without_mod(data[equipped].category, data[equipped].slot, data[equipped].name)
			end

		end

	end

	end)
	if not success then Print("[Error] " .. err) end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskModsActionList")
function BlackMarketGui.populate_choose_mask_mod(self, data)

	local success, err = pcall(function()

	Hooks:Call("BlackMarketGUIOnPopulateMaskMods", self, data)

	local new_data = {}
	local index = 1
	local equipped_mod = managers.blackmarket:customize_mask_category_id(data.category)
	local guis_catalog = "guis/"

	for k, mods in pairs(data.on_create_data) do

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket[data.category][mods.id] and tweak_data.blackmarket[data.category][mods.id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = mods.id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket[data.category][new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = index
		new_data.prev_slot = data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = mods.default or mods.amount
		new_data.amount = mods.amount or 0
		new_data.equipped = equipped_mod == mods.id
		new_data.equipped_text = managers.localization:text("bm_menu_chosen")
		new_data.mods = mods
		new_data.stream = data.category ~= "colors"
		new_data.global_value = mods.global_value
		local is_locked = false
		if new_data.amount < 1 and mods.id ~= "plastic" and mods.id ~= "no_color_full_material" and not mods.free_of_charge then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.lock_texture = true
			new_data.dlc_locked = "bm_menu_amount_locked"
			is_locked = true
		end
		if tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not tweak_data.dlc[new_data.global_value].free and not managers.dlc:has_dlc(new_data.global_value) then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			is_locked = true
		end

		if data.category == "colors" then
			new_data.bitmap_texture = "guis/textures/pd2/blackmarket/icons/colors/color_bg"
			new_data.extra_bitmaps = {}
			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_02")
			table.insert(new_data.extra_bitmaps, "guis/textures/pd2/blackmarket/icons/colors/color_01")
			new_data.extra_bitmaps_colors = {}
			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.name].colors[2])
			table.insert(new_data.extra_bitmaps_colors, tweak_data.blackmarket.colors[new_data.name].colors[1])
		elseif data.category == "textures" then
			new_data.bitmap_texture = tweak_data.blackmarket[data.category][mods.id].texture
			new_data.render_template = Idstring("VertexColorTexturedPatterns")
		else
			new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. new_data.name
			if mods.bitmap_texture_override then
				new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. mods.bitmap_texture_override
			end
		end

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", new_data.category, new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				new_data.global_value or "normal",
				new_data.category,
				new_data.name
			}
		end

		new_data.btn_text_params = {
			type = managers.localization:text("bm_menu_" .. data.category)
		}
		if not is_locked then

			table.insert(new_data, "mp_choose")
			table.insert(new_data, "mp_preview")

		end

		if managers.blackmarket:can_finish_customize_mask() and managers.blackmarket:can_afford_customize_mask() then
			table.insert(new_data, "mm_buy")
		end

		Hooks:Call("BlackMarketGUIOnPopulateMaskModsActionList", self, new_data)

		data[index] = new_data
		index = index + 1

	end

	if #data == 0 then
		new_data = {}
		new_data.name = "bm_menu_nothing"
		new_data.empty_slot = true
		new_data.category = data.category
		new_data.slot = 1
		new_data.unlocked = true
		new_data.can_afford = true
		new_data.equipped = false
		data[1] = new_data
	end

	local max_mask_mods = #data.on_create_data
	for i = 1, math.ceil(max_mask_mods / data.override_slots[1]) * data.override_slots[1] do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

	end)
	if not success then Print("[Error] " .. err) end

end


Hooks:RegisterHook("BlackMarketGUIStartPageData")
function BlackMarketGui._start_page_data(self)

	local data = {}
	table.insert(data, {
		name = "bm_menu_primaries",
		category = "primaries",
		on_create_func_name = "populate_primaries",
		identifier = self.identifiers.weapon,
		override_slots = {3, 3}
	})
	table.insert(data, {
		name = "bm_menu_secondaries",
		category = "secondaries",
		on_create_func_name = "populate_secondaries",
		identifier = self.identifiers.weapon,
		override_slots = {3, 3}
	})
	table.insert(data, {
		name = "bm_menu_melee_weapons",
		category = "melee_weapons",
		on_create_func_name = "populate_melee_weapons",
		allow_preview = true,
		override_slots = {3, 3},
		identifier = Idstring("melee_weapon")
	})
	table.insert(data, {
		name = "bm_menu_armors",
		category = "armors",
		on_create_func_name = "populate_armors",
		override_slots = {4, 2},
		identifier = self.identifiers.armor
	})
	table.insert(data, {
		name = "bm_menu_deployables",
		category = "deployables",
		on_create_func_name = "populate_deployables",
		override_slots = {4, 2},
		identifier = Idstring("deployable")
	})
	table.insert(data, {
		name = "bm_menu_masks",
		category = "masks",
		on_create_func_name = "populate_masks",
		identifier = self.identifiers.mask,
		override_slots = {3, 3},
		start_crafted_item = 1
	})
	if not managers.network:session() then
		table.insert(data, {
			name = "bm_menu_characters",
			category = "characters",
			on_create_func_name = "populate_characters",
			override_slots = {4, 2},
			identifier = self.identifiers.character
		})
	end

	Hooks:Call("BlackMarketGUIStartPageData", self, data)

	data.topic_id = "menu_inventory"
	self:_cleanup_blackmarket()
	return data

end

Hooks:RegisterHook("BlackMarketGUIUpdateInfoText")
function BlackMarketGui.update_info_text(self)
	self.orig.update_info_text(self)
	Hooks:Call("BlackMarketGUIUpdateInfoText", self)
end

function BlackMarketGui._update_info_text(self, slot_data, updated_texts, data, scale_override)

	local ignore_lock = false
	local is_renaming_this = false
	if data ~= nil then
		ignore_lock = data.ignore_lock or ignore_lock
		is_renaming_this = data.is_renaming_this or is_renaming_this
	end

	if self._desc_mini_icons then
		for _, gui_object in pairs(self._desc_mini_icons) do
			self._panel:remove(gui_object[1])
		end
	end
	self._desc_mini_icons = {}
	local desc_mini_icons = self._slot_data.desc_mini_icons
	local info_box_panel = self._panel:child("info_box_panel")
	if desc_mini_icons and 0 < table.size(desc_mini_icons) then
		for _, mini_icon in pairs(desc_mini_icons) do
			local new_icon = self._panel:bitmap({
				texture = mini_icon.texture,
				x = info_box_panel:left() + 10 + mini_icon.right,
				w = mini_icon.w or 32,
				h = mini_icon.h or 32
			})
			table.insert(self._desc_mini_icons, {new_icon, 1})
		end
		updated_texts[2].text = string.rep("     ", table.size(desc_mini_icons)) .. updated_texts[2].text
	else
	end
	if not ignore_lock and slot_data.lock_texture and slot_data.lock_texture ~= true then
		local new_icon = self._panel:bitmap({
			texture = slot_data.lock_texture,
			x = info_box_panel:left() + 10,
			w = 20,
			h = 20,
			color = self._info_texts[3]:color(),
			blend_mode = "add"
		})
		updated_texts[3].text = "     " .. updated_texts[3].text
		table.insert(self._desc_mini_icons, {new_icon, 2})
	else
	end
	if is_renaming_this and self._rename_info_text then
		local text = self._renaming_item.custom_name ~= "" and self._renaming_item.custom_name or "##" .. tostring(slot_data.raw_name_localized) .. "##"
		updated_texts[self._rename_info_text].text = text
		updated_texts[self._rename_info_text].resource_color = tweak_data.screen_colors.text:with_alpha(0.35)
	end
	for id, _ in ipairs(self._info_texts) do
		self:set_info_text(id, updated_texts[id].text, updated_texts[id].resource_color)
	end
	local _, _, _, th = self._info_texts[1]:text_rect()
	self._info_texts[1]:set_h(th)
	local y = self._info_texts[1]:bottom()
	local title_offset = y
	local bg = self._info_texts_bg[1]
	if alive(bg) then
		bg:set_shape(self._info_texts[1]:shape())
	end
	local below_y
	for i = 2, #self._info_texts do
		local info_text = self._info_texts[i]
		info_text:set_font_size(small_font_size)
		_, _, _, th = info_text:text_rect()
		info_text:set_y(y)
		info_text:set_h(th)
		if updated_texts[i].below_stats then
			if slot_data.comparision_data and alive(self._stats_text_modslist) then
				info_text:set_world_y(below_y or self._stats_text_modslist:world_top())
				below_y = (below_y or info_text:world_y()) + th
			else
				info_text:set_top((below_y or info_text:top()) + 20)
				below_y = (below_y or info_text:top()) + th
			end
		end
		local scale = 1
		if info_text:bottom() > self._info_texts_panel:h() then
			scale = self._info_texts_panel:h() / info_text:bottom()
		end

		if scale_override then
			if type(scale_override) == "number" then
				scale = scale_override
			end
			if type(scale_override) == "table" then
				scale = scale_override[i]
			end
		end

		info_text:set_font_size(small_font_size * scale)
		_, _, _, th = info_text:text_rect()
		info_text:set_h(th)
		local bg = self._info_texts_bg[i]
		if alive(bg) then
			bg:set_shape(info_text:shape())
		end
		y = info_text:bottom()
	end
	for _, desc_mini_icon in ipairs(self._desc_mini_icons) do
		desc_mini_icon[1]:set_y(title_offset)
		desc_mini_icon[1]:set_world_top(self._info_texts[desc_mini_icon[2]]:world_bottom() + (2 - (desc_mini_icon[2] - 1) * 3))
	end
	if is_renaming_this and self._rename_info_text and self._rename_caret then
		local info_text = self._info_texts[self._rename_info_text]
		local x, y, w, h = info_text:text_rect()
		if self._renaming_item.custom_name == "" then
			w = 0
		end
		self._rename_caret:set_w(2)
		self._rename_caret:set_h(h)
		self._rename_caret:set_world_position(x + w, y)
	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasksActionList")
function BlackMarketGui.populate_buy_mask(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateBuyMasks", self, data)

	local new_data = {}
	local guis_catalog = "guis/"
	local max_masks = #data.on_create_data

	for i = 1, max_masks do
		data[i] = nil
	end

	for i = 1, #data.on_create_data do

		guis_catalog = "guis/"

		local bundle_folder = tweak_data.blackmarket.masks[data.on_create_data[i].mask_id] and tweak_data.blackmarket.masks[data.on_create_data[i].mask_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = data.on_create_data[i].mask_id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = data.on_create_data[i].global_value
		new_data.unlocked = managers.blackmarket:get_item_amount(new_data.global_value, "masks", new_data.name, true) or 0
		new_data.equipped = false
		new_data.num_backs = data.prev_node_data.num_backs + 1
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. new_data.name
		new_data.stream = false

		if not new_data.global_value then
			Application:debug("BlackMarketGui:populate_buy_mask( data ) Missing global value on mask", new_data.name)
		end

		if tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not tweak_data.dlc[new_data.global_value].free and not managers.dlc:has_dlc(new_data.global_value) then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		if tweak_data.blackmarket.masks[new_data.name].infamy_lock then

			local infamy_lock = tweak_data.blackmarket.masks[new_data.name].infamy_lock
			local is_unlocked = managers.infamy:owned(infamy_lock)
			if not is_unlocked then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				end
				new_data.lock_texture = "guis/textures/pd2/lock_infamy"
				new_data.infamy_lock = infamy_lock
			end

		end

		if new_data.unlocked and new_data.unlocked > 0 then

			table.insert(new_data, "bm_buy")
			table.insert(new_data, "bm_preview")
			if 0 < managers.money:get_mask_sell_value(new_data.name, new_data.global_value) then
				table.insert(new_data, "bm_sell")
			end

		else

			new_data.mid_text = ""
			new_data.lock_texture = new_data.lock_texture or true

		end

		Hooks:Call("BlackMarketGUIOnPopulateBuyMasksActionList", self, new_data)

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", "masks", new_data.name) then

			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				new_data.global_value or "normal",
				"masks",
				new_data.name
			}

		end

		data[i] = new_data

	end

	local max_page = data.override_slots[1] * data.override_slots[2]
	for i = 1, math.max(math.ceil(max_masks / data.override_slots[1]) * data.override_slots[1], max_page) do

		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIChooseMaskPartCallback")
function BlackMarketGui.choose_mask_part_callback(self, data)
	local r = Hooks:ReturnCall("BlackMarketGUIChooseMaskPartCallback", self, data)
	if r then
		return
	end
	return self.orig.choose_mask_part_callback(self, data)
end

Hooks:RegisterHook("BlackMarketGUIMouseReleased")
function BlackMarketGui.mouse_released(self, o, button, x, y)
	if not self._enabled then
		return
	end
	self.orig.mouse_released(self, o, button, x, y)
	Hooks:Call("BlackMarketGUIMouseReleased", self, o, button, x, y)
end

Hooks:RegisterHook("BlackMarketGUIOnPreviewWeapon")
function BlackMarketGui._preview_weapon(self, data)
	self.orig._preview_weapon(self, data)
	Hooks:Call("BlackMarketGUIOnPreviewWeapon", self, data)
end
-- END OF FILE
