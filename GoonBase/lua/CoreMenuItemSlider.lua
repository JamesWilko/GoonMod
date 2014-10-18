----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

core:import("CoreMenuItemSlider")

CloneClass( CoreMenuItemSlider.ItemSlider )
local ItemSlider = CoreMenuItemSlider.ItemSlider

function ItemSlider.set_value(self, value)
	self._value = math.min(math.max(self._min, value), self._max)
	self:dirty()
end

-- END OF FILE
