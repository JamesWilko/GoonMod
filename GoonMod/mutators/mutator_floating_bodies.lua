
local Mutator = class(BaseMutator)
Mutator.Id = "FloatingBodies"
Mutator.OptionsName = "All Cops go to Heaven"
Mutator.OptionsDesc = "Enemies will float upwards after death. Will not effect bodies with pagers."
Mutator.AllPlayersRequireMod = true

Mutator._FloatTime = 60
Mutator._ClientStealthFloatTime = 15
Mutator._PostUpdateRagdolled = "CopActionHurtPostUpdateRagdolled_" .. Mutator:ID()

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("CopActionHurtPostUpdateRagdolled", self._PostUpdateRagdolled, function(cop, t)

		if not cop._death_time then
			cop._death_time = t
		end
		local float_time = t - (cop._death_time or t)
		local should_float = float_time < self._FloatTime
		local float_timed_out = float_time > self._FloatTime

		if managers.groupai:state():whisper_mode() then

			if Network:is_server() then
				if should_float and cop._unit:brain().is_pager_started then
					should_float = not cop._unit:brain():is_pager_started()
				end
			else
				should_float = float_time > self._ClientStealthFloatTime
			end

		end

		if should_float then

			if not cop._death_twist then
				cop._death_twist = math.random(2) == 1 and 1 or -1
			end
			
			local dt = TimerManager:game():delta_time()
			local scale = 1.25 * dt
			local unit = cop._unit
			local height = 1
			local twist_dir = cop._death_twist
			local rot_acc = (math.UP * (0.5 * twist_dir)) * -0.5
			local rot_time = 1 + math.rand(2)
			local nr_u_bodies = unit:num_bodies()
			local i_u_body = 0
			while nr_u_bodies > i_u_body do
				local u_body = unit:body(i_u_body)
				if u_body:enabled() and u_body:dynamic() then
					local body_mass = u_body:mass()
					World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, math.UP * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
				end
				i_u_body = i_u_body + 1
			end

		end

		if float_timed_out then
			cop:_freeze_ragdoll()
			cop.update = nil
		end

	end)

end

function Mutator:OnDisabled()
	Hooks:Remove( self._PostUpdateRagdolled )
end
