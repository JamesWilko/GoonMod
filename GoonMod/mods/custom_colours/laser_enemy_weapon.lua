
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomEnemyWeaponLaser"
Mod.Name = "Custom Laser Colour - Enemy"
Mod.Desc = "Set a custom colour for lasers attached to enemy weapons"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Lasers
GoonBase.EnemyLasers = GoonBase.EnemyLasers or {}
local Lasers = GoonBase.EnemyLasers
Lasers.MenuFile = "custom_enemy_laser_menu.txt"
Lasers._WorldOpacity = 0.4

-- Options
GoonBase.Options.EnemyLasers 				= GoonBase.Options.EnemyLasers or {}
GoonBase.Options.EnemyLasers.Enabled 		= GoonBase.Options.EnemyLasers.Enabled or true
GoonBase.Options.EnemyLasers.RH 			= GoonBase.Options.EnemyLasers.RH or 0.8
GoonBase.Options.EnemyLasers.GS 			= GoonBase.Options.EnemyLasers.GS or 0.0
GoonBase.Options.EnemyLasers.BV 			= GoonBase.Options.EnemyLasers.BV or 0.0
GoonBase.Options.EnemyLasers.UseHSV 		= GoonBase.Options.EnemyLasers.UseHSV or false
GoonBase.Options.EnemyLasers.UseRainbow 	= GoonBase.Options.EnemyLasers.UseRainbow or false
GoonBase.Options.EnemyLasers.RainbowSpeed 	= GoonBase.Options.EnemyLasers.RainbowSpeed or 1
if GoonBase.Options.EnemyLasers.Enabled == nil then
	GoonBase.Options.EnemyLasers.Enabled = true
end
if GoonBase.Options.EnemyLasers.UseHSV == nil then
	GoonBase.Options.EnemyLasers.UseHSV = false
end
if GoonBase.Options.EnemyLasers.UseRainbow == nil then
	GoonBase.Options.EnemyLasers.UseRainbow = false
end

-- Laser Colour
Lasers.Color = ColorHSVRGB:new( GoonBase.Options.EnemyLasers, Color.red:with_alpha(0.6) )

-- Functions
function Lasers:IsEnabled()
	return GoonBase.Options.EnemyLasers.Enabled
end

function Lasers:IsRainbow()
	return GoonBase.Options.EnemyLasers.UseRainbow
end

function Lasers:RainbowSpeed()
	return GoonBase.Options.EnemyLasers.RainbowSpeed
end

function Lasers:GetColor(alpha)
	return Lasers.Color:GetColor( alpha )
end

function Lasers:IsNPCPlayerUnitLaser( laser )

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
		if alive(data.unit) and data.name ~= criminals_manager:local_character_name() and data.unit:inventory() and data.unit:inventory():equipped_unit() then

			local wep_base = data.unit:inventory():equipped_unit():base()
			local weapon_base = data.unit:inventory():equipped_unit():base()
			if Lasers:CheckWeaponForLasers( weapon_base, laser_key ) then
				self._laser_units_lookup[laser_key] = true
				return
			end

			if weapon_base._second_gun then
				if Lasers:CheckWeaponForLasers( weapon_base._second_gun:base(), laser_key ) then
					self._laser_units_lookup[laser_key] = true
					return
				end
			end

		end
	end

	if laser_key then
		self._laser_units_lookup[laser_key] = false
	end
	return false

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
	MenuCallbackHandler.CustomEnemyLaserMenuChangeFocus = function( node, focus )
		if focus then
			Lasers:ShowPreviewMenuItem()
		else
			Lasers:DestroyPreviewMenuItem()
		end
	end

	MenuCallbackHandler.ToggleEnableCustomEnemyLaser = function( this, item )
		GoonBase.Options.EnemyLasers.Enabled = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserToggleUseHue = function( this, item )
		GoonBase.Options.EnemyLasers.UseHSV = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserSetRedHue = function( this, item )
		GoonBase.Options.EnemyLasers.RH = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserSetGreenSaturation = function( this, item )
		GoonBase.Options.EnemyLasers.GS = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserSetBlueValue = function( this, item )
		GoonBase.Options.EnemyLasers.BV = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserSetUseRainbow = function( this, item )
		GoonBase.Options.EnemyLasers.UseRainbow = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomEnemyLaserSetRainbowSpeed = function( this, item )
		GoonBase.Options.EnemyLasers.RainbowSpeed = tonumber( item:value() )
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. Lasers.MenuFile, GoonBase.EnemyLasers, GoonBase.Options.EnemyLasers )

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

Hooks:Add("WeaponLaserPostSetColorByTheme", "WeaponLaserPostSetColorByTheme_CustomEnemyLaser", function(laser, unit)

	if not Lasers:IsEnabled() then
		return
	end

	if laser._is_npc and not Lasers:IsNPCPlayerUnitLaser( laser ) then
		laser:set_color( Lasers:GetColor(Lasers._WorldOpacity) )
	end

end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_EnemyRainbow", function(laser, unit, t, dt)

	if not Lasers:IsEnabled() then
		return
	end

	if laser._is_npc and not Lasers:IsNPCPlayerUnitLaser( laser ) then

		if not Lasers:IsRainbow() then
			laser:set_color( Lasers:GetColor() )
		else
			laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
		end

	end
	
end)
