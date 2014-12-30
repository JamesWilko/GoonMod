----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GrenadeIndicator"
Mod.Name = "Grenade Indicator"
Mod.Desc = "Show an indicator on your HUD as an enemy grenade is thrown"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Localization
local Localization = GoonBase.Localization
Localization.OptionsMenu_GrenadeMarker = "Show Markers on Flashbangs"
Localization.OptionsMenu_GrenadeMarkerDesc = "Show a HUD marker when a flashbang is deployed"

-- Options
GoonBase.Options.GrenadeIndicator = GoonBase.Options.GrenadeIndicator or {}
GoonBase.Options.GrenadeIndicator.ShowGrenadeMarker = true

local WaypointName = "GoonBaseGrenadeWaypoint_"

-- Hooks
Hooks:Add( "QuickSmokeGrenadeActivate", "QuickSmokeGrenadeActivate_GrenadeIndicator", function( this, pos, duration )

	if GoonBase.Options.GrenadeIndicator.ShowGrenadeMarker then

		this.grenadeID = tostring(math.random(0, 10000))
		managers.hud:add_waypoint(
			WaypointName .. this.grenadeID,
			{ icon = 'pd2_kill', distance = true, position = pos, no_sync = false, present_timer = 0, state = "present", radius = 100, color = Color.yellow, blend_mode = "add" } 
		)

	end

end )

Hooks:Add( "QuickSmokeGrenadeDetonate", "QuickSmokeGrenadeDetonate_GrenadeIndicator", function( this )

	if GoonBase.Options.GrenadeIndicator.ShowGrenadeMarker then
		managers.hud:remove_waypoint( WaypointName .. this.grenadeID )
	end

end )

-- Add options to menu
Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_GrenadeIndicator", function( menu_manager )

	local success, err = pcall(function()

		MenuCallbackHandler.toggle_grenade_marker = function(this, item)
			GoonBase.Options.GrenadeIndicator.ShowGrenadeMarker = item:value() == "on" and true or false
			GoonBase.Options:Save()
		end

		GoonBase.MenuHelper:AddToggle({
			id = "toggle_grenade_marker",
			title = "OptionsMenu_GrenadeMarker",
			desc = "OptionsMenu_GrenadeMarkerDesc",
			callback = "toggle_grenade_marker",
			value = GoonBase.Options.GrenadeIndicator.ShowGrenadeMarker,
			menu_id = "goonbase_options_menu",
			priority = -1
		})

	end)
	if not success then PrintTable(err) end

end)
-- END OF FILE
