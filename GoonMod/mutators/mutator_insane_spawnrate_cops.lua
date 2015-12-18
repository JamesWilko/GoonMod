
local Mutator = class(BaseMutator)
Mutator.Id = "InsaneSpawnRateCops"
Mutator.OptionsName = "Excessive Force - Cops Only"
Mutator.OptionsDesc = "Increases the number of police that spawn"
Mutator.Incompatibilities = { "SuicidalSpawnRate", "SuicidalSpawnRateCops", "InsaneSpawnRate" }

Mutator.HookSpawnGroups = "GroupAITweakDataPostInitEnemySpawnGroups_InsaneSpawnRateCops"
Mutator.HookEnemyData = "EnemyManagerInitEnemyData_" .. Mutator.Id
Mutator.HookGroupAIState = "GroupAIStateBesiegeInit_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_InsaneSpawnRateCops", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("GroupAITweakDataPostInitEnemySpawnGroups", self.HookSpawnGroups, function(data, difficulty_index)
		self:ModifyTweakData(data, difficulty_index)
	end)

	Hooks:Add("EnemyManagerInitEnemyData", self.HookEnemyData, function(enemy_manager)
		enemy_manager._enemy_data.max_nr_active_units = 2000
	end)

	Hooks:Add("GroupAIStateBesiegeInit", self.HookGroupAIState, function(ai_state)

		GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS = 3000
		
		-- Load spawn adjustment hooks
		SafeDoFile(GoonBase.Mutators.MutatorsPath .. "mutator_spawn_adjustments.lua")

	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookSpawnGroups)
	Hooks:Remove(self.HookEnemyData)
	Hooks:Remove(self.HookGroupAIState)
end

function Mutator:ModifyTweakData(data, difficulty_index)

	local self = data

	self.enemy_spawn_groups.CS_defend_a = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 10,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_b = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 10,
				amount_min = 8,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_c = {
		amount = {10, 15},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 10,
				amount_min = 18,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_cops = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 5,
				amount_min = 8,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_stealth_a = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_cop_stealth_MP5",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_swats = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 10,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_swat_R870",
				freq = 4.5,
				amount_max = 10,
				tactics = self._tactics.CS_swat_shotgun,
				rank = 1
			},
			{
				unit = "CS_swat_MP5",
				freq = 10,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.CS_heavys = {
		amount = {10, 20},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 15,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_heavy_M4",
				freq = 3.5,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_a = {
		amount = {20, 30},
		spawn = {
			{
				unit = "FBI_suit_C45_M4",
				freq = 10,
				amount_min = 10,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "CS_cop_C45_R870",
				freq = 10,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_b = {
		amount = {20, 25},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 15,
				amount_min = 10,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "FBI_swat_M4",
				freq = 15,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_c = {
		amount = {20, 25},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 20,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_d = {
		amount = {10, 20},
		spawn = {
			{
				unit = "FBI_heavy_G36",
				freq = 20,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_stealth_a = {
		amount = {10, 20},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 15,
				tactics = self._tactics.FBI_suit_stealth,
				rank = 1
			},
			{
				unit = "CS_tazer",
				freq = 15,
				tactics = self._tactics.CS_tazer,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.FBI_stealth_b = {
		amount = {10, 30},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 15,
				tactics = self._tactics.FBI_suit_stealth,
				rank = 1
			},
			{
				unit = "FBI_suit_M4_MP5",
				freq = 7.5,
				tactics = self._tactics.FBI_suit,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.FBI_swats = {
		amount = {15, 25},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 15,
				tactics = self._tactics.FBI_swat_rifle,
				rank = 2
			},
			{
				unit = "FBI_swat_M4",
				freq = 7.5,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 3
			},
			{
				unit = "FBI_swat_R870",
				freq = 4.5,
				tactics = self._tactics.FBI_swat_shotgun,
				rank = 1
			},
			{
				unit = "spooc",
				freq = 1,
				amount_max = 8,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_heavys = {
		amount = {9, 12},
		spawn = {
			{
				unit = "FBI_heavy_G36",
				freq = 15,
				tactics = self._tactics.FBI_swat_rifle,
				rank = 1
			},
			{
				unit = "FBI_heavy_G36",
				freq = 7.5,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 2
			},
			{
				unit = "CS_tazer",
				freq = 2,
				amount_max = 9,
				tactics = self._tactics.CS_tazer,
				rank = 3
			}
		}
	}

	self.besiege.assault.force = {
		200,
		300,
		400
	}

	self.besiege.assault.force_pool = {
		300,
		600,
		1000
	}

	self.besiege.reenforce.interval = {
		4,
		3,
		2,
		1
	}

	self.besiege.assault.force_balance_mul = {
		20,
		24,
		28,
		32
	}
	self.besiege.assault.force_pool_balance_mul = {
		12,
		18,
		24,
		32
	}

	self.besiege.assault.delay = {
		15,
		10,
		5
	}

	self.besiege.assault.sustain_duration_min = {
		120,
		160,
		240
	}

	self.besiege.assault.sustain_duration_max = {
		240,
		320,
		480
	}

	self.besiege.assault.sustain_duration_balance_mul = {
		1.3,
		1.5,
		1.7,
		1.9
	}

end
