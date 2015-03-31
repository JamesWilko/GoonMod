
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
