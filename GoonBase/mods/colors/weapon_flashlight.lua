----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWeaponFlashlight"
Mod.Name = "Custom Weapon Flashlight Colour"
Mod.Desc = "Set a custom colour for flashlights attached to your weapons"
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.Priority = 1

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Weapon Light
GoonBase.WeaponLight = GoonBase.WeaponLight or {}
local Light = GoonBase.WeaponLight
Light.MenuId = "goonbase_weapon_light_menu"
Light.Color = nil

-- Localization
local Localization = GoonBase.Localization
Localization.Options_WeaponLightName = "Weapon Flashlight Color"
Localization.Options_WeaponLightDesc = "Modify the color of weapon flashlights"
Localization.Options_WeaponLightEnableTitle = "Enable Custom Weapon Flashlight Color"
Localization.Options_WeaponLightEnableDesc = "Use the custom set color for Weapon Flashlights"
Localization.Options_WeaponLightRainbowTitle = "Enable Rainbow Light"
Localization.Options_WeaponLightRainbowDesc = "Enable rainbow instead of the set Hue"
Localization.Options_WeaponLightRainbowSpeedTitle = "Rainbow Speed"
Localization.Options_WeaponLightRainbowSpeedDesc = "Set the speed of the rainbow effect"

-- Options
if GoonBase.Options.WeaponLight == nil then
	GoonBase.Options.WeaponLight = {}
	GoonBase.Options.WeaponLight.Enabled = false
	GoonBase.Options.WeaponLight.R = 1
	GoonBase.Options.WeaponLight.G = 0.1
	GoonBase.Options.WeaponLight.B = 0.1
	GoonBase.Options.WeaponLight.HSV = false
	GoonBase.Options.WeaponLight.Rainbow = false
	GoonBase.Options.WeaponLight.RainbowSpeed = 10
end

-- Functions
function Light:IsEnabled()
	return GoonBase.Options.WeaponLight.Enabled
end

function Light:IsRainbow()
	return GoonBase.Options.WeaponLight.Rainbow
end

function Light:GetColor(alpha)
	if Light.Color == nil then
		Light.Color = ColorHSVRGB:new()
		Light.Color:SetOptionsTable( "WeaponLight" )
	end
	return Light.Color:GetColor( alpha ) or Color( alpha or 1, 1, 0, 0 )
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_WeaponLight", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Light.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_WeaponLight", function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "weapon_light_button",
		title = "Options_WeaponLightName",
		desc = "Options_WeaponLightDesc",
		next_node = Light.MenuId,
		menu_id = "goonbase_options_menu",
	})

	-- Enabled Toggle
	MenuCallbackHandler.toggle_custom_weapon_light_color = function(this, item)
		GoonBase.Options.WeaponLight.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_custom_weapon_light_color",
		title = "Options_WeaponLightEnableTitle",
		desc = "Options_WeaponLightEnableDesc",
		callback = "toggle_custom_weapon_light_color",
		value = GoonBase.Options.WeaponLight.Enabled,
		menu_id = Light.MenuId,
		priority = 11
	})

	-- RGB/HSV Colour
	Light.Color = ColorHSVRGB:new()
	Light.Color:SetID( "weapon_light" )
	Light.Color:SetPriority( 5 )
	Light.Color:SetOptionsTable( "WeaponLight" )
	Light.Color:SetupMenu( Light.MenuId )

	-- Rainbow Laser
	MenuCallbackHandler.toggle_weapon_light_rainbow = function(this, item)
		GoonBase.Options.WeaponLight.Rainbow = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.weapon_light_rainbow_speed = function(this, item)
		GoonBase.Options.WeaponLight.RainbowSpeed = item:value()
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_weapon_light_rainbow",
		title = "Options_WeaponLightRainbowTitle",
		desc = "Options_WeaponLightRainbowDesc",
		callback = "toggle_weapon_light_rainbow",
		value = GoonBase.Options.WeaponLight.Rainbow,
		menu_id = Light.MenuId,
		priority = 2
	})

	GoonBase.MenuHelper:AddSlider({
		id = "weapon_light_rainbow_speed",
		title = "Options_WeaponLightRainbowSpeedTitle",
		desc = "Options_WeaponLightRainbowSpeedDesc",
		callback = "weapon_light_rainbow_speed",
		value = GoonBase.Options.WeaponLight.RainbowSpeed,
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = Light.MenuId,
		priority = 1,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_WeaponLight", function(menu_manager, mainmenu_nodes)
	local menu_id = Light.MenuId
	local data = {
		area_bg = "half"
	}
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id, data )
end)

-- Hooks
Hooks:Add("WeaponFlashLightInit", "WeaponFlashLightInit_CustomLight", function(flashlight, unit)

	if not Light:IsEnabled() then
		Hooks:Remove("WeaponFlashLightInit_CustomLight")
		return
	end

	flashlight._light:set_color( Light:GetColor() )

end)

Hooks:Add("WeaponFlashLightCheckState", "WeaponFlashLightCheckState_CustomLight", function(flashlight)

	if flashlight._on then

		flashlight._unit:set_extension_update_enabled( Idstring("base"), flashlight._on )

		Hooks:RegisterHook("WeaponFlashLightUpdate")
		flashlight._old_update = flashlight.update
		flashlight.update = function(self, unit, t, dt)
			Hooks:Call( "WeaponFlashLightUpdate", self, unit, t, dt )
			if flashlight.overkill_update ~= nil then
				flashlight.overkill_update(self, unit, t, dt)
			end
		end

	end

end)

Hooks:Add("WeaponFlashLightUpdate", "WeaponFlashLightUpdate_Rainbow", function(flashlight, unit, t, dt)

	local psuccess, perror = pcall(function()

		if not Light:IsEnabled() then
			return
		end

		if not Light:IsRainbow() then
			flashlight._light:set_color( Light:GetColor() )
		end

		if Light:IsRainbow() then

			Light:GetColor()
			local r, g, b = Light.Color:ToRGB( math.sin(GoonBase.Options.WeaponLight.RainbowSpeed * t), GoonBase.Options.WeaponLight.G, GoonBase.Options.WeaponLight.B )
			flashlight._light:set_color( Color(r * 2, g * 2, b * 2) )

		end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end)
-- END OF FILE
