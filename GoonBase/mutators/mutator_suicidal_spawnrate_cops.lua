----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/19/2014 9:35:49 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "SuicidalSpawnRateCops"
Mutator.OptionsName = "National Guard Response - Cops Only"
Mutator.OptionsDesc = "Increases the number of regular police units that spawn to an ungodly level"
Mutator.Incompatibilities = { "SuicidalSpawnRate", "InsaneSpawnRate", "InsaneSpawnRateCops" }

Mutator.HookSpawnGroups = "GroupAITweakDataPostInitEnemySpawnGroups_SuicidalSpawnRateCops"
Mutator.HookSpawnCategories = "GroupAITweakDataPostInitUnitCategories_SuicidalSpawnRateCops"
Mutator.HookEnemyData = "EnemyManagerInitEnemyData_SuicidalSpawnRateCops"
Mutator.HookGroupAIState = "GroupAIStateBesiegeInit_SuicidalSpawnRateCops"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_SuicidalSpawnRateCops", function()
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
		amount = {50, 60},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 15,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_b = {
		amount = {50, 60},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 15,
				amount_min = 18,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_c = {
		amount = {50, 65},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 15,
				amount_min = 18,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_cops = {
		amount = {50, 60},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 15,
				amount_min = 18,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_stealth_a = {
		amount = {50, 60},
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
		amount = {50, 60},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 15,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_swat_R870",
				freq = 4.5,
				amount_max = 30,
				tactics = self._tactics.CS_swat_shotgun,
				rank = 1
			},
			{
				unit = "CS_swat_MP5",
				freq = 15,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.CS_heavys = {
		amount = {50, 60},
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
		amount = {40, 40},
		spawn = {
			{
				unit = "FBI_suit_C45_M4",
				freq = 15,
				amount_min = 30,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "CS_cop_C45_R870",
				freq = 15,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_b = {
		amount = {50, 50},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 15,
				amount_min = 30,
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
		amount = {50, 50},
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
		amount = {30, 40},
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
		amount = {30, 40},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 15,
				amount_min = 30,
				tactics = self._tactics.FBI_suit_stealth,
				rank = 1
			},
			{
				unit = "CS_tazer",
				freq = 1,
				amount_max = 2,
				tactics = self._tactics.CS_tazer,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.FBI_stealth_b = {
		amount = {40, 50},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 15,
				amount_min = 30,
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
		amount = {40, 50},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 15,
				amount_min = 30,
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
				amount_max = 30,
				tactics = self._tactics.FBI_swat_shotgun,
				rank = 1
			},
			{
				unit = "spooc",
				freq = 0.15,
				amount_max = 3,
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
				freq = 1,
				amount_max = 2,
				tactics = self._tactics.CS_tazer,
				rank = 3
			}
		}
	}

	self.besiege.assault.force = {
		50,
		80,
		100
	}

	self.besiege.assault.force_pool = {
		200,
		400,
		800
	}

	self.besiege.reenforce.interval = {
		1,
		2,
		3
	}

	self.besiege.assault.force_balance_mul = {
		24,
		32,
		48,
		64
	}
	self.besiege.assault.force_pool_balance_mul = {
		12,
		18,
		24,
		32
	}

	self._tactics.CS_cop = {
		"ranged_fire"
	}
	self._tactics.CS_cop_stealth = {
		"flank",
	}
	self._tactics.CS_swat_rifle = {
		"smoke_grenade",
		"charge",
		"ranged_fire",
		"deathguard"
	}
	self._tactics.CS_swat_shotgun = {
		"charge",
	}
	self._tactics.CS_swat_heavy = {
		"charge",
	}
	self._tactics.CS_swat_rifle_flank = {
		"flank",
		"charge",
	}
	self._tactics.CS_swat_shotgun_flank = {
		"flank",
		"charge",
	}
	self._tactics.CS_swat_heavy_flank = {
		"flank",
		"charge",
	}
	self._tactics.FBI_suit = {
		"flank",
		"ranged_fire",
	}
	self._tactics.FBI_suit_stealth = {
		"flank"
	}
	self._tactics.FBI_swat_rifle = {
		"charge",
	}
	self._tactics.FBI_swat_shotgun = {
		"charge",
	}
	self._tactics.FBI_swat_rifle_flank = {
		"flank",
		"charge",
	}
	self._tactics.FBI_swat_shotgun_flank = {
		"flank",
		"charge",
	}
	self._tactics.FBI_heavy_flank = {
		"flank",
		"charge",
	}

end

-- END OF FILE
