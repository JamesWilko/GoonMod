----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( HUDManager )

function HUDManager._create_teammates_panel(self, hud)
	Print("HUDManager._create_teammates_panel(self, hud)")
	self.orig._create_teammates_panel(self, hud)
end

function HUDManager.remove_teammate_panel_by_name_id(self, name_id)
	Print("HUDManager:remove_teammate_panel_by_name_id(" .. name_id .. ")")
	self.orig.remove_teammate_panel_by_name_id(self, name_id)
end

function HUDManager.remove_teammate_panel(self, id)
	Print("HUDManager:remove_teammate_panel(" .. tostring(id) .. ")")
	self.orig.remove_teammate_panel(self, id)
end

function HUDManager:add_mugshot_by_unit(unit)
	if unit:base().is_local_player then
		return
	end
	local character_name = unit:base():nick_name()
	local name_label_id = managers.hud:_add_name_label({name = character_name, unit = unit})
	unit:unit_data().name_label_id = name_label_id
	local is_husk_player = unit:base().is_husk_player
	local character_name_id = managers.criminals:character_name_by_unit(unit)
	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name_id then
			if is_husk_player and not data.peer_id then
				-- self:_remove_mugshot(data.id)
				break
			else
				unit:unit_data().mugshot_id = data.id
				managers.hud:set_mugshot_normal(unit:unit_data().mugshot_id)
				managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, 1)
				managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, 1)
				return
			end
		end
	end
	local peer, peer_id
	if is_husk_player then
		peer = unit:network():peer()
		peer_id = peer:id()
	end
	local use_lifebar = is_husk_player and true or false
	local mugshot_id = managers.hud:add_mugshot({
		name = utf8.to_upper(character_name),
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})
	unit:unit_data().mugshot_id = mugshot_id
	if peer and peer:is_cheater() then
		self:mark_cheater(peer_id)
	end
	return mugshot_id
end

function HUDManager.add_teammate_panel(self, character_name, player_name, ai, peer_id)

	Print("HUDManager.add_teammate_panel (" .. tostring(character_name) .. " / " .. tostring(player_name) .. ")")

	for i, data in ipairs(self._hud.teammate_panels_data) do
		Print(tostring(i) .. " / taken: " .. tostring(data.taken))
		if not data.taken then

			Print(tostring(i) .. " is not taken yet")

			self._teammate_panels[i]:add_panel()
			self._teammate_panels[i]:set_peer_id(peer_id)
			self._teammate_panels[i]:set_ai(ai)
			self:set_teammate_callsign(i, ai and 5 or peer_id)
			self:set_teammate_name(i, player_name)
			self:set_teammate_state(i, ai and "ai" or "player")

			if peer_id then

				local peer_equipment = managers.player:get_synced_equipment_possession(peer_id) or {}
				for equipment, amount in pairs(peer_equipment) do
					self:add_teammate_special_equipment(i, {
						id = equipment,
						icon = tweak_data.equipments.specials[equipment].icon,
						amount = amount
					})
				end

				local peer_deployable_equipment = managers.player:get_synced_deployable_equipment(peer_id)

				if peer_deployable_equipment then
					local icon = tweak_data.equipments[peer_deployable_equipment.deployable].icon
					self:set_deployable_equipment(i, {
						icon = icon,
						amount = peer_deployable_equipment.amount
					})
				end

				local peer_cable_ties = managers.player:get_synced_cable_ties(peer_id)
				if peer_cable_ties then
					local icon = tweak_data.equipments.specials.cable_tie.icon
					self:set_cable_tie(i, {
						icon = icon,
						amount = peer_cable_ties.amount
					})
				end

				local peer_grenades = managers.player:get_synced_grenades(peer_id)
				if peer_grenades then
					local icon = tweak_data.blackmarket.grenades[peer_grenades.grenade].icon
					self:set_teammate_grenades(i, {
						icon = icon,
						amount = Application:digest_value(peer_grenades.amount, false)
					})
				end

			end

			local unit = managers.player:player_unit(peer_id)
			--local unit = managers.criminals:character_unit_by_name(character_name)
			if alive(unit) then
				local weapon = unit:inventory():equipped_unit()
				if alive(weapon) then
					local icon = weapon:base():weapon_tweak_data().hud_icon
					local equipped_selection = unit:inventory():equipped_selection()
					self:_set_teammate_weapon_selected(i, equipped_selection, icon)
				end
			end

			local peer_ammo_info = managers.player:get_synced_ammo_info(peer_id)
			if peer_ammo_info then
				for selection_index, ammo_info in pairs(peer_ammo_info) do
					self:set_teammate_ammo_amount(i, selection_index, unpack(ammo_info))
				end
			end

			local peer_carry_data = managers.player:get_synced_carry(peer_id)

			if peer_carry_data then
				self:set_teammate_carry_info(i, peer_carry_data.carry_id, managers.loot:get_real_value(peer_carry_data.carry_id, peer_carry_data.multiplier))
			end

			data.taken = true

			Print("id: " .. tostring(i))
			return i

		end
	end

end
-- END OF FILE
