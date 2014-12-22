----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/23/2014 2:05:54 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWorldLaserColour"
Mod.Name = "Custom World Laser Colour"
Mod.Desc = "Set a custom colour for lasers that appear in the game world"
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.Priority = 1

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Lasers
GoonBase.WorldLasers = GoonBase.WorldLasers or {}
local Lasers = GoonBase.WorldLasers
Lasers.MenuId = "goonbase_world_laser_menu"
Lasers.Color = nil

-- Localization
local Localization = GoonBase.Localization
Localization.Options_WorldLaserName = "World Laser Color"
Localization.Options_WorldLaserDesc = "Modify the color of lasers that appear in the world"
Localization.Options_WorldLaserEnableTitle = "Enable Custom World Laser Color"
Localization.Options_WorldLaserEnableDesc = "Use the custom set color for World Lasers"
Localization.Options_WorldLaserRainbowTitle = "Enable Rainbow Laser"
Localization.Options_WorldLaserRainbowDesc = "Enable rainbow instead of the set Hue"
Localization.Options_WorldLaserRainbowSpeedTitle = "Rainbow Speed"
Localization.Options_WorldLaserRainbowSpeedDesc = "Set the speed of the rainbow effect"

-- Options
if GoonBase.Options.WorldLasers == nil then
	GoonBase.Options.WorldLasers = {}
	GoonBase.Options.WorldLasers.Enabled = false
	GoonBase.Options.WorldLasers.R = 1
	GoonBase.Options.WorldLasers.G = 0.1
	GoonBase.Options.WorldLasers.B = 0.1
	GoonBase.Options.WorldLasers.HSV = false
	GoonBase.Options.WorldLasers.Rainbow = false
	GoonBase.Options.WorldLasers.RainbowSpeed = 10
end

-- Functions
function Lasers:IsEnabled()
	return GoonBase.Options.WorldLasers.Enabled
end

function Lasers:IsRainbow()
	return GoonBase.Options.WorldLasers.Rainbow
end

function Lasers:GetColor(alpha)
	if Lasers.Color == nil then
		Lasers.Color = ColorHSVRGB:new()
		Lasers.Color:SetOptionsTable( "WorldLasers" )
	end
	return Lasers.Color:GetColor( alpha ) or Color( alpha or 1, 1, 0, 0 )
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_WorldLaser", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Lasers.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_WorldLaser", function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "world_laser_button",
		title = "Options_WorldLaserName",
		desc = "Options_WorldLaserDesc",
		next_node = Lasers.MenuId,
		menu_id = "goonbase_options_menu",
	})

	-- Enabled Toggle
	MenuCallbackHandler.toggle_custom_world_laser_color = function(this, item)
		GoonBase.Options.WorldLasers.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_custom_world_laser_color",
		title = "Options_WorldLaserEnableTitle",
		desc = "Options_WorldLaserEnableDesc",
		callback = "toggle_custom_world_laser_color",
		value = GoonBase.Options.WorldLasers.Enabled,
		menu_id = Lasers.MenuId,
		priority = 11
	})

	-- RGB/HSV Colour
	Lasers.Color = ColorHSVRGB:new()
	Lasers.Color:SetID( "world_laser" )
	Lasers.Color:SetPriority( 5 )
	Lasers.Color:SetOptionsTable( "WorldLasers" )
	Lasers.Color:SetupMenu( Lasers.MenuId )

	-- Rainbow Laser
	MenuCallbackHandler.toggle_world_laser_rainbow = function(this, item)
		GoonBase.Options.WorldLasers.Rainbow = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.world_laser_rainbow_speed = function(this, item)
		GoonBase.Options.WorldLasers.RainbowSpeed = item:value()
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_world_laser_rainbow",
		title = "Options_WorldLaserRainbowTitle",
		desc = "Options_WorldLaserRainbowDesc",
		callback = "toggle_world_laser_rainbow",
		value = GoonBase.Options.WorldLasers.Rainbow,
		menu_id = Lasers.MenuId,
		priority = 2
	})

	GoonBase.MenuHelper:AddSlider({
		id = "world_laser_rainbow_speed",
		title = "Options_WorldLaserRainbowSpeedTitle",
		desc = "Options_WorldLaserRainbowSpeedDesc",
		callback = "world_laser_rainbow_speed",
		value = GoonBase.Options.WorldLasers.RainbowSpeed,
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = Lasers.MenuId,
		priority = 1,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_WorldLaser", function(menu_manager, mainmenu_nodes)
	local menu_id = Lasers.MenuId
	local data = {
		area_bg = "half"
	}
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id, data )
end)

-- Hooks
Hooks:Add("ElementLaserTriggerPostInit", "ElementLaserTriggerPostInit_WorldLaser", function(laser)

	if not Lasers:IsEnabled() then
		return
	end

	laser._brush:set_color( Lasers:GetColor(0.15) )

end)

Hooks:Add("ElementLaserTriggerUpdateDraw", "ElementLaserTriggerUpdateDraw_WorldLaser", function(laser, t, dt)

	if not Lasers:IsEnabled() then
		return
	end
	
    if not Lasers:IsRainbow() then
		laser._brush:set_color( Lasers:GetColor() )
	end

	if Lasers:IsRainbow() then
		Lasers:GetColor()
		local r, g, b = Lasers.Color:ToRGB( math.sin(GoonBase.Options.WorldLasers.RainbowSpeed * t), GoonBase.Options.WorldLasers.G, GoonBase.Options.WorldLasers.B )
		laser._brush:set_color( Color(0.2, r, g, b) )
	end

end)

-- END OF FILE
