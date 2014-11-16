----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/16/2014 9:49:42 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

ColorHSVRGB = class()

function ColorHSVRGB:init()
	self._ID = "DefaultID"
	self._menu_id = nil
	self._using_hsv = false
	self._priority = 0
	self._r = 0
	self._g = 0
	self._b = 0
end

function ColorHSVRGB:ID()
	return self._ID
end

function ColorHSVRGB:UsingHSV()
	return self._using_hsv
end

function ColorHSVRGB:GetColor(alpha)

	local r, g, b = 0, 0, 0
	if self:UsingHSV() then
		r, g, b = self:ToRGB(self._r, self._g, self._b)
	else
		r = self._r
		g = self._g
		b = self._b
	end

	return Color(alpha or 1, r, g, b)

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

function ColorHSVRGB:SetID(id)
	self._ID = id
end

function ColorHSVRGB:SetHSV(hsv)
	self._using_hsv = hsv
end

function ColorHSVRGB:SetOptionsTable(tbl)

	self.options_table = tbl

	self._r = GoonBase.Options[tbl].R
	self._g = GoonBase.Options[tbl].G
	self._b = GoonBase.Options[tbl].B
	self._using_hsv = GoonBase.Options[tbl].HSV

end

function ColorHSVRGB:SetupLocalization()

	local id = self:ID()
	local hsv = self:UsingHSV()
	local Localization = GoonBase.Localization

	Localization["Options_ToggleColorHSV_Title"] = "Use HSV"
	Localization["Options_ToggleColorHSV_Message"] = "Use HSV instead of RGB"

	Localization["Options_" .. id .. "_RH_Title"] = hsv and "Hue/Red" or "Red/Hue"
	Localization["Options_" .. id .. "_GS_Title"] = hsv and "Saturation/Green" or "Green/Saturation"
	Localization["Options_" .. id .. "_BV_Title"] = hsv and "Value/Blue" or "Blue/Value"
	Localization["Options_" .. id .. "_Example"] = "Color Example"

	Localization["Options_" .. id .. "_RH_Desc"] = string.gsub( "Control the {1} of the colour", "{1}", hsv and "Hue" or "Red" )
	Localization["Options_" .. id .. "_GS_Desc"] = string.gsub( "Control the {1} of the colour", "{1}", hsv and "Saturation" or "Green" )
	Localization["Options_" .. id .. "_BV_Desc"] = string.gsub( "Control the {1} of the colour", "{1}", hsv and "Value" or "Blue" )
	Localization["Options_" .. id .. "_ExampleMessage"] = "Re-open this menu to update the color example"

end

function ColorHSVRGB:SetPriority( prio )
	self._priority = prio
end

function ColorHSVRGB:SetupMenu( menu_id )

	local id = self:ID()
	local r = GoonBase.Options[self.options_table].R
	local g = GoonBase.Options[self.options_table].G
	local b = GoonBase.Options[self.options_table].B
	local hsv = GoonBase.Options[self.options_table].HSV

	self:SetupLocalization()
	self._menu_id = menu_id

	MenuCallbackHandler["set_rh_" .. id] = function(this, item)
		self._r = item:value()
		GoonBase.Options[self.options_table].R = self._r
		GoonBase.Options:Save()
	end

	MenuCallbackHandler["set_gs_" .. id] = function(this, item)
		self._g = item:value()
		GoonBase.Options[self.options_table].G = self._g
		GoonBase.Options:Save()
	end

	MenuCallbackHandler["set_bv_" .. id] = function(this, item)
		self._b = item:value()
		GoonBase.Options[self.options_table].B = self._b
		GoonBase.Options:Save()
	end

	MenuCallbackHandler["toggle_hsv_" .. id] = function(this, item)

		local enabled = item:value() == "on" and true or false
		self:SetHSV( enabled )
		GoonBase.Options[self.options_table].HSV = enabled
		GoonBase.Options:Save()

		self:SetupLocalization()

	end

	GoonBase.MenuHelper:AddSlider({
		id = "slider_rh_" .. id,
		title = "Options_" .. id .. "_RH_Title",
		desc = "Options_" .. id .. "_RH_Desc",
		callback = "set_rh_" .. id,
		value = r,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = menu_id,
		priority = self._priority + 5,
	})

	GoonBase.MenuHelper:AddSlider({
		id = "slider_gs_" .. id,
		title = "Options_" .. id .. "_GS_Title",
		desc = "Options_" .. id .. "_GS_Desc",
		callback = "set_gs_" .. id,
		value = g,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = menu_id,
		priority = self._priority + 4,
	})

	GoonBase.MenuHelper:AddSlider({
		id = "slider_bv_" .. id,
		title = "Options_" .. id .. "_BV_Title",
		desc = "Options_" .. id .. "_BV_Desc",
		callback = "set_bv_" .. id,
		value = b,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = menu_id,
		priority = self._priority + 3,
	})

	GoonBase.MenuHelper:AddToggle({
		id = "toggle_hsv_" .. id,
		title = "Options_ToggleColorHSV_Title",
		desc = "Options_ToggleColorHSV_Message",
		callback = "toggle_hsv_" .. id,
		value = hsv,
		menu_id = menu_id,
		priority = self._priority,
	})

end

-- END OF FILE
