----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWeaponLaser"
Mod.Name = "Custom Weapon Laser Colour"
Mod.Desc = "Set a custom colour for lasers attached to your weapons"
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.Priority = 1

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Weapon Laser
GoonBase.WeaponLaser = GoonBase.WeaponLaser or {}
local Laser = GoonBase.WeaponLaser
Laser.MenuId = "goonbase_weapon_laser_menu"
Laser.Color = nil

-- Localization
local Localization = GoonBase.Localization
Localization.Options_WeaponLaserName = "Weapon Laser Color"
Localization.Options_WeaponLaserDesc = "Modify the color of weapon lasers"
Localization.Options_WeaponLaserEnableTitle = "Enable Custom Weapon Laser Color"
Localization.Options_WeaponLaserEnableDesc = "Use the custom set color for Weapon Lasers"
Localization.Options_WeaponLaserRainbowTitle = "Enable Rainbow Laser"
Localization.Options_WeaponLaserRainbowDesc = "Enable rainbow instead of the set Hue"
Localization.Options_WeaponLaserRainbowSpeedTitle = "Rainbow Speed"
Localization.Options_WeaponLaserRainbowSpeedDesc = "Set the speed of the rainbow effect"

-- Options
if GoonBase.Options.WeaponLaser == nil then
	GoonBase.Options.WeaponLaser = {}
	GoonBase.Options.WeaponLaser.Enabled = false
	GoonBase.Options.WeaponLaser.R = 1
	GoonBase.Options.WeaponLaser.G = 0.1
	GoonBase.Options.WeaponLaser.B = 0.1
	GoonBase.Options.WeaponLaser.HSV = false
	GoonBase.Options.WeaponLaser.Rainbow = false
	GoonBase.Options.WeaponLaser.RainbowSpeed = 10
end

-- Functions
function Laser:IsEnabled()
	return GoonBase.Options.WeaponLaser.Enabled
end

function Laser:IsRainbow()
	return GoonBase.Options.WeaponLaser.Rainbow
end

function Laser:GetColor(alpha)
	if Laser.Color == nil then
		Laser.Color = ColorHSVRGB:new()
		Laser.Color:SetOptionsTable( "WeaponLaser" )
	end
	return Laser.Color:GetColor( alpha ) or Color( alpha or 1, 1, 0, 0 )
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_WeaponLaser", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Laser.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_WeaponLaser", function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "weapon_laser_button",
		title = "Options_WeaponLaserName",
		desc = "Options_WeaponLaserDesc",
		next_node = Laser.MenuId,
		menu_id = "goonbase_options_menu",
		priority = 100
	})

	-- Enabled Toggle
	MenuCallbackHandler.toggle_custom_weapon_laser_color = function(this, item)
		GoonBase.Options.WeaponLaser.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_custom_weapon_laser_color",
		title = "Options_WeaponLaserEnableTitle",
		desc = "Options_WeaponLaserEnableDesc",
		callback = "toggle_custom_weapon_laser_color",
		value = GoonBase.Options.WeaponLaser.Enabled,
		menu_id = Laser.MenuId,
		priority = 11
	})

	-- RGB/HSV Colour
	Laser.Color = ColorHSVRGB:new()
	Laser.Color:SetID( "weapon_laser" )
	Laser.Color:SetPriority( 5 )
	Laser.Color:SetOptionsTable( "WeaponLaser" )
	Laser.Color:SetupMenu( Laser.MenuId )

	-- Rainbow Laser
	MenuCallbackHandler.toggle_weapon_laser_rainbow = function(this, item)
		GoonBase.Options.WeaponLaser.Rainbow = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.weapon_laser_rainbow_speed = function(this, item)
		GoonBase.Options.WeaponLaser.RainbowSpeed = item:value()
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_weapon_laser_rainbow",
		title = "Options_WeaponLaserRainbowTitle",
		desc = "Options_WeaponLaserRainbowDesc",
		callback = "toggle_weapon_laser_rainbow",
		value = GoonBase.Options.WeaponLaser.Rainbow,
		menu_id = Laser.MenuId,
		priority = 2
	})

	GoonBase.MenuHelper:AddSlider({
		id = "weapon_light_rainbow_speed",
		title = "Options_WeaponLaserRainbowSpeedTitle",
		desc = "Options_WeaponLaserRainbowSpeedDesc",
		callback = "weapon_laser_rainbow_speed",
		value = GoonBase.Options.WeaponLaser.RainbowSpeed,
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = Laser.MenuId,
		priority = 1,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_WeaponLaser", function(menu_manager, mainmenu_nodes)
	local menu_id = Laser.MenuId
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id )
end)

-- Hooks
Hooks:Add("WeaponLaserInit", "WeaponLaserUpdate_CustomLaser", function(laser, unit)

	if not Laser:IsEnabled() then
		return
	end

	if laser._is_npc then
		return
	end

	laser:set_color( Laser:GetColor() )

end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_Rainbow", function(laser, unit, t, dt)

	if not Laser:IsEnabled() then
		return
	end

	if laser._is_npc then
		return
	end

	if not Laser:IsRainbow() then
		laser:set_color( Laser:GetColor() )
	end

	if Laser:IsRainbow() then
		Laser:GetColor()
		local r, g, b = Laser.Color:ToRGB( math.sin(GoonBase.Options.WeaponLaser.RainbowSpeed * t), GoonBase.Options.WeaponLaser.G, GoonBase.Options.WeaponLaser.B )
		laser:set_color( Color(r, g, b) )
	end

end)

-- END OF FILE
