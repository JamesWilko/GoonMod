
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWeaponLaserColour"
Mod.Name = "Custom Laser Colour - Players"
Mod.Desc = "Modify the color of your own, and your teammates weapon lasers"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Lasers
GoonBase.WeaponLasers = GoonBase.WeaponLasers or {}
local Lasers = GoonBase.WeaponLasers
Lasers.MenuFile = "custom_weapon_laser_menu.txt"
Lasers.NetworkID = "gmcpwlc"
Lasers._WorldOpacity = 0.4

-- Options
GoonBase.Options.WeaponLasers 				= GoonBase.Options.WeaponLasers or {}
GoonBase.Options.WeaponLasers.Enabled 		= GoonBase.Options.WeaponLasers.Enabled or true
GoonBase.Options.WeaponLasers.RH 			= GoonBase.Options.WeaponLasers.RH or 0.0
GoonBase.Options.WeaponLasers.GS 			= GoonBase.Options.WeaponLasers.GS or 0.75
GoonBase.Options.WeaponLasers.BV 			= GoonBase.Options.WeaponLasers.BV or 0.0
GoonBase.Options.WeaponLasers.UseHSV 		= GoonBase.Options.WeaponLasers.UseHSV or false
GoonBase.Options.WeaponLasers.UseRainbow 	= GoonBase.Options.WeaponLasers.UseRainbow or false
GoonBase.Options.WeaponLasers.RainbowSpeed 	= GoonBase.Options.WeaponLasers.RainbowSpeed or 1
GoonBase.Options.WeaponLasers.TeamLasers 	= GoonBase.Options.WeaponLasers.TeamLasers or 3

-- Laser Colours
Lasers.Color = ColorHSVRGB:new( GoonBase.Options.WeaponLasers, Color.red:with_alpha(0.6) )
Lasers.TeammateColours = Lasers.TeammateColours or {}
Lasers.UniquePlayerColours = Lasers.UniquePlayerColours or {
	[1] = Color("29ce31"),
	[2] = Color("00eae8"),
	[3] = Color("f99d1c"),
	[4] = Color("ebe818"),
	[5] = Color("ebe818"),
}

-- Functions
function Lasers:IsEnabled()
	return GoonBase.Options.WeaponLasers.Enabled
end

function Lasers:IsRainbow()
	return GoonBase.Options.WeaponLasers.UseRainbow
end

function Lasers:RainbowSpeed()
	return GoonBase.Options.WeaponLasers.RainbowSpeed
end

function Lasers:GetColor(alpha)
	return Lasers.Color:GetColor( alpha )
end

function Lasers:AreTeamLasersOff()
	return GoonBase.Options.WeaponLasers.TeamLasers == 1
end

function Lasers:AreTeamLasersSameColour()
	return GoonBase.Options.WeaponLasers.TeamLasers == 2
end

function Lasers:AreTeamLasersNetworked()
	return GoonBase.Options.WeaponLasers.TeamLasers == 3
end

function Lasers:AreTeamLasersUnique()
	return GoonBase.Options.WeaponLasers.TeamLasers == 4
end

function Lasers:GetCriminalNameFromLaserUnit( laser )

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

	for id, character in pairs(criminals_manager._characters) do
		if alive(character.unit) and character.unit:inventory() and character.unit:inventory():equipped_unit() then

			local weapon_base = character.unit:inventory():equipped_unit():base()
			if Lasers:CheckWeaponForLasers( weapon_base, laser_key ) then
				self._laser_units_lookup[laser_key] = character.name
				return
			end

			if weapon_base._second_gun then
				if Lasers:CheckWeaponForLasers( weapon_base._second_gun:base(), laser_key ) then
					self._laser_units_lookup[laser_key] = character.name
					return
				end
			end

		end
	end

	if laser_key then
		self._laser_units_lookup[laser_key] = false
	end
	return nil

end

function Lasers:CheckWeaponForLasers( weapon_base, key )

	if weapon_base and weapon_base._factory_id and weapon_base._blueprint then

		local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weapon_base._factory_id, weapon_base._blueprint)
		if gadgets then
			for _, i in ipairs(gadgets) do

				local gadget_key = weapon_base._parts[i].unit:key()
				if gadget_key == key then
					return true
				end

			end
		end

	end
	return false

end

function Lasers:UpdateLaser( laser, unit, t, dt )

	if not Lasers:IsEnabled() then
		return
	end

	if laser._is_npc then

		local criminal_name = Lasers:GetCriminalNameFromLaserUnit( laser )
		if not criminal_name then
			return
		end

		if Lasers:AreTeamLasersOff() then
			Lasers:SetColourOfLaser( laser, unit, t, dt, Color.green:with_alpha(0.1) )
			return
		end

		if Lasers:AreTeamLasersSameColour() then
			Lasers:SetColourOfLaser( laser, unit, t, dt )
			return
		end

		if Lasers:AreTeamLasersNetworked() then
			local color = Lasers.TeammateColours[criminal_name]
			if color then
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
			end
			return
		end

		if Lasers:AreTeamLasersUnique() then
			local id = managers.criminals:character_color_id_by_name( criminal_name )
			if id == 1 then id = id + 1 end
			local color = Lasers.UniquePlayerColours[ id or 5 ]:with_alpha(Lasers._WorldOpacity)
			if color then
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
			end
			return
		end

	end

	Lasers:SetColourOfLaser( laser, unit, t, dt )

end

function Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )

	if override_color then
		if override_color ~= "rainbow" then
			laser:set_color( override_color )
		else
			if type(override_color) == "string" then
				laser:set_color_by_theme( override_color )
			else
				laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
			end
		end
		return
	end

	if not Lasers:IsRainbow() then
		laser:set_color( Lasers:GetColor( Lasers._WorldOpacity ) )
		return
	end

	if Lasers:IsRainbow() then
		laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
		return
	end

end


function Lasers:ShowPreviewMenuItem()

	if not managers.menu_component then
		return
	end

	local ws = managers.menu_component._ws
	self._panel = ws:panel():panel()

	local w, h = self._panel:w() * 0.35, 48
	self._color_rect = self._panel:rect({
		w = w,
		h = h,
		color = Color.red,
		blend_mode = "add",
		layer = tweak_data.gui.MOUSE_LAYER - 50,
	})
	self._color_rect:set_right( self._panel:right() )
	self._color_rect:set_top( self._panel:h() * 0.265 )

	self:UpdatePreview()

end

function Lasers:DestroyPreviewMenuItem()

	if alive(self._panel) then

		self._panel:remove( self._color_rect )
		self._panel:remove( self._panel )

		self._color_rect = nil
		self._panel = nil

	end

end

function Lasers:UpdatePreview( t )

	if not alive(self._panel) or not alive(self._color_rect) or not Lasers.Color then
		return
	end

	if self:IsRainbow() and t then
		self._color_rect:set_color( Lasers.Color:GetRainbowColor(t, self:RainbowSpeed()) )
	else
		self._color_rect:set_color( Lasers.Color:GetColor() )
	end

end

-- Menu
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	-- Callbacks
	MenuCallbackHandler.CustomWeaponLaserMenuChangeFocus = function( node, focus )
		if focus then
			Lasers:ShowPreviewMenuItem()
		else
			Lasers:DestroyPreviewMenuItem()
		end
	end

	MenuCallbackHandler.ToggleEnableCustomWeaponLaser = function( this, item )
		GoonBase.Options.WeaponLasers.Enabled = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserToggleUseHue = function( this, item )
		GoonBase.Options.WeaponLasers.UseHSV = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserSetRedHue = function( this, item )
		GoonBase.Options.WeaponLasers.RH = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserSetGreenSaturation = function( this, item )
		GoonBase.Options.WeaponLasers.GS = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserSetBlueValue = function( this, item )
		GoonBase.Options.WeaponLasers.BV = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserSetUseRainbow = function( this, item )
		GoonBase.Options.WeaponLasers.UseRainbow = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWeaponLaserSetRainbowSpeed = function( this, item )
		GoonBase.Options.WeaponLasers.RainbowSpeed = tonumber( item:value() )
	end

	MenuCallbackHandler.CustomWeaponLaserSetTeammateLaser = function( this, item )
		GoonBase.Options.WeaponLasers.TeamLasers = tonumber( item:value() )
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. Lasers.MenuFile, GoonBase.WeaponLasers, GoonBase.Options.WeaponLasers )

end)

-- Hooks
Hooks:Add("MenuUpdate", "MenuUpdate_" .. Mod:ID(), function(t, dt)
	if Lasers:IsRainbow() then
		Lasers:UpdatePreview( t )
	end
end)

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_" .. Mod:ID(), function(t, dt)
	if Lasers:IsRainbow() then
		Lasers:UpdatePreview( t )
	end
end)

Hooks:Add("WeaponLaserInit", "WeaponLaserInit_" .. Mod:ID(), function(laser, unit)
	Lasers:UpdateLaser(laser, unit, 0, 0)
end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_Rainbow_" .. Mod:ID(), function(laser, unit, t, dt)
	Lasers:UpdateLaser(laser, unit, t, dt)
end)

Hooks:Add("WeaponLaserSetOn", "WeaponLaserSetOn_" .. Mod:ID(), function(laser)

	if laser._is_npc then
		return
	end

	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end

	local local_name = criminals_manager:local_character_name()
	local laser_name = Lasers:GetCriminalNameFromLaserUnit( laser )
	if laser_name == nil or local_name == laser_name then
		local col_str = LuaNetworking:ColourToString( Lasers:GetColor() )
		if Lasers:IsRainbow() then
			col_str = "rainbow"
		end
		LuaNetworking:SendToPeers( Lasers.NetworkID, col_str )
	end

end)

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_" .. Mod:ID(), function(sender, message, data)

	if message == Lasers.NetworkID then

		local criminals_manager = managers.criminals
		if not criminals_manager then
			return
		end

		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		if data ~= "rainbow" then
			col = LuaNetworking:StringToColour(data)
		end

		if char then
			Lasers.TeammateColours[char] = col
		end

	end

end)
