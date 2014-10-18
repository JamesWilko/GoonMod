----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CopInventory )

Hooks:RegisterHook("CopInventoryDropShield")
function CopInventory.drop_shield(self)

	if alive(self._shield_unit) then
		self._shield_unit:unlink()
		if self._shield_unit:damage() then
			self._shield_unit:damage():run_sequence_simple("enable_body")
		end
	end

	Hooks:Call("CopInventoryDropShield", self)

end

Hooks:RegisterHook("CopInventoryDestroyAllItems")
function CopInventory.destroy_all_items(self)
		
	CopInventory.super.destroy_all_items(self)
	if alive(self._shield_unit) then
		self._shield_unit:set_slot(0)
		self._shield_unit = nil
	end

	Hooks:Call("CopInventoryDestroyAllItems", self)

end

Hooks:RegisterHook("CopInventoryCheckSpawnShield")
function CopInventory._chk_spawn_shield(self, weapon_unit)

	-- self.orig._chk_spawn_shield(self, weapon_unit)
	Hooks:Call("CopInventoryCheckSpawnShield", self, weapon_unit)

	if self._shield_unit_name and not alive(self._shield_unit) then
		local align_name = self._shield_attach_point or Idstring("a_weapon_left_front")
		local align_obj = self._unit:get_object(align_name)
		self._shield_unit = World:spawn_unit(Idstring(self._shield_unit_name), align_obj:position(), align_obj:rotation())
		self._unit:link(align_name, self._shield_unit, self._shield_unit:orientation_object():name())
		self._shield_unit:set_enabled(false)
	end
	
end

Hooks:RegisterHook("CopInventoryUpdate")
function CopInventory.update(self, unit, t, dt)
	Hooks:Call("CopInventoryUpdate", self, unit, t, dt)
end

-- END OF FILE
