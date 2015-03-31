
local Mutator = class(BaseMutator)
Mutator.Id = "SuicideCloakers"
Mutator.OptionsName = "Suicide Cloakers"
Mutator.OptionsDesc = "Cloakers explode on impact"
Mutator.AllPlayersRequireMod = true

Mutator._ActionSpooc = "ActionSpoocPostInitialize_" .. Mutator:ID()

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("ActionSpoocAnimActCallback", "asdasd", function(spooc, anim_act)
		if anim_act == "strike" then
			Mutator:Detonate(spooc)
		end
	end)

end

function Mutator:Detonate(spooc)

	local pos = spooc._unit:position()
	local range = 1000
	local damage = 1000
	local explosion_params = {
		effect = "effects/payday2/particles/explosions/grenade_explosion",
		sound_event = "grenade_explode",
		feedback_range = range * 2,
		camera_shake_max_mul = 4,
		sound_muffle_effect = true
	}

	managers.explosion:detect_and_give_dmg({
		hit_pos = pos,
		range = range,
		collision_slotmask = managers.slot:get_mask("explosion_targets"),
		curve_pow = tweak_data.upgrades.explosive_bullet.curve_pow,
		damage = damage,
		player_damage = damage,
		ignore_unit = nil,
		user = nil
	})
	managers.explosion:play_sound_and_effects(pos, math.UP, range, explosion_params)

	if LuaNetworking:IsMultiplayer() and LuaNetworking:IsHost() then
		
		local grenade_type = "launcher_frag"
		local unit_name = Idstring(tweak_data.blackmarket.grenades[grenade_type].unit)
		local unit = World:spawn_unit(unit_name, pos, Rotation(math.random(0, 360), math.UP))
		unit:base():_detonate()

	end

end

function Mutator:OnDisabled()
	Hooks:Remove(self._CopDamageInit)
end
