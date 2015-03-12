-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GrenadeRestriction"
Mod.Name = "Grenade Restriction"
Mod.Desc = "Prevent accidental grenade-throwing by requiring an initial double-tap"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

local grenade_restriction_menu_id = "goonbase_grenade_restriction_mod_menu"

-- Localization
local Localization = GoonBase.Localization
Localization.OptionsMenu_GrenadeRestriction = "Grenade Restriction"
Localization.OptionsMenu_GrenadeRestrictionDesc = "Prevent accidental grenade-throwing by requiring an initial double-tap"
Localization.OptionsMenu_GrenadeRestrictionSubmenuTitle = "Grenade Restriction"
Localization.OptionsMenu_GrenadeRestrictionSubmenuDesc = "Change settings for grenade-throwing restrictions"
Localization.OptionsMenu_GrenadeRestrictionEnabled = "Enabled"
Localization.OptionsMenu_GrenadeRestrictionEnabledDesc = "Turn grenade-throwing restrictions on or off."
Localization.OptionsMenu_GrenadeRestrictionThreshold = "Threshold"
Localization.OptionsMenu_GrenadeRestrictionThresholdDesc = "Amount of time within which the grenade button must be pressed to activate (Current: {1})"

Localization.OptionsMenu_GrenadeRestrictionThresholdDesc_Default = Localization.OptionsMenu_GrenadeRestrictionThresholdDesc

-- Options
if GoonBase.Options.GrenadeRestriction == nil then
	GoonBase.Options.GrenadeRestriction = {}
	GoonBase.Options.GrenadeRestriction.Enabled = true
	GoonBase.Options.GrenadeRestriction.Threshold = 0.25
end

-- Hooks
Hooks:Add( "PlayerStandardCheckActionThrowGrenade", "PlayerStandardCheckActionThrowGrenade_DoubleTapCheck", function( this, t, input )

	if GoonBase.Options.GrenadeRestriction.Enabled then

		if input.btn_throw_grenade_press and managers.groupai:state():whisper_mode() and (not this._last_grenade_time or t > this._last_grenade_time + GoonBase.Options.GrenadeRestriction.Threshold) and not this._has_thrown_grenade then
			this._last_grenade_time = t
			return false
		end

	end

	if input.btn_throw_grenade_press then
		this._has_thrown_grenade = true
	end

end )

-- Add menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_" .. Mod:ID(), function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( grenade_restriction_menu_id )
end)

-- Add options to menu
Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function( menu_manager )

	MenuCallbackHandler.toggle_grenade_restriction = function(this, item)
		GoonBase.Options.GrenadeRestriction.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.set_grenade_restriction_threshold = function(this, item)
		GoonBase.Options.GrenadeRestriction.Threshold = item:value()
		GoonBase.Localization.OptionsMenu_GrenadeRestrictionThresholdDesc = GoonBase.Localization.OptionsMenu_GrenadeRestrictionThresholdDesc_Default:gsub("{1}", string.format("%0.2f", GoonBase.Options.GrenadeRestriction.Threshold))
		GoonBase.Options:Save()
	end

	-- Localization
	GoonBase.Localization.OptionsMenu_GrenadeRestrictionThresholdDesc = GoonBase.Localization.OptionsMenu_GrenadeRestrictionThresholdDesc_Default:gsub("{1}", string.format("%0.2f", GoonBase.Options.GrenadeRestriction.Threshold))

	GoonBase.MenuHelper:AddButton({
		id = "grenade_restriction_mod_menu_button",
		title = "OptionsMenu_GrenadeRestrictionSubmenuTitle",
		desc = "OptionsMenu_GrenadeRestrictionSubmenuDesc",
		next_node = grenade_restriction_menu_id,
		menu_id = "goonbase_options_menu"
	})

	-- Toggle Button
	GoonBase.MenuHelper:AddToggle({
		id = "toggle_grenade_restriction",
		title = "OptionsMenu_GrenadeRestriction",
		desc = "OptionsMenu_GrenadeRestrictionDesc",
		callback = "toggle_grenade_restriction",
		value = GoonBase.Options.GrenadeRestriction.Enabled,
		menu_id = grenade_restriction_menu_id,
		priority = 50
	})

	-- Threshold Slider
	GoonBase.MenuHelper:AddSlider({
		id = "grenade_restriction_threshold_slider",
		title = "OptionsMenu_GrenadeRestrictionThreshold",
		desc = "OptionsMenu_GrenadeRestrictionThresholdDesc",
		callback = "set_grenade_restriction_threshold",
		value = GoonBase.Options.GrenadeRestriction.Threshold,
		min = 0.05,
		max = 2,
		step = 0.05,
		show_value = true,
		menu_id = grenade_restriction_menu_id,
		priority = 49
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_GrenadeRestriction", function(menu_manager, mainmenu_nodes)
	mainmenu_nodes[grenade_restriction_menu_id] = GoonBase.MenuHelper:BuildMenu( grenade_restriction_menu_id )
end)
-- END OF FILE
