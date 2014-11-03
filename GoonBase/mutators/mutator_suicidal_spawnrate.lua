----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/3/2014 6:23:30 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "SuicidalSpawnRate"
Mutator.OptionsName = "National Guard Response"
Mutator.OptionsDesc = "Increases the number of police that spawn to an ungodly level"
Mutator.Incompatibilities = { "SuicidalSpawnRateCops", "InsaneSpawnRate", "InsaneSpawnRateCops" }

Mutator.HookSpawnGroups = "GroupAITweakDataPostInitEnemySpawnGroups_" .. Mutator.Id
Mutator.HookSpawnCategories = "GroupAITweakDataPostInitUnitCategories_" .. Mutator.Id
Mutator.HookEnemyData = "EnemyManagerInitEnemyData_" .. Mutator.Id
Mutator.HookGroupAIState = "GroupAIStateBesiegeInit_" .. Mutator.Id
Mutator.CopDamageMover = "CopDamageSetMoverCollisionState_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_SuicidalSpawnRate", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("GroupAITweakDataPostInitUnitCategories", self.HookSpawnCategories, function(data, difficulty_index)
		self:ModifyUnitCategories(data, difficulty_index)
	end)
	Hooks:Add("GroupAITweakDataPostInitEnemySpawnGroups", self.HookSpawnGroups, function(data, difficulty_index)
		self:ModifyTweakData(data, difficulty_index)
	end)
	Hooks:Add("EnemyManagerInitEnemyData", self.HookEnemyData, function(enemy_manager)
		enemy_manager._enemy_data.max_nr_active_units = 2000
	end)
	Hooks:Add("GroupAIStateBesiegeInit", self.HookGroupAIState, function(ai_state)
		GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS = 3000
	end)
	Hooks:Add("CopDamageSetMoverCollisionState", self.CopDamageMover, function(cop_damage, state)
		return false
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookSpawnCategories)
	Hooks:Remove(self.HookSpawnGroups)
	Hooks:Remove(self.HookEnemyData)
	Hooks:Remove(self.HookGroupAIState)
	Hooks:Remove(self.CopDamageMover)
end

function Mutator:ModifyUnitCategories(data, difficulty_index)

	data.special_unit_spawn_limits = {
		tank = 100000,
		taser = 100000,
		spooc = 100000,
		shield = 100000,
	}

	data.unit_categories.FBI_shield.special_type = nil
	data.unit_categories.FBI_tank.special_type = nil
	data.unit_categories.CS_tazer.special_type = nil
	data.unit_categories.CS_shield.special_type = nil

end

function Mutator:ModifyTweakData(data, difficulty_index)

	local self = data
	self.enemy_spawn_groups = {}
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

	self.enemy_spawn_groups.CS_shields = {
		amount = {50, 60},
		spawn = {
			{
				unit = "CS_shield",
				freq = 15,
				amount_min = 18,
				amount_max = 30,
				tactics = self._tactics.CS_shield,
				rank = 3
			},
			{
				unit = "CS_cop_stealth_MP5",
				freq = 4.5,
				amount_max = 9,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			},
			{
				unit = "CS_heavy_M4_w",
				freq = 7.5,
				amount_max = 12,
				tactics = self._tactics.CS_swat_heavy,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.CS_tazers = {
		amount = {20, 25},
		spawn = {
			{
				unit = "CS_tazer",
				freq = 15,
				amount_min = 18,
				amount_max = 15,
				tactics = self._tactics.CS_tazer,
				rank = 2
			},
			{
				unit = "CS_swat_MP5",
				freq = 15,
				amount_max = 18,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_tanks = {
		amount = {5, 8},
		spawn = {
			{
				unit = "FBI_tank",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_tank,
				rank = 2
			},
			{
				unit = "CS_tazer",
				freq = 1.5,
				amount_max = 3,
				tactics = self._tactics.CS_tazer,
				rank = 1
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
				freq = 15,
				amount_max = 30,
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
				freq = 1,
				amount_max = 9,
				tactics = self._tactics.CS_tazer,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.FBI_shields = {
		amount = {40, 50},
		spawn = {
			{
				unit = "FBI_shield",
				freq = 15,
				amount_min = 30,
				amount_max = 50,
				tactics = self._tactics.FBI_shield_flank,
				rank = 3
			},
			{
				unit = "CS_tazer",
				freq = 2.5,
				amount_max = 6,
				tactics = self._tactics.CS_tazer,
				rank = 2
			},
			{
				unit = "FBI_heavy_G36",
				freq = 4.5,
				amount_max = 9,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_tanks = {
		amount = {12, 15},
		spawn = {
			{
				unit = "FBI_tank",
				freq = 2,
				amount_max = 20,
				tactics = self._tactics.FBI_tank,
				rank = 1
			},
			{
				unit = "FBI_shield",
				freq = 2,
				amount_min = 20,
				amount_max = 50,
				tactics = self._tactics.FBI_shield_flank,
				rank = 3
			},
			{
				unit = "FBI_heavy_G36_w",
				freq = 2.5,
				amount_min = 8,
				tactics = self._tactics.FBI_heavy_flank,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.single_spooc = {
		amount = {8, 20},
		spawn = {
			{
				unit = "spooc",
				freq = 2,
				amount_min = 2,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_spoocs = self.enemy_spawn_groups.single_spooc

	self.besiege.assault.force = {
		200,
		300,
		400
	}

	self.besiege.assault.force_pool = {
		400,
		800,
		1500
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

	self.besiege.assault.hostage_hesitation_delay = {
		0,
		0,
		0
	}

	self.besiege.assault.delay = {
		20,
		15,
		10
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

-- END OF FILE
