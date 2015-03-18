
local WeaponCustomization = GoonBase.WeaponCustomization
if not GoonBase.WeaponCustomization then
	return
end

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

WeaponCustomization._controller_index = {
	modifying = 1,
	not_modifying = 1,
}

WeaponCustomization._invalid_melee_weapons = {
	["weapon"] = true,
	["fists"] = true,
}

local BTN_X = utf8.char(57346)
local BTN_Y = utf8.char(57347)
local BTN_LT = utf8.char(57354)
local BTN_LB = utf8.char(57352)
local BTN_RT = utf8.char(57355)
local BTN_RB = utf8.char(57353)
local BTN_START = utf8.char(57349)

function WeaponCustomization:IsUsingController()
	local type = managers.controller:get_default_wrapper_type()
	return type == "xbox360" or type == "ps3"
end

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

	new_node_data.blur_fade = self._data.blur_fade
	new_node_data.weapon_slot_data = data

	if data.category == "primaries" or data.category == "secondaries" then
		managers.blackmarket:view_weapon( data.category, data.slot, callback(self, self, "_open_weapon_customization_preview_node", {new_node_data}) )
	end
	if data.category == "melee_weapons" then
		managers.blackmarket._customizing_weapon_data = new_node_data
		managers.blackmarket:preview_melee_weapon(data.name)
	end

end

function WeaponCustomization._open_weapon_customization_preview_node(self, data)

	if not managers.blackmarket._customizing_weapon_data and not data then
		return
	end

	managers.blackmarket._customizing_weapon = true
	if data then
		managers.blackmarket._customizing_weapon_data = data[1].weapon_slot_data
	else
		data = { managers.blackmarket._customizing_weapon_data }
		managers.blackmarket._customizing_weapon_data = managers.blackmarket._customizing_weapon_data.weapon_slot_data
	end

	local weapon_data = managers.blackmarket._customizing_weapon_data
	if not weapon_data then
		return
	end

	local category = weapon_data.category
	local slot = weapon_data.slot
	local weapon = WeaponCustomization:GetWeaponTableFromInventory( weapon_data )
	
	WeaponCustomization:CreateCustomizablePartsList( weapon, category == "melee_weapons" )
	managers.blackmarket._selected_weapon_parts = clone( WeaponCustomization._default_part_visual_blueprint )

	WeaponCustomization._controller_index = {
		modifying = 1,
		not_modifying = 1,
	}

	managers.menu:open_node( "blackmarket_mask_node", data )
	WeaponCustomization:LoadCurrentWeaponCustomization( weapon_data )

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

	if Utils:IsInGameState() then
		return
	end

	gui.customize_weapon_visuals = function(gui, data)
		WeaponCustomization.weapon_visual_customization_callback(gui, data)
	end
	gui._open_weapon_customization_preview_node = function(gui, data)
		WeaponCustomization._open_weapon_customization_preview_node(gui, data)
	end

	local w_visual_customize = {
		prio = 5,
		btn = "BTN_BACK",
		pc_btn = Idstring("toggle_chat"),
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

Hooks:Add("BlackMarketGUIOnPopulateMeleeWeaponActionList", "BlackMarketGUIOnPopulateMeleeWeaponActionList_WeaponCustomization", function(gui, data)
	if data.unlocked and not WeaponCustomization._invalid_melee_weapons[data.name] then
		table.insert(data, "w_visual_customize")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateWeapons", "BlackMarketGUIOnPopulateWeapons_WeaponCustomization", function(gui, category, data)
	if managers.blackmarket._customizing_weapon then
		managers.blackmarket._customizing_weapon = nil
	end
end)

Hooks:Add("BlackMarketGUIChooseMaskPartCallback", "BlackMarketGUIChooseMaskPartCallback_WeaponCustomization", function(gui, data)
	WeaponCustomization:UpdateWeaponPartsWithMaskMod( data )
end)

Hooks:Add("BlackMarketGUIButtonPostSetTextParameters", "BlackMarketGUIButtonPostSetTextParameters_WeaponCustomization", function(self, params)

	local bm = BlackMarketGui._instance
	if bm then

		local tab_data = bm._tabs[bm._selected]._data
		if tab_data.identifier == bm.identifiers.weapon_customization then
			self._btn_text:set_text( self._btn_text:text():lower():gsub("mask", "weapon"):upper() )
			BlackMarketGui.make_fine_text(self, self._btn_text)
		end

	end

end)

Hooks:Add("BlackMarketGUIUpdateInfoText", "BlackMarketGUIUpdateInfoText_WeaponCustomization", function(self)


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

		if not WeaponCustomization._select_rect or not alive( WeaponCustomization._select_rect ) then
			WeaponCustomization._select_rect = self._panel:child("info_box_panel"):rect({
				name = "wc_select_rect",
				blend_mode = "add",
				color = tweak_data.screen_colors.button_stage_3,
				alpha = 0.3,
				valign = "scale",
				halign = "scale",
				x = 10,
				y = 10,
				w = self._panel:child("info_box_panel"):w() - 20,
				h = tweak_data.menu.pd2_small_font_size * WeaponCustomization._menu_text_scaling,
			})
		end

		local blackmarket = managers.blackmarket
		if blackmarket._customizing_weapon and blackmarket._customizing_weapon_data and blackmarket._customizing_weapon_parts then

			local weapon_data = managers.blackmarket._customizing_weapon_data
			local category = weapon_data.category
			local slot = weapon_data.slot
			local weapon = WeaponCustomization:GetWeaponTableFromInventory( weapon_data )

			if not WeaponCustomization:_IsCustomizingMeleeWeapon() then

				updated_texts[2].text = managers.localization:to_upper_text("wc_modifying_parts") .. "\n"
				updated_texts[3].text = managers.localization:to_upper_text("wc_not_modifying_parts") .. "\n"

				if WeaponCustomization:IsUsingController() then
					updated_texts[2].text = BTN_LT .. " " .. updated_texts[2].text
					updated_texts[3].text = BTN_RT .. " " .. updated_texts[3].text
				end

				local num_modifying = 0
				local num_not_modifying = 0
				for k, v in pairs( blackmarket._customizing_weapon_parts ) do
					if v and v.modifying then
						num_modifying = num_modifying + 1
					else
						num_not_modifying = num_not_modifying + 1
					end
				end

				local modifying_lines = 0
				local not_modifying_lines = 0
				for k, v in pairs( blackmarket._customizing_weapon_parts ) do

					if v.id then
						local part = tweak_data.weapon.factory.parts[v.id]
						if part then

							local part_name = WeaponCustomization:_GetLocalizedPartName(v.id, part)
							local modifying = (v and v.modifying or false)
							local part_index = modifying and 2 or 3

							if WeaponCustomization:IsUsingController() then

								if v and v.modifying then
									modifying_lines = modifying_lines + 1
								else
									not_modifying_lines = not_modifying_lines + 1
								end

								-- Clamp values
								if WeaponCustomization._controller_index.modifying > num_modifying then
									WeaponCustomization._controller_index.modifying = 1
								end
								if WeaponCustomization._controller_index.not_modifying > num_not_modifying then
									WeaponCustomization._controller_index.not_modifying = 1
								end

								-- Place markers on appropriate lines
								local ind = WeaponCustomization:_GetIndexFromLine(modifying and modifying_lines or not_modifying_lines, modifying)
								if modifying then
									if WeaponCustomization._controller_index.modifying == modifying_lines then
										part_name = BTN_X .. " " .. part_name
									end
								else
									if WeaponCustomization._controller_index.not_modifying == not_modifying_lines then
										part_name = BTN_Y .. " " .. part_name
									end
								end

							end
							part_name = "    " .. part_name .. "\n"

							updated_texts[ part_index ].text = updated_texts[ part_index ].text .. part_name

						end
					end

				end

			end

		end

		-- Add advanced options
		self._info_texts_color[5] = tweak_data.screen_colors.text
		updated_texts[5].text = "\n"
		if WeaponCustomization:IsUsingController() then
			updated_texts[5].text = updated_texts[5].text .. BTN_START .. " "
		end
		updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("wc_advanced_options") .. "\n"
		for k, v in ipairs( WeaponCustomization._advanced_menu_options ) do
			updated_texts[5].text = updated_texts[5].text .. managers.localization:text( v.text ) .. "\n"
		end

		-- Selected Mod
		updated_texts[4].text = WeaponCustomization:_IsCustomizingMeleeWeapon() and "" or "\n"
		if slot_data then

			updated_texts[4].text = updated_texts[4].text .. managers.localization:to_upper_text("wc_highlighted_mod") .. "\n" .. slot_data.name_localized

			if not slot_data.unlocked or (type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				self._info_texts_color[5] = tweak_data.screen_colors.important_1
				updated_texts[5].text = managers.localization:text("wc_unavailable_mod")
			end

		end

		-- Update texts
		self:_update_info_text(slot_data, updated_texts, nil, WeaponCustomization._menu_text_scaling)

	end

end)

Hooks:Add("BlackMarketGUIOnMouseMoved", "BlackMarketGUIOnMouseMoved_WeaponCustomization", function(gui, button, x, y)
	WeaponCustomization:UpdateHighlight(gui, button, x, y)
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

Hooks:Add("MenuUpdate", "MenuUpdate_WeaponCustomization", function(t, dt)

	if managers.blackmarket._customizing_weapon then
		WeaponCustomization:_UpdateControllerBindings()
	end

end)

Hooks:Add("BlackMarketGUIOnPopulateWeapons", "BlackMarketGUIOnPopulateWeapons_WeaponCustomization", function(gui, category, data)
	managers.blackmarket._customizing_weapon_data = nil
	WeaponCustomization:RestoreMenuColourGrading()
end)

function WeaponCustomization:_UpdateControllerBindings()

	if WeaponCustomization:IsUsingController() then

		local controller = managers.menu:get_controller()
		local r_trigger = controller:get_input_pressed("primary_attack")
		local l_trigger = controller:get_input_pressed("secondary_attack")
		local button_x = controller:get_input_pressed("reload")
		local button_y = controller:get_input_pressed("switch_weapon")
		local start = controller:get_input_pressed("start")

		-- Cycle through modifying and not modifying options
		if r_trigger then
			WeaponCustomization._controller_index.not_modifying = WeaponCustomization._controller_index.not_modifying + 1
			WeaponCustomization:_UpdateBlackmarketGUI()
		end

		if l_trigger then
			WeaponCustomization._controller_index.modifying = WeaponCustomization._controller_index.modifying + 1
			WeaponCustomization:_UpdateBlackmarketGUI()
		end

		-- Switch modifying and not modifying items
		if button_x then
			WeaponCustomization:_SwapWeaponPartModifyingStatus(WeaponCustomization._controller_index.modifying, true, true)
		end

		if button_y then
			WeaponCustomization:_SwapWeaponPartModifyingStatus(WeaponCustomization._controller_index.not_modifying, false, true)
		end

		-- Controller advanced options
		if start then
			WeaponCustomization:ShowControllerAdvancedOptions()
		end

	end

end

function WeaponCustomization:_UpdateBlackmarketGUI()
	if managers.menu_component and managers.menu_component._blackmarket_gui then
		managers.menu_component._blackmarket_gui:update_info_text()
	end
end

function WeaponCustomization:UpdateHighlight(gui, button, x, y)

	if not gui then
		return
	end

	local inside = false
	for k, v in pairs( gui._info_texts ) do
		if v:inside(x, y) and gui._info_texts_panel:inside(x, y) then

			local line, line_str = WeaponCustomization:_GetLineFromObjectRect(x, y, v)
			line = line - 1
			
			if alive( WeaponCustomization._select_rect ) and line and (not string.is_nil_or_empty(line_str) and line_str ~= '\n') then

					inside = true
					line = line < 0 and 0 or line

					WeaponCustomization._select_rect:set_alpha( 0.3 )

					local lh = tweak_data.menu.pd2_small_font_size * WeaponCustomization._menu_text_scaling
					WeaponCustomization._select_rect:set_y( v:y() + line * lh + lh * 0.5 + line )

					if WeaponCustomization._select_rect_line ~= line then
						WeaponCustomization._select_rect_line = line
						managers.menu_component:post_event("highlight")
					end

			end

		end
	end

	if not inside then
		if alive( WeaponCustomization._select_rect ) then
			WeaponCustomization._select_rect:set_alpha( 0 )
		end
	end

end

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
				WeaponCustomization:_SwapWeaponPartModifyingStatus(line, modifying_item)
				gui:update_info_text()
				managers.menu_component:post_event("menu_enter")
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
			self[ adv_option.func ](self)
			managers.menu_component:post_event("menu_enter")
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
				managers.menu_component:post_event("menu_enter")
				break

			end

		end
	end

end

function WeaponCustomization:_SwapWeaponPartModifyingStatus( line, modifying, update )
	local tbl_index = WeaponCustomization:_GetIndexFromLine(line, modifying)
	if tbl_index and managers.blackmarket._customizing_weapon_parts[ tbl_index ] then
		managers.blackmarket._customizing_weapon_parts[ tbl_index ].modifying = not managers.blackmarket._customizing_weapon_parts[ tbl_index ].modifying
	end
	if update then
		WeaponCustomization:_UpdateBlackmarketGUI()
	end
end

function WeaponCustomization:_GetLineFromObjectRect(x, y, obj)
	local rx, ry, rw, rh = obj:text_rect()
	local font_size = tweak_data.menu.pd2_small_font_size * WeaponCustomization._menu_text_scaling
	y = y - ry + font_size / 2
	y = y / (font_size * 1.05)
	local line = math.round_with_precision(y, 0)
	local strs = string.split( obj:text(), "[\n]" )
	if strs and obj:text():sub(1, 1) == '\n' then
		table.insert( strs, 1, "\n" )
	end
	if strs then
		return line, strs[line]
	end
	return line
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

function WeaponCustomization:_IsCustomizingMeleeWeapon()
	if managers.blackmarket._customizing_weapon_data then
		local weapon_data = managers.blackmarket._customizing_weapon_data
		local category = weapon_data.category
		if category == "primaries" or category == "secondaries" then
			return false
		else
			return true
		end
	end
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

function WeaponCustomization:RestoreMenuColourGrading()
	managers.environment_controller:set_default_color_grading( "color_matrix" )
	managers.environment_controller:refresh_render_settings()
	self._previous_colour_grading = nil
end

function WeaponCustomization:AdvancedClearWeaponCheck()

	local title = managers.localization:text("wc_clear_weapon_title")
	local message = managers.localization:text("wc_clear_weapon_message")
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("wc_clear_weapon_accept"),
		callback = callback(self, self, "_AdvancedClearWeaponAccept")
	}
	menuOptions[2] = {
		text = managers.localization:text("wc_clear_weapon_cancel"),
		is_cancel_button = true
	}
	local menu = QuickMenu:new(title, message, menuOptions, true)

end

function WeaponCustomization:_AdvancedClearWeaponAccept()

	if managers.blackmarket._customizing_weapon_data then
		return
	end

	local category = managers.blackmarket._customizing_weapon_data.category
	local weapon = self:GetWeaponTableFromInventory( managers.blackmarket._customizing_weapon_data )

	-- Rebuild weapon parts list
	if category ~= "melee_weapons" then
		self:CreateCustomizablePartsList( weapon )
	end

	-- Clear selected parts
	managers.blackmarket._selected_weapon_parts = clone( WeaponCustomization._default_part_visual_blueprint )

	-- Save
	self:UpdateWeaponPartsWithMod( nil, nil, managers.blackmarket._customizing_weapon_parts, category ~= "melee_weapons" )

	-- Clear data on slot
	if weapon.visual_blueprint then
		weapon.visual_blueprint = nil
	end

end

-- Advanced options for controller
function WeaponCustomization:ShowControllerAdvancedOptions()

	local title = managers.localization:text("wc_advanced_options_menu")
	local message = ""
	local menuOptions = {}
	
	local i = 1
	for k, v in ipairs( WeaponCustomization._advanced_menu_options ) do
		menuOptions[i] = {
			text = managers.localization:text( v.text ),
			callback = WeaponCustomization[v.func],
			is_cancel_button = true
		}
		i = i + 1
	end

	menuOptions[i] = {
		text = managers.localization:text("wc_clear_weapon_cancel"),
		is_cancel_button = true
	}

	local menu = QuickMenu:new(title, message, menuOptions, true)
	
end
