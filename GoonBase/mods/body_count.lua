----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "BodyCountMod"
Mod.Name = "Corpse Delimiter"
Mod.Desc = "Change the amount of bodies that can appear after enemies are killed"
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.EnabledByDefault = true

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Body Count Mod
_G.GoonBase.CorpseDelimiter = _G.GoonBase.CorpseDelimiter or {}
local CorpseDelimiter = _G.GoonBase.CorpseDelimiter
local body_count_menu_id = "goonbase_corpse_mod_menu"
CorpseDelimiter.RemoveAllBodiesKey = "BodyCountModRemoveAll"
CorpseDelimiter.RemoveAllShieldsKey = "BodyCountModRemoveShields"
CorpseDelimiter.CustomKeys = {
	REMOVE_ALL = GoonBase.Options.BodyCount ~= nil and GoonBase.Options.BodyCount.RemoveAllBodiesKey or "",
	REMOVE_SHIELDS = GoonBase.Options.BodyCount ~= nil and GoonBase.Options.BodyCount.RemoveAllShieldsKey or ""
}

-- Options
if GoonBase.Options.BodyCount == nil then
	GoonBase.Options.BodyCount = {}
	GoonBase.Options.BodyCount.CustomCorpseLimit = true
	GoonBase.Options.BodyCount.MaxCorpses = 1024
	GoonBase.Options.BodyCount.CurrentMaxCorpses = 1024
	GoonBase.Options.BodyCount.RemoveShields = false
	GoonBase.Options.BodyCount.ShieldTime = 60
	GoonBase.Options.BodyCount.MaxShieldTime = 600
	GoonBase.Options.BodyCount.RemoveAllBodiesKey = ""
	GoonBase.Options.BodyCount.RemoveAllShieldsKey = ""
end

-- Localization
local Localization = GoonBase.Localization
Localization.OptionsMenu_CorpseSubmenuTitle = "Corpses"
Localization.OptionsMenu_CorpseSubmenuDesc = "Change settings for the ingame Corpses"
Localization.OptionsMenu_CorpseToggle = "Use Custom Corpse Amount"
Localization.OptionsMenu_CorpseToggleDesc = "Use the custom amount of corpses instead of the default amount (8)"
Localization.OptionsMenu_CorpseAmount = "Corpse Amount"
Localization.OptionsMenu_CorpseAmountDesc = "Maximum number of corpses allowed (Current: {1})"
Localization.OptionsMenu_CorpseShieldToggle = "Despawn Shields"
Localization.OptionsMenu_CorpseShieldToggleDesc = "Despawn shields after a short time"
Localization.OptionsMenu_CorpseShieldTimer = "Shield Despawn Time"
Localization.OptionsMenu_CorpseShieldTimerDesc = "Despawn shields after {1} seconds"
Localization.OptionsMenu_RemoveAllCorpses = "Remove All Corpses"
Localization.OptionsMenu_RemoveAllCorpsesDesc = "Key to clean up all corpses in the level when pressed"
Localization.OptionsMenu_RemoveAllShields = "Remove All Shields"
Localization.OptionsMenu_RemoveAllShieldsDesc = "Key to clean up all shields in the level when pressed"

Localization.OptionsMenu_CorpseAmountDesc_Default = Localization.OptionsMenu_CorpseAmountDesc
Localization.OptionsMenu_CorpseShieldTimerDesc_Default = Localization.OptionsMenu_CorpseShieldTimerDesc

-- Stop bodies from despawning
Hooks:Add("EnemyManagerPreUpdateCorpseDisposal", "EnemyManagerPreUpdateCorpseDisposal_BodyCount", function(enemy_manager)
	enemy_manager._MAX_NR_CORPSES = GoonBase.Options.BodyCount.CustomCorpseLimit and GoonBase.Options.BodyCount.CurrentMaxCorpses or 8
end)

-- Despawn shields after time
local shield_timer_id = 0
Hooks:Add("CopInventoryDropShield", "CopInventoryDropShield_BodyCount", function(inventory)

	if GoonBase.Options.BodyCount.CustomCorpseLimit and GoonBase.Options.BodyCount.RemoveShields then

		local id = "CopInventoryDropShield_" .. tostring(shield_timer_id)
		shield_timer_id = shield_timer_id + 1

		Queue:Add(id, function()
			if inventory ~= nil then
				inventory:destroy_all_items()
			end
		end, GoonBase.Options.BodyCount.ShieldTime)

	end

end)

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_BodyCount", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( body_count_menu_id )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_BodyCount", function( menu_manager )

	-- Add corpse mod menu button
	GoonBase.MenuHelper:AddButton({
		id = "corpse_mod_menu_button",
		title = "OptionsMenu_CorpseSubmenuTitle",
		desc = "OptionsMenu_CorpseSubmenuDesc",
		next_node = body_count_menu_id,
		menu_id = "goonbase_options_menu"
	})

	-- Callbacks
	MenuCallbackHandler.toggle_corpse = function(this, item)
		GoonBase.Options.BodyCount.CustomCorpseLimit = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.set_corpse_amount = function(this, item)
		GoonBase.Options.BodyCount.CurrentMaxCorpses = math.floor( item:value() )
		GoonBase.Localization.OptionsMenu_CorpseAmountDesc = GoonBase.Localization.OptionsMenu_CorpseAmountDesc_Default:gsub("{1}", GoonBase.Options.BodyCount.CurrentMaxCorpses)
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.toggle_shield_timer = function(this, item)
		GoonBase.Options.BodyCount.RemoveShields = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.set_shield_timer = function(this, item)
		GoonBase.Options.BodyCount.ShieldTime = math.floor( item:value() )
		GoonBase.Localization.OptionsMenu_CorpseShieldTimerDesc = GoonBase.Localization.OptionsMenu_CorpseShieldTimerDesc_Default:gsub("{1}", GoonBase.Options.BodyCount.ShieldTime)
		GoonBase.Options:Save()
	end

	-- Localization
	GoonBase.Localization.OptionsMenu_CorpseAmountDesc = GoonBase.Localization.OptionsMenu_CorpseAmountDesc_Default:gsub("{1}", GoonBase.Options.BodyCount.CurrentMaxCorpses)
	GoonBase.Localization.OptionsMenu_CorpseShieldTimerDesc = GoonBase.Localization.OptionsMenu_CorpseShieldTimerDesc_Default:gsub("{1}", GoonBase.Options.BodyCount.ShieldTime)

	-- Custom Corpse Amount Toggle
	GoonBase.MenuHelper:AddToggle({
		id = "toggle_custom_corpse",
		title = "OptionsMenu_CorpseToggle",
		desc = "OptionsMenu_CorpseToggleDesc",
		callback = "toggle_corpse",
		value = GoonBase.Options.BodyCount.CustomCorpseLimit,
		menu_id = body_count_menu_id,
		priority = 50
	})

	-- Corpse Amount Slider
	GoonBase.MenuHelper:AddSlider({
		id = "corpse_amount_slider",
		title = "OptionsMenu_CorpseAmount",
		desc = "OptionsMenu_CorpseAmountDesc",
		callback = "set_corpse_amount",
		value = GoonBase.Options.BodyCount.CurrentMaxCorpses,
		min = 8,
		max = GoonBase.Options.BodyCount.MaxCorpses,
		step = 1,
		show_value = true,
		menu_id = body_count_menu_id,
		priority = 49
	})

	-- Despawn Shields
	GoonBase.MenuHelper:AddToggle({
		id = "toggle_shield_timer",
		title = "OptionsMenu_CorpseShieldToggle",
		desc = "OptionsMenu_CorpseShieldToggleDesc",
		callback = "toggle_shield_timer",
		value = GoonBase.Options.BodyCount.RemoveShields,
		menu_id = body_count_menu_id,
		priority = 48
	})

	-- Shield Timer Slider
	GoonBase.MenuHelper:AddSlider({
		id = "shield_timer_slider",
		title = "OptionsMenu_CorpseShieldTimer",
		desc = "OptionsMenu_CorpseShieldTimerDesc",
		callback = "set_shield_timer",
		value = GoonBase.Options.BodyCount.ShieldTime,
		min = 15,
		max = GoonBase.Options.BodyCount.MaxShieldTime,
		step = 1,
		show_value = true,
		menu_id = body_count_menu_id,
		priority = 47
	})

	-- Remove bindings
	GoonBase.MenuHelper:AddDivider({
		id = "keybind_corpse_menu_divider",
		menu_id = body_count_menu_id,
		size = 16,
		priority = 30,
	})

	GoonBase.MenuHelper:AddKeybinding({
		id = "keybind_corpse_remove_all",
		title = managers.localization:text("OptionsMenu_RemoveAllCorpses"),
		desc = managers.localization:text("OptionsMenu_RemoveAllCorpsesDesc"),
		connection_name = CorpseDelimiter.RemoveAllBodiesKey,
		button = CorpseDelimiter.CustomKeys.REMOVE_ALL,
		binding = CorpseDelimiter.CustomKeys.REMOVE_ALL,
		menu_id = body_count_menu_id,
		priority = 20
	})

	GoonBase.MenuHelper:AddKeybinding({
		id = "keybind_corpse_remove_shields",
		title = managers.localization:text("OptionsMenu_RemoveAllShields"),
		desc = managers.localization:text("OptionsMenu_RemoveAllShieldsDesc"),
		connection_name = CorpseDelimiter.RemoveAllShieldsKey,
		button = CorpseDelimiter.CustomKeys.REMOVE_SHIELDS,
		binding = CorpseDelimiter.CustomKeys.REMOVE_SHIELDS,
		menu_id = body_count_menu_id,
		priority = 19
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BodyCount", function(menu_manager, mainmenu_nodes)
	mainmenu_nodes[body_count_menu_id] = GoonBase.MenuHelper:BuildMenu( body_count_menu_id )
end)

-- Custom keybinds
Hooks:Add("CustomizeControllerOnKeySet", "CustomizeControllerOnKeySet_" .. Mod:ID(), function(item)

	local psuccess, perror = pcall(function()
	
	if item._name == CorpseDelimiter.RemoveAllBodiesKey then
		CorpseDelimiter.CustomKeys.REMOVE_ALL = item._input_name_list[1]
		CorpseDelimiter:SaveBindings()
	end

	if item._name == CorpseDelimiter.RemoveAllShieldsKey then
		CorpseDelimiter.CustomKeys.REMOVE_SHIELDS = item._input_name_list[1]
		CorpseDelimiter:SaveBindings()
	end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end)

function CorpseDelimiter:SaveBindings()
	GoonBase.Options.BodyCount.RemoveAllBodiesKey = CorpseDelimiter.CustomKeys.REMOVE_ALL
	GoonBase.Options.BodyCount.RemoveAllShieldsKey = CorpseDelimiter.CustomKeys.REMOVE_SHIELDS
	GoonBase.Options:Save()
end

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_" .. Mod:ID(), function(t, dt)
	CorpseDelimiter:UpdateBindings()
end)

function CorpseDelimiter:UpdateBindings()

	if self._input == nil then
		self._input = Input:keyboard()
	end
	if managers.hud:chat_focus() then
		return
	end

	local remove_all_key = CorpseDelimiter.CustomKeys.REMOVE_ALL
	if not string.is_nil_or_empty(remove_all_key) and self._input:pressed(Idstring(remove_all_key)) then
		if not managers.groupai:state():whisper_mode() then
			managers.enemy:dispose_all_corpses()
		end
	end

	local remove_shields_key = CorpseDelimiter.CustomKeys.REMOVE_SHIELDS
	if not string.is_nil_or_empty(remove_shields_key) and self._input:pressed(Idstring(remove_shields_key)) then
		CorpseDelimiter:RemoveAllShields()
	end

end

function CorpseDelimiter:RemoveAllShields()

	local enemy_data = managers.enemy._enemy_data
	local corpses = enemy_data.corpses
	for u_key, u_data in pairs(corpses) do
		if u_data.unit:inventory() ~= nil then
			u_data.unit:inventory():destroy_all_items()
		end
	end

end
-- END OF FILE
