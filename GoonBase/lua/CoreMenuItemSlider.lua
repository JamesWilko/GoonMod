----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/16/2014 9:49:42 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

core:import("CoreMenuItemSlider")

CloneClass( CoreMenuItemSlider.ItemSlider )
local ItemSlider = CoreMenuItemSlider.ItemSlider

function ItemSlider.setup_gui(self, node, row_item)
	local r = self.orig.setup_gui(self, node, row_item)
	row_item.gui_slider_text:set_font_size( tweak_data.menu.stats_font_size )
	return r
end

function ItemSlider.set_value(self, value)
	self._value = math.min(math.max(self._min, value), self._max)
	self:dirty()
end

local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ItemSlider.reload(self, row_item, node)
	local r = self.orig.reload(self, row_item, node)
	local value = self:show_value() and string.format("%.2f", round(self:value(), 2)) or string.format("%.0f", self:percentage()) .. "%"
	row_item.gui_slider_text:set_text(value)
	return r
end

-- END OF FILE
