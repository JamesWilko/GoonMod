----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "AllSpecialSpawns"
Mutator.OptionsName = "Special Party!"
Mutator.OptionsDesc = "Replace all spawning units with Specials"
Mutator.Incompatibilities = { "AllCloakerSpawns", "AllBulldozerSpawns", "AllShieldSpawns", "AllTaserSpawns" }

Mutator.HookTaskData = "GroupAITweakDataPostInitTaskData_AllSpecialsMutator"
Mutator.HookUnitCategories = "GroupAITweakDataPostInitUnitCategories_AllSpecialsMutator"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_AllSpecialsSpawns", function()
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
			interval = {0, 1},
			retire_delay = 30
		},
		recurring_spawn_1 = {
			interval = {0, 1}
		}
	}

	data.besiege.assault.groups = {
		FBI_swats = {
			1,
			1,
			1
		},
		FBI_heavys = {
			1,
			1,
			1
		},
		FBI_shields = {
			1,
			1,
			1
		},
		FBI_tanks = {
			1,
			1,
			1
		},
		CS_tazers = {
			1,
			1,
			1
		},
		FBI_spoocs = {
			1,
			1,
			1
		},
		single_spooc = {
			1,
			1,
			1
		}
	}

	data.besiege.reenforce.groups = {
		CS_defend_a = {
			1,
			1,
			1
		},
		FBI_defend_b = {
			1,
			1,
			1
		},
		FBI_defend_c = {
			1,
			1,
			1
		},
		FBI_defend_d = {
			1,
			1,
			1
		}
	}

	data.besiege.recon.groups = {
		FBI_stealth_a = {
			1,
			1,
			1
		},
		FBI_stealth_b = {
			1,
			1,
			1
		},
		single_spooc = {
			1,
			1,
			1
		}
	}

end

function Mutator:ModifyUnitCategories(data, difficulty_index)

	local access_type_all = { walk = true, acrobatic = true }

	data.special_unit_spawn_limits = {
		tank = 1000,
		taser = 1000,
		spooc = 1000,
		shield = 1000,
	}

	data.unit_categories.CS_tazer.units = {
		Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
		Idstring("units/payday2/characters/ene_spook_1/ene_spook_1"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
	}
	data.unit_categories.CS_cop_C45_R870 = data.unit_categories.CS_tazer
	data.unit_categories.CS_cop_stealth_MP5 = data.unit_categories.CS_tazer
	data.unit_categories.CS_swat_MP5 = data.unit_categories.CS_tazer
	data.unit_categories.CS_swat_R870 = data.unit_categories.CS_tazer
	data.unit_categories.CS_heavy_M4 = data.unit_categories.CS_tazer
	data.unit_categories.CS_heavy_M4_w = data.unit_categories.CS_tazer
	data.unit_categories.CS_shield = data.unit_categories.CS_tazer
	data.unit_categories.FBI_suit_C45_M4 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_suit_M4_MP5 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_suit_stealth_MP5 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_swat_M4 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_swat_R870 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_heavy_G36 = data.unit_categories.CS_tazer
	data.unit_categories.FBI_heavy_G36_w = data.unit_categories.CS_tazer
	data.unit_categories.FBI_shield = data.unit_categories.CS_tazer
	data.unit_categories.FBI_tank = data.unit_categories.CS_tazer

end
-- END OF FILE
