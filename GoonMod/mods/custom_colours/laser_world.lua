
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWorldLaserColour"
Mod.Name = "Custom Laser Colour - World"
Mod.Desc = "Modify the colour of lasers that appear in the game world"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Lasers
GoonBase.WorldLasers = GoonBase.WorldLasers or {}
local Lasers = GoonBase.WorldLasers
Lasers.MenuFile = "custom_world_laser_menu.txt"
Lasers._WorldOpacity = 0.4

-- Options
GoonBase.Options.WorldLasers 				= GoonBase.Options.WorldLasers or {}
GoonBase.Options.WorldLasers.Enabled 		= GoonBase.Options.WorldLasers.Enabled or true
GoonBase.Options.WorldLasers.RH 			= GoonBase.Options.WorldLasers.RH or 0.6
GoonBase.Options.WorldLasers.GS 			= GoonBase.Options.WorldLasers.GS or 0.0
GoonBase.Options.WorldLasers.BV 			= GoonBase.Options.WorldLasers.BV or 0.0
GoonBase.Options.WorldLasers.UseHSV 		= GoonBase.Options.WorldLasers.UseHSV or false
GoonBase.Options.WorldLasers.UseRainbow 	= GoonBase.Options.WorldLasers.UseRainbow or false
GoonBase.Options.WorldLasers.RainbowSpeed 	= GoonBase.Options.WorldLasers.RainbowSpeed or 1
if GoonBase.Options.WorldLasers.Enabled == nil then
	GoonBase.Options.WorldLasers.Enabled = true
end
if GoonBase.Options.WorldLasers.UseHSV == nil then
	GoonBase.Options.WorldLasers.UseHSV = false
end
if GoonBase.Options.WorldLasers.UseRainbow == nil then
	GoonBase.Options.WorldLasers.UseRainbow = false
end

-- Laser Colour
Lasers.Color = ColorHSVRGB:new( GoonBase.Options.WorldLasers, Color.red:with_alpha(0.6) )

-- Functions
function Lasers:IsEnabled()
	return GoonBase.Options.WorldLasers.Enabled
end

function Lasers:IsRainbow()
	return GoonBase.Options.WorldLasers.UseRainbow
end

function Lasers:RainbowSpeed()
	return GoonBase.Options.WorldLasers.RainbowSpeed
end

function Lasers:GetColor(alpha)
	return Lasers.Color:GetColor( alpha )
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
	MenuCallbackHandler.CustomWorldLaserMenuChangeFocus = function( node, focus )
		if focus then
			Lasers:ShowPreviewMenuItem()
		else
			Lasers:DestroyPreviewMenuItem()
		end
	end

	MenuCallbackHandler.ToggleEnableCustomWorldLaser = function( this, item )
		GoonBase.Options.WorldLasers.Enabled = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserToggleUseHue = function( this, item )
		GoonBase.Options.WorldLasers.UseHSV = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserSetRedHue = function( this, item )
		GoonBase.Options.WorldLasers.RH = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserSetGreenSaturation = function( this, item )
		GoonBase.Options.WorldLasers.GS = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserSetBlueValue = function( this, item )
		GoonBase.Options.WorldLasers.BV = tonumber( item:value() )
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserSetUseRainbow = function( this, item )
		GoonBase.Options.WorldLasers.UseRainbow = item:value() == "on" and true or false
		Lasers:UpdatePreview()
	end

	MenuCallbackHandler.CustomWorldLaserSetRainbowSpeed = function( this, item )
		GoonBase.Options.WorldLasers.RainbowSpeed = tonumber( item:value() )
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. Lasers.MenuFile, GoonBase.WorldLasers, GoonBase.Options.WorldLasers )

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

Hooks:Add("ElementLaserTriggerPostInit", "ElementLaserTriggerPostInit_" .. Mod:ID(), function(laser)

	if not Lasers:IsEnabled() then
		return
	end

	laser._brush:set_color( Lasers:GetColor(Lasers._WorldOpacity) )

end)

Hooks:Add("ElementLaserTriggerUpdateDraw", "ElementLaserTriggerUpdateDraw_" .. Mod:ID(), function(laser, t, dt)

	if not Lasers:IsEnabled() then
		return
	end
	
	if not Lasers:IsRainbow() then
		laser._brush:set_color( Lasers:GetColor(Lasers._WorldOpacity) )
	end

	if Lasers:IsRainbow() then
		laser._brush:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
	end

end)
