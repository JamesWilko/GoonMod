
local Mutator = class(BaseMutator)
Mutator.Id = "MethAddiction"
Mutator.OptionsName = "Addicts"
Mutator.OptionsDesc = "Players constantly lose health unless they are carrying the bag of drugs"
Mutator.AllPlayersRequireMod = true

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator._player_lookup = {}
Mutator._player_id_lookup = {}
Mutator._drugs = {
	["coke"] = true,
	["meth"] = true,
	["coke_pure"] = true,
	["sandwich"] = true,
}
Mutator._drug_spawns = {
	"coke",
	"meth",
	"coke_pure",
}
Mutator._addiction_restore = 0.0425
Mutator._addiction_damage = -0.1250

Mutator._gameUpdateHook = "GameSetupUpdate_" .. Mutator:ID()
Mutator._playerDamageOnPostInitHook = "PlayerDamageOnPostInit_" .. Mutator:ID()

function Mutator:IsDrugsBag( carry_data )
	if not carry_data then
		return false
	end
	return self._drugs[carry_data.carry_id]
end

function Mutator:ApplyAddictionDamage( unit, carrying_drugs, delta )

	if unit and unit:character_damage() and unit:character_damage().change_health then
		if carrying_drugs then
			unit:character_damage():change_health( self._addiction_restore * delta )
		else
			unit:character_damage():change_health( self._addiction_damage * delta )
		end
	end

end

function Mutator:OnEnabled()
	
	Hooks:Add("GameSetupUpdate", self._gameUpdateHook, function(t, dt)
		
		local ply_manager = managers.player
		if ply_manager then

			local carry_data = ply_manager:get_my_carry_data()
			local carrying = carry_data and self:IsDrugsBag(carry_data)
			self:ApplyAddictionDamage( ply_manager:player_unit(), carrying, dt )

		end

	end)

	Hooks:Add("PlayerDamageOnPostInit", self._playerDamageOnPostInitHook, function(ply, unit)

		DelayedCalls:Add("AddictsSpawnFreeDrugs", 1, function()
			local loot = self._drug_spawns[math.random(1, #self._drug_spawns)]
			managers.player:force_verify_carry()
			self:SpawnMutatorLoot( loot )
		end)
		
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove( self._gameUpdateHook )
	Hooks:Remove( self._playerDamageOnPostInitHook )
end

function Mutator:SpawnMutatorLoot(loot_id, zipline_unit)

	local carry_data = tweak_data.carry[loot_id]
	if not carry_data then
		return
	end

	local player = managers.player:player_unit()
	if player then
		player:sound():play("Play_bag_generic_throw", nil, false)
	else
		return
	end

	local camera_ext = player:camera()
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local throw_distance_multiplier_upgrade_level = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)

	local pos = camera_ext:position()
	local rot = camera_ext:rotation()
	local peer_id = managers.network:session():local_peer() or 0

	if not Network:is_client() then
		managers.player:server_drop_carry(loot_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, pos, rot, player:camera():forward(), throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer():id())
	end

end

