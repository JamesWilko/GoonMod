----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/23/2014 2:39:17 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomEnemyWeaponLaser"
Mod.Name = "Custom Enemy Laser Colour"
Mod.Desc = "Set a custom colour for lasers attached to enemy weapons"
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
GoonBase.EnemyLaser = GoonBase.EnemyLaser or {}
local Laser = GoonBase.EnemyLaser
Laser.MenuId = "goonbase_enemy_laser_menu"
Laser.Color = nil

-- Localization
local Localization = GoonBase.Localization
Localization.Options_EnemyLaserName = "Enemy Laser Color"
Localization.Options_EnemyLaserDesc = "Modify the color of enemy's weapons lasers"
Localization.Options_EnemyLaserEnableTitle = "Enable Custom Enemy Laser Color"
Localization.Options_EnemyLaserEnableDesc = "Use the custom set color for enemy's weapons Lasers"
Localization.Options_EnemyLaserRainbowTitle = "Enable Rainbow Laser"
Localization.Options_EnemyLaserRainbowDesc = "Enable rainbow instead of the set Hue"
Localization.Options_EnemyLaserRainbowSpeedTitle = "Rainbow Speed"
Localization.Options_EnemyLaserRainbowSpeedDesc = "Set the speed of the rainbow effect"

-- Options
if GoonBase.Options.EnemyLaser == nil then
	GoonBase.Options.EnemyLaser = {}
	GoonBase.Options.EnemyLaser.Enabled = false
	GoonBase.Options.EnemyLaser.R = 1
	GoonBase.Options.EnemyLaser.G = 0.1
	GoonBase.Options.EnemyLaser.B = 0.1
	GoonBase.Options.EnemyLaser.HSV = false
	GoonBase.Options.EnemyLaser.Rainbow = false
	GoonBase.Options.EnemyLaser.RainbowSpeed = 10
end

-- Functions
function Laser:IsEnabled()
	return GoonBase.Options.EnemyLaser.Enabled
end

function Laser:IsRainbow()
	return GoonBase.Options.EnemyLaser.Rainbow
end

function Laser:GetColor(alpha)
	if Laser.Color == nil then
		Laser.Color = ColorHSVRGB:new()
		Laser.Color:SetOptionsTable( "EnemyLaser" )
	end
	return Laser.Color:GetColor( alpha ) or Color( alpha or 1, 1, 0, 0 )
end

function Laser:IsNPCPlayerUnitLaser( laser )

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
									return true
								end

							end
						end

					end

				end

			end

		end
	end

	return false

end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_EnemyLaser", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Laser.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_EnemyLaser", function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "enemy_laser_button",
		title = "Options_EnemyLaserName",
		desc = "Options_EnemyLaserDesc",
		next_node = Laser.MenuId,
		menu_id = "goonbase_options_menu"
	})

	-- Enabled Toggle
	MenuCallbackHandler.toggle_custom_enemy_laser_color = function(this, item)
		GoonBase.Options.EnemyLaser.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_custom_enemy_laser_color",
		title = "Options_EnemyLaserEnableTitle",
		desc = "Options_EnemyLaserEnableDesc",
		callback = "toggle_custom_enemy_laser_color",
		value = GoonBase.Options.EnemyLaser.Enabled,
		menu_id = Laser.MenuId,
		priority = 11
	})

	-- RGB/HSV Colour
	Laser.Color = ColorHSVRGB:new()
	Laser.Color:SetID( "enemy_laser" )
	Laser.Color:SetPriority( 5 )
	Laser.Color:SetOptionsTable( "EnemyLaser" )
	Laser.Color:SetupMenu( Laser.MenuId )

	-- Rainbow Laser
	MenuCallbackHandler.toggle_enemy_laser_rainbow = function(this, item)
		GoonBase.Options.EnemyLaser.Rainbow = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.enemy_laser_rainbow_speed = function(this, item)
		GoonBase.Options.EnemyLaser.RainbowSpeed = item:value()
		GoonBase.Options:Save()
	end

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_enemy_laser_rainbow",
		title = "Options_EnemyLaserRainbowTitle",
		desc = "Options_EnemyLaserRainbowDesc",
		callback = "toggle_enemy_laser_rainbow",
		value = GoonBase.Options.EnemyLaser.Rainbow,
		menu_id = Laser.MenuId,
		priority = 2
	})

	GoonBase.MenuHelper:AddSlider({
		id = "enemy_laser_rainbow_speed",
		title = "Options_EnemyLaserRainbowSpeedTitle",
		desc = "Options_EnemyLaserRainbowSpeedDesc",
		callback = "enemy_laser_rainbow_speed",
		value = GoonBase.Options.EnemyLaser.RainbowSpeed,
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = Laser.MenuId,
		priority = 1,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_EnemyLaser", function(menu_manager, mainmenu_nodes)
	local menu_id = Laser.MenuId
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id )
end)

-- Hooks
Hooks:Add("WeaponLaserPostSetColorByTheme", "WeaponLaserPostSetColorByTheme_CustomEnemyLaser", function(laser, unit)

	if not Laser:IsEnabled() then
		return
	end

	if not laser._is_npc or Laser:IsNPCPlayerUnitLaser( laser ) then
		return
	end

	laser:set_color( Laser:GetColor() )

end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_EnemyRainbow", function(laser, unit, t, dt)

	if not Laser:IsEnabled() then
		return
	end

	if not laser._is_npc or Laser:IsNPCPlayerUnitLaser( laser ) then
		return
	end

	if not Laser:IsRainbow() then
		laser:set_color( Laser:GetColor() )
	end

	if Laser:IsRainbow() then
		Laser:GetColor()
		local r, g, b = Laser.Color:ToRGB( math.sin(GoonBase.Options.EnemyLaser.RainbowSpeed * t), GoonBase.Options.EnemyLaser.G, GoonBase.Options.EnemyLaser.B )
		laser:set_color( Color(r, g, b) )
	end

end)

-- END OF FILE
