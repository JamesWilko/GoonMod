
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
Laser.OtherColours = {}

-- Networking
Laser.Network = Laser.Network or {}
local Network = Laser.Network
Network.SendLaserColour = "CustomLaserColour"

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

	if not self._laser_units_lookup then
		self._laser_units_lookup = {}
	end

	local laser_key = nil
	if laser._unit then
		laser_key = laser._unit:key()
	end
	if laser_key and self._laser_units_lookup[laser_key] ~= nil then
		return self._laser_units_lookup[laser_key]
	end

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
									if laser_key then
										self._laser_units_lookup[laser_key] = data.name
									end
									return data.name
								end

							end
						end

					end

				end

			end

		end
	end

	if laser_key then
		self._laser_units_lookup[laser_key] = false
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
	MenuHelper:NewMenu( Laser.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function(menu_manager, menu_nodes)

	-- Submenu Button
	MenuHelper:AddButton({
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

	MenuHelper:AddToggle({
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

	MenuHelper:AddToggle({
		id = "toggle_weapon_laser_rainbow",
		title = "Options_WeaponLaserRainbowTitle",
		desc = "Options_WeaponLaserRainbowDesc",
		callback = "toggle_weapon_laser_rainbow",
		value = GoonBase.Options.WeaponLaser.Rainbow,
		menu_id = Laser.MenuId,
		priority = 25
	})

	MenuHelper:AddSlider({
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

	MenuHelper:AddDivider({
		id = "weapon_laser_divider",
		menu_id = Laser.MenuId,
		size = 16,
		priority = 21,
	})

	MenuHelper:AddMultipleChoice({
		id = "weapon_laser_teammate_choice",
		title = "Options_TeammateLaserOption",
		desc = "Options_TeammateLaserOptionDesc",
		callback = "weapon_laser_set_teammate",
		menu_id = Laser.MenuId,
		priority = 20,
		items = {
			[1] = "Options_TeammateLaser_Same",
			[2] = "Options_TeammateLaser_Unique",
			[3] = "Options_TeammateLaser_Theirs",
		},
		value = GoonBase.Options.WeaponLaser.TeammateLasers,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_" .. Mod:ID(), function(menu_manager, mainmenu_nodes)
	local menu_id = Laser.MenuId
	local data = {
		area_bg = "half"
	}
	mainmenu_nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )
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
			if not criminal_name then
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
				local col = Laser.OtherColours[criminal_name]
				Laser:SetColourOfLaser( laser, unit, t, dt, col )
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

	if colour_override ~= nil and colour_override ~= "rainbow" then
		local psuccess, perror = pcall(function()
			laser:set_color( colour_override:with_alpha(0.4) )
		end)
		if not psuccess then
			Print("[Error] " .. perror)
		end
		return
	end

	if not Laser:IsRainbow() then
		laser:set_color( Laser:GetColor(0.4) )
	end

	if Laser:IsRainbow() or colour_override == "rainbow" then
		Laser:GetColor()
		local r, g, b = Laser.Color:ToRGB( math.sin(GoonBase.Options.WeaponLaser.RainbowSpeed * t), GoonBase.Options.WeaponLaser.G, GoonBase.Options.WeaponLaser.B )
		laser:set_color( Color(r, g, b):with_alpha(0.4) )
	end

end

-- Networked Colour
Hooks:Add("WeaponLaserSetOn", "WeaponLaserSetOn_" .. Mod:ID(), function(laser)

	if laser._is_npc then
		return
	end

	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end

	local local_name = criminals_manager:local_character_name()
	local laser_name = Laser:GetCriminalNameFromLaserUnit( laser )
	if laser_name == nil or local_name == laser_name then
		local col_str = LuaNetworking:PrepareNetworkedColourString( Laser:GetColor() )
		if Laser:IsRainbow() then
			col_str = "rainbow"
		end
		LuaNetworking:SendToPeers( Network.SendLaserColour, col_str )
	end

end)

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_" .. Mod:ID(), function(sender, message, data)

	if message == Network.SendLaserColour then

		local criminals_manager = managers.criminals
		if not criminals_manager then
			return
		end

		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		if data ~= "rainbow" then
			col = LuaNetworking:NetworkedColourStringToColour(data)
		end

		if char then
			Laser.OtherColours[char] = col
		end

	end

end)
