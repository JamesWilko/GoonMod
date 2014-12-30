----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( PlayerInventory )

function PlayerInventory.add_unit_by_factory_name(self, factory_name, equip, instant, blueprint, texture_switches)
	self.orig.add_unit_by_factory_name(self, factory_name, equip, instant, blueprint, texture_switches)
end

function PlayerInventory._place_selection(self, selection_index, is_equip)
	self.orig._place_selection(self, selection_index, is_equip)
	self:create_riot_shield(self._unit)
end

function PlayerInventory.create_riot_shield(self, unit)

	local psuccess, perror = pcall(function()

		-- local parent_unit = self._unit:camera()._camera_unit
		-- local align_name = Idstring("a_weapon_right")
		-- local align_obj = parent_unit:get_object( Idstring("a_weapon_right") )

		-- self._shield_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_shield_lights/ene_acc_shield_lights"), align_obj:position(), align_obj:rotation())
		-- self._shield_unit:set_enabled(true)
		-- self._shield_unit:damage():run_sequence_simple("held_body")
		-- parent_unit:link(align_name, self._shield_unit, self._shield_unit:orientation_object():name())

		-- local body = self._unit:body("mover_blocker")
		-- if body then
		-- 	body:set_enabled(false)
		-- else
		-- 	Print("could not find body")
		-- end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end


-- END OF FILE
