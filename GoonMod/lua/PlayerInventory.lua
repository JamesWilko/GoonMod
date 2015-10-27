
CloneClass( PlayerInventory )

function PlayerInventory.add_unit_by_factory_name(self, factory_name, equip, instant, blueprint, cosmetics, texture_switches)
	self.orig.add_unit_by_factory_name(self, factory_name, equip, instant, blueprint, cosmetics, texture_switches)
end

Hooks:RegisterHook("PlayerInventoryOnPlaceSelection")
function PlayerInventory._place_selection(self, selection_index, is_equip)
	self.orig._place_selection(self, selection_index, is_equip)
	Hooks:Call("PlayerInventoryOnPlaceSelection", self, selection_index, is_equip)
end

Hooks:RegisterHook("PlayerInventoryOnUpdate")
function PlayerInventory.update(self, unit, t, dt)
	Hooks:Call("PlayerInventoryOnUpdate", self, unit, t, dt)
end
