----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/4/2015 2:00:55 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local WeaponCustomization = GoonBase.WeaponCustomization
local Localization = GoonBase.Localization
Localization.WeaponCustomization_MenuItem = "Customize Weapon"
Localization.bm_menu_customize_weapon_title = "Customize Weapon: $weapon_name"

Localization.wc_modifying_parts = "Modifying Parts"
Localization.wc_not_modifying_parts = "Not Modifying Parts"
Localization.wc_highlighted_mod = "Highlighted"
Localization.wc_unavailable_mod = "Unavailable"
Localization.wc_advanced_options = "Advanced"

Localization.wc_adv_clear_weapon = "Revert to Factory Standard"
Localization.wc_adv_toggle_preview_spin = "Toggle Rotating Preview"
Localization.wc_adv_toggle_colour_grading = "Toggle Ingame Colour Grading"

Localization.wc_clear_weapon_title = "Revert Weapon"
Localization.wc_clear_weapon_message = "This will revert your weapon customization back to factory standard, do you wish to continue?"
Localization.wc_clear_weapon_accept = "Revert"
Localization.wc_clear_weapon_cancel = "Cancel"

Localization.wc_mod_overrides_not_installed_title = "Mod Overrides Missing"
Localization.wc_mod_overrides_not_installed_desc = [[The mod overrides required to make the Weapon Customization mod are missing from your game mod_overrides folder.
You must install these, or else you will not see your weapon customization.

A link to the download is found below. Extract the inner folder 'GoonModWeaponCustomizer' to your mod_overrides folder in your Payday 2 assets folder, and then restart your game.]]
Localization.wc_mod_overrides_not_installed_download = "Download Now"
Localization.wc_mod_overrides_not_installed_cancel = "Later"

WeaponCustomization._advanced_menu_options = {
	[1] = {
		text = "wc_adv_toggle_preview_spin",
		func = "AdvancedToggleWeaponSpin",
	},
	[2] = {
		text = "wc_adv_toggle_colour_grading",
		func = "AddvancedToggleColourGrading",
	},
	[3] = {
		text = "wc_adv_clear_weapon",
		func = "AdvancedClearWeaponCheck",
	}
}
WeaponCustomization._menu_text_scaling = 0.85

function WeaponCustomization.weapon_visual_customization_callback(self, data)

	local all_mods_by_type = {
		materials = managers.blackmarket:get_inventory_category("materials"),
		textures = managers.blackmarket:get_inventory_category("textures"),
		colors = managers.blackmarket:get_inventory_category("colors")
	}

	local new_node_data = {}
	local list = {
		"materials",
		"textures",
		"colors"
	}

	local mask_default_blueprint = {
		["materials"] = {
			id = "plastic",
			global_value = "normal",
		},
		["textures"] = {
			id = "no_color_no_material",
			global_value = "normal",
		},
		["colors"] = {
			id = "nothing",
			global_value = "normal",
		},
	}

	for _, category in pairs(list) do

		local listed_items = {}
		local items = all_mods_by_type[category]
		local default = mask_default_blueprint[category]
		local mods = {}

		if default then
			if default.id == "no_color_no_material" then
				default = managers.blackmarket:customize_mask_category_default(category)
			end
			if default.id ~= "nothing" and default.id ~= "no_color_no_material" then
				table.insert(mods, default)
				mods[#mods].pcs = {0}
				mods[#mods].default = true
				listed_items[default.id] = true
			end
		end

		if category == "materials" and not listed_items.plastic then
			table.insert(mods, {id = "plastic", global_value = "normal"})
			mods[#mods].pcs = {0}
			mods[#mods].default = true
		end

		local td
		for i = 1, #items do
			td = tweak_data.blackmarket[category][items[i].id]
			if not listed_items[items[i].id] and td.texture or td.colors then
				table.insert(mods, items[i])
				mods[#mods].pc = td.pc or td.pcs and td.pcs[1] or 10
				mods[#mods].colors = td.colors
			end
		end

		local sort_td = tweak_data.blackmarket[category]
		local x_pc, y_pc
		table.sort(mods, function(x, y)
			if x.colors and y.colors then
				for i = 1, 2 do
					local x_color = x.colors[i]
					local x_max = math.max(x_color.r, x_color.g, x_color.b)
					local x_min = math.min(x_color.r, x_color.g, x_color.b)
					local x_diff = x_max - x_min
					local x_wl
					if x_max == x_min then
						x_wl = 10 - x_color.r
					elseif x_max == x_color.r then
						x_wl = (x_color.g - x_color.b) / x_diff % 6
					elseif x_max == x_color.g then
						x_wl = (x_color.b - x_color.r) / x_diff + 2
					elseif x_max == x_color.b then
						x_wl = (x_color.r - x_color.g) / x_diff + 4
					end
					local y_color = y.colors[i]
					local y_max = math.max(y_color.r, y_color.g, y_color.b)
					local y_min = math.min(y_color.r, y_color.g, y_color.b)
					local y_diff = y_max - y_min
					local y_wl
					if y_max == y_min then
						y_wl = 10 - y_color.r
					elseif y_max == y_color.r then
						y_wl = (y_color.g - y_color.b) / y_diff % 6
					elseif y_max == y_color.g then
						y_wl = (y_color.b - y_color.r) / y_diff + 2
					elseif y_max == y_color.b then
						y_wl = (y_color.r - y_color.g) / y_diff + 4
					end
					if x_wl ~= y_wl then
						return x_wl < y_wl
					end
				end
			end
			x_pc = x.pc or x.pcs and x.pcs[1] or 1001
			y_pc = y.pc or y.pcs and y.pcs[1] or 1001
			x_pc = x_pc + (x.global_value and tweak_data.lootdrop.global_values[x.global_value].sort_number or 0)
			y_pc = y_pc + (y.global_value and tweak_data.lootdrop.global_values[y.global_value].sort_number or 0)
			return x_pc < y_pc
		end)

		local max_x = 6
		local max_y = 3
		local mod_data = mods or {}
		table.insert(new_node_data, {
			name = category,
			category = category,
			prev_node_data = data,
			name_localized = managers.localization:to_upper_text("bm_menu_" .. category),
			on_create_func_name = "populate_choose_mask_mod",
			on_create_data = mod_data,
			override_slots = {max_x, max_y},
			identifier = BlackMarketGui.identifiers.weapon_customization
		})

	end

	new_node_data.topic_id = "bm_menu_customize_weapon_title"
	new_node_data.topic_params = {
		weapon_name = data.name_localized
	}

	local params = {}
	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_abort_customized_mask_callback"))
	params.no_func = callback(self, self, "_dialog_no")

	new_node_data.back_callback = callback(self, self, "_warn_abort_customized_mask_callback", params)
	new_node_data.blur_fade = self._data.blur_fade
	new_node_data.weapon_slot_data = data

	if data.category == "primaries" or data.category == "secondaries" then
		managers.blackmarket:view_weapon( data.category, data.slot, callback(self, self, "_open_weapon_customization_preview_node", {new_node_data}) )
	end
	if data.category == "melee_weapons" then
		-- managers.menu:open_node(self._preview_node_name, {})
		-- managers.blackmarket:preview_melee_weapon(data.name)
		-- self:_open_weapon_customization_preview_node( {new_node_data} )
	end

end

function WeaponCustomization._open_weapon_customization_preview_node(self, data)

	managers.blackmarket._customizing_weapon = true
	managers.blackmarket._customizing_weapon_data = data[1].weapon_slot_data

	local category = data[1].weapon_slot_data.category
	local slot = data[1].weapon_slot_data.slot
	local weapon = managers.blackmarket._global.crafted_items[category][slot]

	managers.blackmarket._customizing_weapon_parts = {}
	for k, v in ipairs( weapon.blueprint ) do
		local tbl = clone( WeaponCustomization._default_part_visual_blueprint )
		tbl.id = v
		tbl.modifying = false
		table.insert( managers.blackmarket._customizing_weapon_parts, tbl )
	end

	managers.blackmarket._selected_weapon_parts = clone( WeaponCustomization._default_part_visual_blueprint )

	managers.menu:open_node("blackmarket_mask_node", data)
	WeaponCustomization:LoadCurrentWeaponCustomization( category, slot )

	WeaponCustomization:Temp_CheckOverridesInstalled()

end

Hooks:Add("MenuSceneManagerOverrideSceneTemplate", "MenuSceneManagerOverrideSceneTemplate_WeaponCustomization", function(scene, template, data, custom_name, skip_transition)
	if managers.blackmarket._customizing_weapon and template == "blackmarket_mask" then
		return "blackmarket_item"
	end
end)

Hooks:Add("BlackMarketGUIStartPageData", "BlackMarketGUIStartPageData_WeaponCustomization", function(gui)
	if gui.identifiers then
		gui.identifiers.weapon_customization = Idstring("weapon_customization")
	end
end)

Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_WeaponCustomization", function(gui, is_start_page, component_data)

	gui.customize_weapon_visuals = function(gui, data)
		WeaponCustomization.weapon_visual_customization_callback(gui, data)
	end
	gui._open_weapon_customization_preview_node = function(gui, data)
		WeaponCustomization._open_weapon_customization_preview_node(gui, data)
	end

	local w_visual_customize = {
		prio = 5,
		btn = "BTN_STICK_L",
		pc_btn = nil,
		name = "WeaponCustomization_MenuItem",
		callback = callback(gui, gui, "customize_weapon_visuals")
	}

	local btn_x = 10
	gui._btns["w_visual_customize"] = BlackMarketGuiButtonItem:new(gui._buttons, w_visual_customize, btn_x)

end)

Hooks:Add("BlackMarketGUIOnPopulateWeaponActionList", "BlackMarketGUIOnPopulateWeaponActionList_WeaponCustomization", function(gui, data)
	if data.unlocked then
		table.insert(data, "w_visual_customize")
	end
end)

-- Hooks:Add("BlackMarketGUIOnPopulateMeleeWeaponActionList", "BlackMarketGUIOnPopulateMeleeWeaponActionList_WeaponCustomization", function(gui, data)
-- 	if data.unlocked then
-- 		table.insert(data, "w_visual_customize")
-- 	end
-- end)

Hooks:Add("BlackMarketGUIOnPopulateWeapons", "BlackMarketGUIOnPopulateWeapons_WeaponCustomization", function(gui, category, data)
	if managers.blackmarket._customizing_weapon then
		managers.blackmarket._customizing_weapon = nil
	end
end)

Hooks:Add("BlackMarketGUIChooseMaskPartCallback", "BlackMarketGUIChooseMaskPartCallback_WeaponCustomization", function(gui, data)
	WeaponCustomization:UpdateWeaponPartsWithMaskMod( data )
end)

Hooks:Add("BlackMarketGUIUpdateInfoText", "BlackMarketGUIUpdateInfoText_WeaponCustomization", function(self)

	local table_contains = function(tbl, val)
		for k, v in ipairs( tbl ) do
			if v.id == val then
				return v
			end
		end
		return false
	end

	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	local updated_texts = {
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""},
	}

	local id = "none"
	for k, v in pairs( self.identifiers ) do
		if v == identifier then
			id = k
		end
	end

	if identifier == self.identifiers.weapon_customization then

		local blackmarket = managers.blackmarket
		if blackmarket._customizing_weapon and blackmarket._customizing_weapon_data and blackmarket._customizing_weapon_parts then

			local weapon_data = managers.blackmarket._customizing_weapon_data
			local category = weapon_data.category
			local slot = weapon_data.slot
			local weapon = managers.blackmarket._global.crafted_items[category][slot]

			updated_texts[2].text = managers.localization:to_upper_text("wc_modifying_parts") .. "\n"
			updated_texts[3].text = managers.localization:to_upper_text("wc_not_modifying_parts") .. "\n"
			for k, v in pairs( weapon.blueprint ) do

				local part = tweak_data.weapon.factory.parts[v]
				if part then

					local tbl = table_contains( blackmarket._customizing_weapon_parts, v )
					local part_name = managers.localization:to_upper_text(part.name_id or "bm_wp_m4_lower_reciever")
					local part_index = (tbl and tbl.modifying) and 2 or 3
					updated_texts[ part_index ].text = updated_texts[ part_index ].text .. "    " .. part_name .. "\n"

				end

			end

		end

		-- Add advanced options
		self._info_texts_color[5] = tweak_data.screen_colors.text
		updated_texts[5].text = "\n" .. managers.localization:to_upper_text("wc_advanced_options") .. "\n"
		for k, v in ipairs( WeaponCustomization._advanced_menu_options ) do
			updated_texts[5].text = updated_texts[5].text .. managers.localization:text( v.text ) .. "\n"
		end

		-- Selected Mod
		updated_texts[4].text = "\n"
		if slot_data then

			updated_texts[4].text = "\n" .. managers.localization:to_upper_text("wc_highlighted_mod") .. "\n" .. slot_data.name_localized

			if not slot_data.unlocked or (type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				self._info_texts_color[5] = tweak_data.screen_colors.important_1
				updated_texts[5].text = managers.localization:text("wc_unavailable_mod")
			end

		end

		-- Update texts
		self:_update_info_text(slot_data, updated_texts, nil, WeaponCustomization._menu_text_scaling)

	end

end)

Hooks:Add("BlackMarketGUIMouseReleased", "BlackMarketGUIMouseReleased_WeaponCustomization", function(gui, button, x, y)

	if not managers.blackmarket._customizing_weapon then
		return
	end

	if button == Idstring("0") then
		WeaponCustomization:LeftMouseReleased(gui, button, x, y)
	end
	
	if button == Idstring("1") then
		WeaponCustomization:RightMouseReleased(gui, button, x, y)
	end


end)

function WeaponCustomization:LeftMouseReleased(gui, button, x, y)
	WeaponCustomization:LeftMouseReleased_SelectParts(gui, button, x, y)
	WeaponCustomization:LeftMouseReleased_Advanced(gui, button, x, y)
end

function WeaponCustomization:LeftMouseReleased_SelectParts(gui, button, x, y)

	for k, v in pairs( gui._info_texts ) do
		if v:inside(x, y) then

			local line = WeaponCustomization:_GetLineFromObjectRect(x, y, v) - 1
			local modifying_item = nil
			if k == 2 then modifying_item = true end
			if k == 3 then modifying_item = false end

			if modifying_item ~= nil then

				local tbl_index = WeaponCustomization:_GetIndexFromLine(line, modifying_item)

				if tbl_index and managers.blackmarket._customizing_weapon_parts[ tbl_index ] then
					managers.blackmarket._customizing_weapon_parts[ tbl_index ].modifying = not managers.blackmarket._customizing_weapon_parts[ tbl_index ].modifying
				end

				gui:update_info_text()
				break

			end

		end
	end

end

function WeaponCustomization:LeftMouseReleased_Advanced(gui, button, x, y)

	local v = gui._info_texts[5]
	if not v then
		return
	end

	if v:inside(x, y) then

		local line = WeaponCustomization:_GetLineFromObjectRect(x, y, v) - 2
		local adv_option = self._advanced_menu_options[ line ]
		
		if adv_option and adv_option.func then
			self[ adv_option.func ]()
		end

	end

end

function WeaponCustomization:RightMouseReleased(gui, button, x, y)

	for k, v in pairs( gui._info_texts ) do
		if v:inside(x, y) then

			local line = WeaponCustomization:_GetLineFromObjectRect(x, y, v) - 1
			local modifying_item = nil
			if k == 2 then modifying_item = true end
			if k == 3 then modifying_item = false end

			if modifying_item ~= nil then

				local tbl_index = WeaponCustomization:_GetIndexFromLine(line, modifying_item)

				if tbl_index and managers.blackmarket._customizing_weapon_parts[ tbl_index ] then
					local mod = managers.blackmarket._customizing_weapon_parts[ tbl_index ].modifying
					for a, b in ipairs( managers.blackmarket._customizing_weapon_parts ) do
						if a ~= tbl_index then
							managers.blackmarket._customizing_weapon_parts[a].modifying = not mod
						end
					end
				end

				gui:update_info_text()
				break

			end

		end
	end

end

function WeaponCustomization:_IsInObjectRect(x, y, obj)
	local rx, ry, rw, rh = obj:text_rect()
	if x >= rx and x <= rx + rw and y >= ry and y <= ry + rh then
		return true
	end
	return false
end

function WeaponCustomization:_GetLineFromObjectRect(x, y, obj)
	local rx, ry, rw, rh = obj:text_rect()
	local font_size = tweak_data.menu.pd2_small_font_size * WeaponCustomization._menu_text_scaling
	y = y - ry + font_size / 2
	y = y / (font_size * 1.05)
	return math.round_with_precision(y, 0)
end

function WeaponCustomization:_GetIndexFromLine(line, modifying)

	local i = 0

	for k, v in ipairs( managers.blackmarket._customizing_weapon_parts ) do
		if (modifying and v.modifying) or (not modifying and not v.modifying) then
			i = i + 1
			if i == line then
				return k
			end
		end
	end

	return nil

end

-- Clear Weapon Function
function WeaponCustomization:AdvancedToggleWeaponSpin()

	if managers.menu_scene then
		if managers.menu_scene._disable_rotate ~= nil then
			managers.menu_scene._disable_rotate = not managers.menu_scene._disable_rotate
		else
			managers.menu_scene._disable_rotate = true
		end
	end

end

function WeaponCustomization:AddvancedToggleColourGrading()

	if managers and managers.environment_controller then

		local self = WeaponCustomization
		local grading = "color_payday"
		if self._previous_colour_grading then
			grading = self._previous_colour_grading
			self._previous_colour_grading = nil
		else
			self._previous_colour_grading = managers.environment_controller:default_color_grading()
		end

		managers.environment_controller:set_default_color_grading( grading )
		managers.environment_controller:refresh_render_settings()

	end

end

function WeaponCustomization:AdvancedClearWeaponCheck()

	local title = managers.localization:text("wc_clear_weapon_title")
	local message = managers.localization:text("wc_clear_weapon_message")
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("wc_clear_weapon_accept"),
		callback = WeaponCustomization.AdvancedClearWeaponAccept,
		is_cancel_button = true
	}
	menuOptions[2] = {
		text = managers.localization:text("wc_clear_weapon_cancel"),
		is_cancel_button = true
	}
	local menu = SimpleMenu:New(title, message, menuOptions)
	menu:Show()

end

function WeaponCustomization.AdvancedClearWeaponAccept()

	if managers.blackmarket._customizing_weapon_data then

		local category = managers.blackmarket._customizing_weapon_data.category
		local slot = managers.blackmarket._customizing_weapon_data.slot
		local weapon = managers.blackmarket._global.crafted_items[category][slot]

		-- Clear weapon parts
		managers.blackmarket._customizing_weapon_parts = {}
		for k, v in ipairs( weapon.blueprint ) do
			local tbl = clone( WeaponCustomization._default_part_visual_blueprint )
			tbl.id = v
			tbl.modifying = false
			table.insert( managers.blackmarket._customizing_weapon_parts, tbl )
		end

		-- Clear selected parts
		managers.blackmarket._selected_weapon_parts = clone( WeaponCustomization._default_part_visual_blueprint )

		-- Save
		WeaponCustomization:UpdateWeaponPartsWithMod( nil, nil, managers.blackmarket._customizing_weapon_parts, true )

		-- Clear data on slot
		if weapon.visual_blueprint then
			weapon.visual_blueprint = nil
		end
		
	end

end

-- Temporary Popup
function WeaponCustomization:Temp_CheckOverridesInstalled()

	local file_name = "assets/mod_overrides/GoonModWeaponCustomizer/units/payday2/weapons/wpn_fps_ass_74_pts/wpn_fps_ass_74_b_standard.material_config"
	file_name = Application:base_path() .. file_name

	local f= io.open(file_name, "r")
	if f ~= nil then
		io.close(f)
	else
		WeaponCustomization:Temp_ShowOverridesNotInstalledWindow()
	end

end

function WeaponCustomization:Temp_ShowOverridesNotInstalledWindow()

	local title = managers.localization:text("wc_mod_overrides_not_installed_title")
	local message = managers.localization:text("wc_mod_overrides_not_installed_desc")
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("wc_mod_overrides_not_installed_download"),
		callback = WeaponCustomization.Temp_DownloadOverrides,
		is_cancel_button = true
	}
	menuOptions[2] = {
		text = managers.localization:text("wc_mod_overrides_not_installed_cancel"),
		is_cancel_button = true
	}
	local menu = SimpleMenu:New(title, message, menuOptions)
	menu:Show()

end

function WeaponCustomization:Temp_DownloadOverrides()

	if SystemInfo:platform() == Idstring("WIN32") then
		os.execute( "explorer " .. WeaponCustomization._mod_overrides_download_location )
		os.execute( "explorer " .. Application:base_path() .. "assets\\mod_overrides\\" )
	end

end
-- END OF FILE
