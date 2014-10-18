----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

core:import("CoreMenuItem")

CloneClass( CoreMenuItem.Item )
local Item = CoreMenuItem.Item

function Item.trigger(self)
	self.orig.trigger(self)
end

function Item.dirty(self)

	if self._parameters.type ~= "CoreMenuItemSlider.ItemSlider" or self._type ~= "slider" then
		if self.dirty_callback then
			self.dirty_callback(self)
		end
	end

end

-- END OF FILE
