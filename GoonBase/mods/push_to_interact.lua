----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local interact_menu_id = "goonbase_pushtointeract_menu"

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "PushToInteract"
Mod.Name = "Push to Interact"
Mod.Desc = "Push interact key to toggle interacting with an object"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Options
GoonBase.Options.PushToInteract = GoonBase.Options.PushToInteract or {}
GoonBase.Options.PushToInteract.Enabled = true
GoonBase.Options.PushToInteract.ReleaseTime = 0.2

-- Localization
local Localization = GoonBase.Localization
Localization.OptionsMenu_PushInteractSubmenuTitle = "Push to Interact"
Localization.OptionsMenu_PushInteractSubmenuDesc = "Change settings for Push to Interact"
Localization.OptionsMenu_PushInteractEnableTitle = "Enable Push to Interact"
Localization.OptionsMenu_PushInteractEnableDesc = "Enable Push to Interact, pushing the interact button will automatically hold the button until it is pushed again"
Localization.OptionsMenu_PushInteractTimeTitle = "Push Grace Period"
Localization.OptionsMenu_PushInteractTimeDesc = "Grace period of the push, if the button is held longer than the grace period, then the push will not be enabled. (Current: {1} sec)"
Localization.OptionsMenu_PushInteractTimeDesc_Default = Localization.OptionsMenu_PushInteractTimeDesc

-- Hooks
local DELAY_RELEASE = false
local RELEASE_LOCK = false

Hooks:Add("PlayerStandardCheckActionInteract", "PlayerStandardCheckActionInteract_PushToInteract", function(ply, t, input)

	if not GoonBase.Options.PushToInteract.Enabled then
		return
	end

	ply._last_interact_press_t = ply._last_interact_press_t or 0

	if input.btn_interact_press then

		ply._last_interact_press_t = t
		if ply:_interacting() then
			ply:_interupt_action_interact()
			return false
		end

	elseif input.btn_interact_release then

		local dt = t - (ply._last_interact_press_t + GoonBase.Options.PushToInteract.ReleaseTime)
		local delayed = (DELAY_RELEASE and RELEASE_LOCK) or not (DELAY_RELEASE or RELEASE_LOCK)
		if delayed and dt <= 0 or RELEASE_LOCK and dt >= 0 then
			return false
		end

	end

end)

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_PushToInteract", function( menu_manager, menu_nodes )
	GoonBase.MenuHelper:NewMenu( interact_menu_id )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_PushToInteract", function( menu_manager )

	-- Add corpse mod menu button
	GoonBase.MenuHelper:AddButton({
		id = "pushtointeract_mod_menu_button",
		title = "OptionsMenu_PushInteractSubmenuTitle",
		desc = "OptionsMenu_PushInteractSubmenuDesc",
		next_node = interact_menu_id,
		menu_id = "goonbase_options_menu"
	})

	-- Callbacks
	MenuCallbackHandler.toggle_pushtointeract = function(this, item)
		GoonBase.Options.PushToInteract.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.set_pushtointeract_grace_period = function(this, item)
		GoonBase.Options.PushToInteract.ReleaseTime = tonumber( item:value() )
		GoonBase.Localization.OptionsMenu_PushInteractTimeDesc = GoonBase.Localization.OptionsMenu_PushInteractTimeDesc_Default:gsub("{1}", GoonBase.Options.PushToInteract.ReleaseTime)
		GoonBase.Options:Save()
	end

	-- Localization
	GoonBase.Localization.OptionsMenu_PushInteractTimeDesc = GoonBase.Localization.OptionsMenu_PushInteractTimeDesc_Default:gsub("{1}", GoonBase.Options.PushToInteract.ReleaseTime)

	-- Custom Corpse Amount Toggle
	GoonBase.MenuHelper:AddToggle({
		id = "pushtointeract_toggle",
		title = "OptionsMenu_PushInteractEnableTitle",
		desc = "OptionsMenu_PushInteractEnableDesc",
		callback = "toggle_pushtointeract",
		value = GoonBase.Options.PushToInteract.Enabled,
		menu_id = interact_menu_id,
		priority = 2
	})

	-- Corpse Amount Slider
	GoonBase.MenuHelper:AddSlider({
		id = "pushtointeract_timer_slider",
		title = "OptionsMenu_PushInteractTimeTitle",
		desc = "OptionsMenu_PushInteractTimeDesc",
		callback = "set_pushtointeract_grace_period",
		value = GoonBase.Options.PushToInteract.ReleaseTime,
		min = 0.02,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = interact_menu_id,
		priority = 1
	})


end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_PushToInteract", function( menu_manager, mainmenu_nodes )
	mainmenu_nodes[interact_menu_id] = GoonBase.MenuHelper:BuildMenu( interact_menu_id )
end)

-- END OF FILE
