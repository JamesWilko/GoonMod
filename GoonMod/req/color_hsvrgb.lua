
ColorHSVRGB = class()

local KeyEnabled 	= "Enabled"
local KeyRedHue 	= "RH"
local KeyGreenSat 	= "GS"
local KeyBlueValue 	= "BV"
local KeyUseHSV 	= "UseHSV"

function ColorHSVRGB:init( options_table, default_color )
	self._options = options_table or {}
	self._default = default_color
end

function ColorHSVRGB:IsEnabled()
	return self._options[KeyEnabled]
end

function ColorHSVRGB:GetRedHue()
	return self._options[KeyRedHue]
end

function ColorHSVRGB:GetGreenSaturation()
	return self._options[KeyGreenSat]
end

function ColorHSVRGB:GetBlueValue()
	return self._options[KeyBlueValue]
end

function ColorHSVRGB:IsUsingHSV()
	return self._options[KeyUseHSV]
end

function ColorHSVRGB:GetColor(alpha)

	if not self:IsEnabled() then
		return self._default
	end

	local r, g, b = self:GetRedHue(), self:GetGreenSaturation(), self:GetBlueValue()
	if self:IsUsingHSV() then
		r, g, b = self:ToRGB(r, g, b)
	end

	return Color(alpha or 1, r, g, b)

end

function ColorHSVRGB:GetRainbowColor( time, speed )
	t = t or 1
	speed = speed or 1
	local r, g, b = self:ToRGB( math.sin((speed * time) % 80), self:GetGreenSaturation(), self:GetBlueValue() )
	return Color( r, g, b )
end

function ColorHSVRGB:ToRGB(h, s, v)
 
	local r, g, b

	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	local mod = i % 6
	if mod == 0 then
		r = v
		g = t
		b = p
	elseif mod == 1 then
		r = q
		g = v
		b = p
	elseif mod == 2 then
		r = p
		g = v
		b = t
	elseif mod == 3 then
		r = p
		g = q
		b = v
	elseif mod == 4 then
		r = t
		g = p
		b = v
	elseif mod == 5 then
		r = v
		g = p
		b = q
	end

	return r, g, b

end
