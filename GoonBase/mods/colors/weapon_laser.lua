----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/23/2014 2:39:17 PM
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
Laser.UniquePlayerColours = {
	[1] = Color("29ce31"), -- MrGreen
	[2] = Color("00eae8"), -- MrBlue
	[3] = Color("f99d1c"), -- MrBrown
	[4] = Color("ebe818"), -- MrOrange
	[5] = Color("ebe818"), -- MrAI
}

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
Localization.Options_TeammateLaserOption = "Teammate Lasers"
Localization.Options_TeammateLaserOptionDesc = "Set how teammate lasers should appear"
Localization.Options_TeammateLaser_Same = "Use My Colour"
Localization.Options_TeammateLaser_Theirs = "Use Their Colour"
Localization.Options_TeammateLaser_Unique = "Unique per Person"

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
	GoonBase.Options.WeaponLaser.TeammateLasers = 1
end

-- Functions
function Laser:IsEnabled()
	return GoonBase.Options.WeaponLaser.Enabled
end

function Laser:IsRainbow()
	return GoonBase.Options.WeaponLaser.Rainbow
end

function Laser:GetColor( alpha )
	if Laser.Color == nil then
		Laser.Color = ColorHSVRGB:new()
		Laser.Color:SetOptionsTable( "WeaponLaser" )
	end
	return Laser.Color:GetColor( alpha ) or Color( alpha or 1, 1, 0, 0 )
end

function Laser:GetCriminalNameFromLaserUnit( laser )

	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end

	for id, data in pairs(criminals_manager._characters) do
		if data.unit ~= nil and alive(data.unit) and data.name ~= criminals_manager:local_character_name() then

			if data.unit:inventory() and data.unit:inventory():equipped_unit() then 

				local wep_base = data.unit:inventory():equipped_unit():base()
				if wep_base then

					if wep_base._factory_id ~= nil and wep_base._blueprint ~= nil then

						local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", wep_base._factory_id, wep_base._blueprint)
						if gadgets then
							local gadget
							for _, i in ipairs(gadgets) do

								gadget = wep_base._parts[i]
								gadget = gadget.unit:base()

								if gadget == laser then
									return data.name
								end

							end
						end

					end

				end

			end

		end
	end

	return nil

end

function Laser:UsingSameColour()
	return GoonBase.Options.WeaponLaser.TeammateLasers == 1
end

function Laser:UsingUniqueColour()
	return GoonBase.Options.WeaponLaser.TeammateLasers == 2
end

function Laser:UsingPlayerColour()
	return GoonBase.Options.WeaponLaser.TeammateLasers == 3
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_" .. Mod:ID(), function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Laser.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "weapon_laser_button",
		title = "Options_WeaponLaserName",
		desc = "Options_WeaponLaserDesc",
		next_node = Laser.MenuId,
		menu_id = "goonbase_options_menu",
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
		priority = 50
	})

	-- RGB/HSV Colour
	Laser.Color = ColorHSVRGB:new()
	Laser.Color:SetID( "weapon_laser" )
	Laser.Color:SetPriority( 30 )
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

	MenuCallbackHandler.weapon_laser_set_teammate = function(this, item)
		GoonBase.Options.WeaponLaser.TeammateLasers = tonumber(item:value())
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_weapon_laser_rainbow",
		title = "Options_WeaponLaserRainbowTitle",
		desc = "Options_WeaponLaserRainbowDesc",
		callback = "toggle_weapon_laser_rainbow",
		value = GoonBase.Options.WeaponLaser.Rainbow,
		menu_id = Laser.MenuId,
		priority = 25
	})

	GoonBase.MenuHelper:AddSlider({
		id = "weapon_laser_rainbow_speed",
		title = "Options_WeaponLaserRainbowSpeedTitle",
		desc = "Options_WeaponLaserRainbowSpeedDesc",
		callback = "weapon_laser_rainbow_speed",
		value = GoonBase.Options.WeaponLaser.RainbowSpeed,
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = Laser.MenuId,
		priority = 24,
	})

	GoonBase.MenuHelper:AddDivider({
		id = "weapon_laser_divider",
		menu_id = Laser.MenuId,
		size = 16,
		priority = 21,
	})

	GoonBase.MenuHelper:AddMultipleChoice({
		id = "weapon_laser_teammate_choice",
		title = "Options_TeammateLaserOption",
		desc = "Options_TeammateLaserOptionDesc",
		callback = "weapon_laser_set_teammate",
		menu_id = Laser.MenuId,
		priority = 20,
		items = {
			[1] = "Options_TeammateLaser_Same",
			[2] = "Options_TeammateLaser_Unique",
			-- [3] = "Options_TeammateLaser_Theirs",
		},
		value = GoonBase.Options.WeaponLaser.TeammateLasers,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_" .. Mod:ID(), function(menu_manager, mainmenu_nodes)
	local menu_id = Laser.MenuId
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id )
end)

-- Hooks
Hooks:Add("WeaponLaserInit", "WeaponLaserInit_" .. Mod:ID(), function(laser, unit)
	Laser:UpdateLaser(laser, unit, 0, 0)
end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_Rainbow_" .. Mod:ID(), function(laser, unit, t, dt)
	Laser:UpdateLaser(laser, unit, t, dt)
end)

function Laser:UpdateLaser( laser, unit, t, dt )

	local psuccess, perror = pcall(function()

		if not Laser:IsEnabled() then
			return
		end

		if laser._is_npc then

			local criminal_name = Laser:GetCriminalNameFromLaserUnit( laser )
			if criminal_name == nil then
				return
			end

			if Laser:UsingSameColour() then
				Laser:SetColourOfLaser( laser, unit, t, dt )
			end

			if Laser:UsingUniqueColour() then
				local id = managers.criminals:character_color_id_by_name( criminal_name )
				if id == 1 then id = id + 1 end
				local col = Laser.UniquePlayerColours[ id or 5 ]
				Laser:SetColourOfLaser( laser, unit, t, dt, col )
			end

			if Laser:UsingPlayerColour() then
				Laser:SetColourOfLaser( laser, unit, t, dt )
			end

			return

		end

		Laser:SetColourOfLaser( laser, unit, t, dt )

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

function Laser:SetColourOfLaser( laser, unit, t, dt, colour_override )

	if colour_override ~= nil then
		laser:set_color( colour_override:with_alpha(0.4) )
		return
	end

	if not Laser:IsRainbow() then
		laser:set_color( Laser:GetColor(0.4) )
	end

	if Laser:IsRainbow() then
		Laser:GetColor()
		local r, g, b = Laser.Color:ToRGB( math.sin(GoonBase.Options.WeaponLaser.RainbowSpeed * t), GoonBase.Options.WeaponLaser.G, GoonBase.Options.WeaponLaser.B )
		laser:set_color( Color(r, g, b):with_alpha(0.4) )
	end

end

-- END OF FILE
