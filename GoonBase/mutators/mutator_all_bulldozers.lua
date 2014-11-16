----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/16/2014 9:49:42 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "AllBulldozerSpawns"
Mutator.OptionsName = "Bomb Squad"
Mutator.OptionsDesc = "Replace all spawning units with various Bulldozers and backup"
Mutator.Incompatibilities = { "AllCloakerSpawns", "AllTaserSpawns", "AllShieldSpawns" }

Mutator.HookTaskData = "GroupAITweakDataPostInitTaskData_AllBulldozerMutator"
Mutator.HookUnitCategories = "GroupAITweakDataPostInitUnitCategories_AllBulldozerMutator"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_AllBulldozerSpawns", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("GroupAITweakDataPostInitTaskData", self.HookTaskData, function(data, difficulty_index, difficulty)
		self:ModifyTaskData(data, difficulty_index, difficulty)
	end)
	Hooks:Add("GroupAITweakDataPostInitUnitCategories", self.HookUnitCategories, function(data, difficulty_index)
		self:ModifyUnitCategories(data, difficulty_index)
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookTaskData)
	Hooks:Remove(self.HookUnitCategories)
end

function Mutator:ModifyTaskData(data, difficulty_index, difficulty)

	data.besiege.recurring_group_SO = {
		recurring_cloaker_spawn = {
			interval = {15, 20},
			retire_delay = 3000
		},
		recurring_spawn_1 = {
			interval = {3, 6}
		}
	}

	data.besiege.assault.groups = {
		FBI_swats = {
			0.7,
			0.2,
			0.05
		},
		FBI_heavys = {
			0.7,
			0.2,
			0.05
		},
		FBI_shields = {
			0.7,
			0.2,
			0.05
		},
		FBI_tanks = {
			1,
			0.4,
			0.15
		},
		CS_tazers = {
			0.7,
			0.2,
			0.05
		},
		FBI_spoocs = {
			0.7,
			0.2,
			0.05
		},
		single_spooc = {
			0.7,
			0.2,
			0.05
		}
	}

	data.besiege.reenforce.groups = {
		CS_defend_a = {
			0.7,
			0.2,
			0.05
		},
		FBI_defend_b = {
			0.7,
			0.2,
			0.05
		},
		FBI_defend_c = {
			0.7,
			0.2,
			0.05
		},
		FBI_defend_d = {
			0.7,
			0.2,
			0.05
		}
	}

	data.besiege.recon.groups = {
		FBI_stealth_a = {
			0.7,
			0.2,
			0.05
		},
		FBI_stealth_b = {
			0.7,
			0.2,
			0.05
		},
		single_spooc = {
			0.7,
			0.2,
			0.05
		}
	}

end

function Mutator:ModifyUnitCategories(data, difficulty_index)

	local access_type_walk_only = { walk = true }

	data.special_unit_spawn_limits = {
		tank = 1000000,
		taser = 0,
		spooc = 0,
		shield = 0,
	}

	data.unit_categories.FBI_tank.units = {
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
	}
	data.unit_categories.CS_cop_C45_R870 = data.unit_categories.FBI_tank
	data.unit_categories.CS_cop_stealth_MP5 = data.unit_categories.FBI_tank
	data.unit_categories.CS_swat_MP5 = data.unit_categories.FBI_tank
	data.unit_categories.CS_swat_R870 = data.unit_categories.FBI_tank
	data.unit_categories.CS_heavy_M4 = data.unit_categories.FBI_tank
	data.unit_categories.CS_heavy_M4_w = data.unit_categories.FBI_tank
	data.unit_categories.FBI_suit_C45_M4 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_suit_M4_MP5 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_suit_stealth_MP5 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_swat_M4 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_swat_R870 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_heavy_G36 = data.unit_categories.FBI_tank
	data.unit_categories.FBI_heavy_G36_w = data.unit_categories.FBI_tank
	data.unit_categories.CS_tazer = data.unit_categories.spooc
	data.unit_categories.CS_shield = data.unit_categories.spooc
	data.unit_categories.FBI_shield = data.unit_categories.spooc

end

-- END OF FILE
