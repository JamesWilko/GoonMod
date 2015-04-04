
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWeaponFlashlight"
Mod.Name = "Custom Flashlight Colour - Players"
Mod.Desc = "Modify the color of flashlights attached to your weapons"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Weapon Light
GoonBase.WeaponLight = GoonBase.WeaponLight or {}
local Light = GoonBase.WeaponLight
Light.MenuFile = "custom_flashlight_menu.txt"

-- Options
GoonBase.Options.WeaponLight 				= GoonBase.Options.WeaponLight or {}
GoonBase.Options.WeaponLight.Enabled 		= GoonBase.Options.WeaponLight.Enabled or true
GoonBase.Options.WeaponLight.RH 			= GoonBase.Options.WeaponLight.RH or 1
GoonBase.Options.WeaponLight.GS 			= GoonBase.Options.WeaponLight.GS or 1
GoonBase.Options.WeaponLight.BV 			= GoonBase.Options.WeaponLight.BV or 1
GoonBase.Options.WeaponLight.UseHSV 		= GoonBase.Options.WeaponLight.UseHSV or false
GoonBase.Options.WeaponLight.UseRainbow 	= GoonBase.Options.WeaponLight.UseRainbow or false
GoonBase.Options.WeaponLight.RainbowSpeed 	= GoonBase.Options.WeaponLight.RainbowSpeed or 1
if GoonBase.Options.WeaponLight.Enabled == nil then
	GoonBase.Options.WeaponLight.Enabled = true
end
if GoonBase.Options.WeaponLight.UseHSV == nil then
	GoonBase.Options.WeaponLight.UseHSV = false
end
if GoonBase.Options.WeaponLight.UseRainbow == nil then
	GoonBase.Options.WeaponLight.UseRainbow = false
end

-- Light Colour
Light.Color = ColorHSVRGB:new( GoonBase.Options.WeaponLight, Color.white )

-- Functions
function Light:IsEnabled()
	return GoonBase.Options.WeaponLight.Enabled
end

function Light:IsRainbow()
	return GoonBase.Options.WeaponLight.UseRainbow
end

function Light:RainbowSpeed()
	return GoonBase.Options.WeaponLight.RainbowSpeed
end

function Light:GetColor(alpha)
	return Light.Color:GetColor( alpha )
end

function Light:ShowPreviewMenuItem()

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

function Light:DestroyPreviewMenuItem()

	if alive(self._panel) then

		self._panel:remove( self._color_rect )
		self._panel:remove( self._panel )

		self._color_rect = nil
		self._panel = nil

	end

end

function Light:UpdatePreview( t )

	if not alive(self._panel) or not alive(self._color_rect) or not Light.Color then
		return
	end

	if self:IsRainbow() and t then
		self._color_rect:set_color( Light.Color:GetRainbowColor(t, self:RainbowSpeed()) )
	else
		self._color_rect:set_color( Light.Color:GetColor() )
	end

end

-- Menu
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	-- Callbacks
	MenuCallbackHandler.CustomFlashlightMenuChangeFocus = function( node, focus )
		if focus then
			Light:ShowPreviewMenuItem()
		else
			Light:DestroyPreviewMenuItem()
		end
	end

	MenuCallbackHandler.ToggleEnableCustomFlashlight = function( this, item )
		GoonBase.Options.WeaponLight.Enabled = item:value() == "on" and true or false
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightToggleUseHue = function( this, item )
		GoonBase.Options.WeaponLight.UseHSV = item:value() == "on" and true or false
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightSetRedHue = function( this, item )
		GoonBase.Options.WeaponLight.RH = tonumber( item:value() )
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightSetGreenSaturation = function( this, item )
		GoonBase.Options.WeaponLight.GS = tonumber( item:value() )
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightSetBlueValue = function( this, item )
		GoonBase.Options.WeaponLight.BV = tonumber( item:value() )
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightSetUseRainbow = function( this, item )
		GoonBase.Options.WeaponLight.UseRainbow = item:value() == "on" and true or false
		Light:UpdatePreview()
	end

	MenuCallbackHandler.CustomFlashlightSetRainbowSpeed = function( this, item )
		GoonBase.Options.WeaponLight.RainbowSpeed = tonumber( item:value() )
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. Light.MenuFile, GoonBase.WeaponLight, GoonBase.Options.WeaponLight )

end)

-- Hooks
Hooks:Add("MenuUpdate", "MenuUpdate_" .. Mod:ID(), function(t, dt)
	if Light:IsRainbow() then
		Light:UpdatePreview( t )
	end
end)

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_" .. Mod:ID(), function(t, dt)
	if Light:IsRainbow() then
		Light:UpdatePreview( t )
	end
end)

Hooks:Add("WeaponFlashLightInit", "WeaponFlashLightInit_" .. Mod:ID(), function(flashlight, unit)

	if not Light:IsEnabled() then
		Hooks:Remove("WeaponFlashLightInit_CustomLight")
		return
	end

	flashlight._light:set_color( Light:GetColor() )

end)

Hooks:Add("WeaponFlashLightCheckState", "WeaponFlashLightCheckState_" .. Mod:ID(), function(flashlight)

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

Hooks:Add("WeaponFlashLightUpdate", "WeaponFlashLightUpdate_" .. Mod:ID(), function(flashlight, unit, t, dt)

	if not Light:IsEnabled() then
		return
	end

	if not Light:IsRainbow() then
		flashlight._light:set_color( Light:GetColor() )
	end

	if Light:IsRainbow() then
		flashlight._light:set_color( Light.Color:GetRainbowColor( t, Light:RainbowSpeed() ) )
	end

end)
