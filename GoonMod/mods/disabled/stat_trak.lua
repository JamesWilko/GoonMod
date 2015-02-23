
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "StatTrakWeapons"
Mod.Name = "Stat-trak Weapons"
Mod.Desc = ""
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.EnabledByDefault = true

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Stat-trak
_G.GoonBase.StatTrak = _G.GoonBase.StatTrak or {}
local StatTrak = _G.GoonBase.StatTrak
StatTrak.MenuId = "goonbase_stattrak_menu"
StatTrak.InspectWeaponKey = "StattrakInspectWeapon"
StatTrak.CycleStatKey = "StattrakCycleMode"
StatTrak.CustomKeys = {
	INSPECT = GoonBase.Options.StatTrak ~= nil and GoonBase.Options.StatTrak.InspectWeaponKey or "",
	CYCLE_MODE = GoonBase.Options.StatTrak ~= nil and GoonBase.Options.StatTrak.CycleStatKey or ""
}

StatTrak.CurrentMode = 1
StatTrak.Modes = {
	[1] = "all",
	[2] = "bulldozers",
	[3] = "shields",
	[4] = "tasers",
	[5] = "snipers",
	[6] = "cloakers",
}

StatTrak.ModesFriendlyText = {
	["all"] = "",
	["bulldozers"] = "Bulldozers",
	["shields"] = "Shields",
	["tasers"] = "Tasers",
	["snipers"] = "Snipers",
	["cloakers"] = "Cloakers",
}

StatTrak._example_kills = {
	["all"] = 136,
	["bulldozers"] = 1,
	["shields"] = 12,
	["tasers"] = 7,
	["snipers"] = 4,
	["cloakers"] = 0,
}

-- Load Weapon Offsets
StatTrak.WeaponOffsetsFile = "mods/stat_trak_weapon_offsets.lua"
SafeDoFile( GoonBase.Path .. StatTrak.WeaponOffsetsFile )

-- Options
if GoonBase.Options.StatTrak == nil then
	GoonBase.Options.StatTrak = {}
	GoonBase.Options.StatTrak.InspectWeaponKey = ""
	GoonBase.Options.StatTrak.CycleStatKey = ""
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_" .. Mod:ID(), function(menu_manager, menu_nodes)
	MenuHelper:NewMenu( StatTrak.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function( menu_manager )

	-- Add corpse mod menu button
	MenuHelper:AddButton({
		id = "stattrak_mod_menu_button",
		title = "OptionsMenu_StatTrakSubmenuTitle",
		desc = "OptionsMenu_StatTrakSubmenuDesc",
		next_node = StatTrak.MenuId,
		menu_id = "goonbase_options_menu"
	})

	MenuHelper:AddKeybinding({
		id = "keybind_stattrak_inspect",
		title = managers.localization:text("OptionsMenu_InspectWeapon"),
		desc = managers.localization:text("OptionsMenu_InspectWeaponDesc"),
		connection_name = StatTrak.InspectWeaponKey,
		button = StatTrak.CustomKeys.INSPECT,
		binding = StatTrak.CustomKeys.INSPECT,
		menu_id = StatTrak.MenuId,
		priority = 20
	})

	MenuHelper:AddKeybinding({
		id = "keybind_stattrak_cycle",
		title = managers.localization:text("OptionsMenu_CycleStattrakMode"),
		desc = managers.localization:text("OptionsMenu_CycleStattrakModeDesc"),
		connection_name = StatTrak.CycleStatKey,
		button = StatTrak.CustomKeys.CYCLE_MODE,
		binding = StatTrak.CustomKeys.CYCLE_MODE,
		menu_id = StatTrak.MenuId,
		priority = 19
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_" .. Mod:ID(), function(menu_manager, mainmenu_nodes)
	mainmenu_nodes[StatTrak.MenuId] = MenuHelper:BuildMenu( StatTrak.MenuId )
end)

-- Custom keybinds
Hooks:Add("CustomizeControllerOnKeySet", "CustomizeControllerOnKeySet_" .. Mod:ID(), function(item)

	local psuccess, perror = pcall(function()
	
	if item._name == StatTrak.InspectWeaponKey then
		StatTrak.CustomKeys.INSPECT = item._input_name_list[1]
		StatTrak:SaveBindings()
	end

	if item._name == StatTrak.CycleStatKey then
		StatTrak.CustomKeys.CYCLE_MODE = item._input_name_list[1]
		StatTrak:SaveBindings()
	end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end)

function StatTrak:SaveBindings()
	GoonBase.Options.StatTrak.InspectWeaponKey = StatTrak.CustomKeys.INSPECT
	GoonBase.Options.StatTrak.CycleStatKey = StatTrak.CustomKeys.CYCLE_MODE
	GoonBase.Options:Save()
end

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_" .. Mod:ID(), function(t, dt)
	StatTrak:UpdateBindings()
end)

function StatTrak:UpdateBindings()

	if self._input == nil then
		self._input = Input:keyboard()
	end
	if managers.hud:chat_focus() then
		return
	end

	local inspect_key = StatTrak.CustomKeys.INSPECT
	if not string.is_nil_or_empty(inspect_key) then
		if self._input:pressed(Idstring(inspect_key)) then
			StatTrak._inspecting = true
			local state = managers.player:local_player():movement():current_state()
			state:_stance_entered()
		end
		if self._input:released(Idstring(inspect_key)) then
			StatTrak._inspecting = false
			local state = managers.player:local_player():movement():current_state()
			state:_stance_entered()
		end
	end

	local cycle_key = StatTrak.CustomKeys.CYCLE_MODE
	if not string.is_nil_or_empty(cycle_key) and self._input:pressed(Idstring(cycle_key)) then
		StatTrak:CycleMode()
	end

end

function StatTrak:GetCurrentModeName()
	return StatTrak.Modes[StatTrak.CurrentMode]
end

function StatTrak:CycleMode()
	
	StatTrak.CurrentMode = StatTrak.CurrentMode + 1
	if StatTrak.CurrentMode > #StatTrak.Modes then
		StatTrak.CurrentMode = 1
	end

end

Hooks:Add("FPCameraBaseStanceEnteredCallback", "FPCameraBaseStanceEnteredCallback_" .. Mod:ID(), function(camera, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)

	local psuccess, perror = pcall(function()
		
	if StatTrak._inspecting then

		-- local factory_id = managers.blackmarket:equipped_primary().factory_id
		local factory_id = managers.player:local_player():inventory():equipped_unit():base()._factory_id
		PrintStr(factory_id)
		if factory_id ~= nil then

			local default_offset = StatTrak.StandardOffsets
			local weapon_offset = StatTrak.WeaponOffsets[ factory_id ]

			stance_mod.rotation = weapon_offset.inspect_rotation_offset or default_offset.inspect_rotation_offset
			stance_mod.translation = weapon_offset.inspect_position_offset or default_offset.inspect_position_offset

		end

	end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end)

function StatTrak.add_kill_tracker(weapon, unit)

	local psuccess, perror = pcall(function()
	
		local self = weapon
		self._unit:set_extension_update_enabled( Idstring("base"), true )

		local gui_object = unit:get_object( Idstring("a_body") )
		if gui_object == nil then
			return
		end

		self._gui_object = gui_object
		self._ws_params = StatTrak:GetDefaultOffsets()

		local w = self._ws_params.w
		local h = self._ws_params.h
		local scaled_w, scaled_h = self._ws_params.w * self._ws_params.scale, self._ws_params.h * self._ws_params.scale

		local rot = gui_object:rotation() * self._ws_params.rotation_offset( gui_object )
		local pos = gui_object:position() + self._ws_params.position_offset( gui_object )

		local new_gui = World:newgui()
		local ws = new_gui:create_world_workspace(w, h, pos, Vector3(scaled_w, 0, 0):rotate_with(rot), Vector3(0, 0, -scaled_h):rotate_with(rot))
		self._ws = ws

		ws:panel():clear()
		ws:panel():set_alpha(0.8)
		ws:panel():rect({
			color = Color.black,
			layer = -1
		})
		self._back_drop_gui = MenuBackdropGUI:new(ws)
		local panel = self._back_drop_gui:get_new_background_layer()
		local default_offset = 112
		local font_size = 220
		self._kills_display = panel:text({
			text = "1234",
			y = self._ws:panel():h() / 2 - default_offset,
			font = tweak_data.menu.pd2_large_font,
			align = "center",
			vertical = "center",
			font_size = font_size,
			layer = 0,
			visible = true,
			color = OffshoreGui.MONEY_COLOR
		})

		local font_size = 80
		local default_offset = 40
		self._mode_display = panel:text({
			text = "",
			y = self._ws:panel():h() / 2 - default_offset,
			font = tweak_data.menu.pd2_large_font,
			align = "right",
			vertical = "center",
			font_size = font_size,
			layer = 0,
			visible = true,
			color = TextGui.COLORS.light_red:with_alpha(0.6)
		})

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

Hooks:Add("NewRaycastWeaponBaseInit", "NewRaycastWeaponBaseInit_" .. Mod:ID(), function( weapon, unit )

	if NewRaycastWeaponBase.add_kill_tracker == nil then
		NewRaycastWeaponBase.add_kill_tracker = StatTrak.add_kill_tracker
	end

	weapon:add_kill_tracker(unit)

end)

function StatTrak.update_kill_tracker_offsets(weapon, factory_id)
	weapon._ws_params = StatTrak:GetOffsetsForWeaponID(factory_id)
end

Hooks:Add("NewRaycastWeaponBaseSetFactoryData", "NewRaycastWeaponBaseSetFactoryData_" .. Mod:ID(), function(weapon, factory_id)

	if NewRaycastWeaponBase.update_kill_tracker_offsets == nil then
		NewRaycastWeaponBase.update_kill_tracker_offsets = StatTrak.update_kill_tracker_offsets
	end

	weapon:update_kill_tracker_offsets(factory_id)

end)

function StatTrak.update_kill_tracker_text(weapon, unit, t, dt)

	if not StatTrak.DefaultKillText then
		StatTrak.DefaultKillText = managers.localization:get_default_macro("BTN_SKULL") .. " {0}"
	end

	local psuccess, perror = pcall(function()

		if weapon._kills_display then
			local kills = StatTrak._example_kills[ StatTrak:GetCurrentModeName() ] or 1024
			weapon._kills_display:set_text( StatTrak.DefaultKillText:gsub("{0}", tostring(kills)) )
		end
		if weapon._mode_display then
			weapon._mode_display:set_text( StatTrak.ModesFriendlyText[ StatTrak:GetCurrentModeName() ] )
		end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

function StatTrak.update_kill_tracker_position(weapon, unit, t, dt)

	local psuccess, perror = pcall(function()
	
		local self = weapon
		if self._gui_object and self._ws then

			local ws = self._ws
			local gui_object = self._gui_object

			local w = self._ws_params.w
			local h = self._ws_params.h
			local scaled_w, scaled_h = self._ws_params.w * self._ws_params.scale, self._ws_params.h * self._ws_params.scale

			local pos = gui_object:position() + self._ws_params.position_offset( gui_object )
			local rot = gui_object:rotation() * self._ws_params.rotation_offset( gui_object )

			ws:set_world( w, h, pos, Vector3(scaled_w, 0, 0):rotate_with(rot), Vector3(0, 0, -scaled_h):rotate_with(rot) )

		end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

Hooks:Add("NewRaycastWeaponBaseUpdate", "NewRaycastWeaponBaseUpdate_" .. Mod:ID(), function(weapon, unit, t, dt)

	if NewRaycastWeaponBase.update_kill_tracker_text == nil then
		NewRaycastWeaponBase.update_kill_tracker_text = StatTrak.update_kill_tracker_text
	end
	if NewRaycastWeaponBase.update_kill_tracker_position == nil then
		NewRaycastWeaponBase.update_kill_tracker_position = StatTrak.update_kill_tracker_position
	end

	weapon:update_kill_tracker_text(unit, t, dt)
	weapon:update_kill_tracker_position(unit, t, dt)

end)
