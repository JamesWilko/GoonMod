----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "InsaneSpawnRate"
Mutator.OptionsName = "Excessive Force"
Mutator.OptionsDesc = "Increases the number of police that spawn"
Mutator.Incompatibilities = { "SuicidalSpawnRate" }

Mutator.HookSpawnGroups = "GroupAITweakDataPostInitEnemySpawnGroups_InsaneSpawnRate"
Mutator.HookSpawnCategories = "GroupAITweakDataPostInitUnitCategories_InsaneSpawnRate"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_InsaneSpawnRate", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("GroupAITweakDataPostInitUnitCategories", self.HookSpawnCategories, function(data, difficulty_index)
		self:ModifyUnitCategories(data, difficulty_index)
	end)
	Hooks:Add("GroupAITweakDataPostInitEnemySpawnGroups", self.HookSpawnGroups, function(data, difficulty_index)
		self:ModifyTweakData(data, difficulty_index)
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookSpawnCategories)
	Hooks:Remove(self.HookSpawnGroups)
end

function Mutator:ModifyUnitCategories(data, difficulty_index)

	data.special_unit_spawn_limits = {
		tank = 6,
		taser = 18,
		spooc = 12,
		shield = 64,
	}

end

function Mutator:ModifyTweakData(data, difficulty_index)

	local self = data
	self.enemy_spawn_groups = {}
	self.enemy_spawn_groups.CS_defend_a = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 3,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_b = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_defend_c = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_cops = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_cop_C45_R870",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.CS_cop,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_stealth_a = {
		amount = {6, 9},
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
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_swat_MP5",
				freq = 3,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_swat_R870",
				freq = 1.5,
				amount_max = 6,
				tactics = self._tactics.CS_swat_shotgun,
				rank = 1
			},
			{
				unit = "CS_swat_MP5",
				freq = 1,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.CS_heavys = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_heavy_M4",
				freq = 3,
				tactics = self._tactics.CS_swat_rifle,
				rank = 2
			},
			{
				unit = "CS_heavy_M4",
				freq = 1.15,
				tactics = self._tactics.CS_swat_rifle_flank,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.CS_shields = {
		amount = {9, 12},
		spawn = {
			{
				unit = "CS_shield",
				freq = 3,
				amount_min = 3,
				amount_max = 6,
				tactics = self._tactics.CS_shield,
				rank = 3
			},
			{
				unit = "CS_cop_stealth_MP5",
				freq = 1.5,
				amount_max = 3,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			},
			{
				unit = "CS_heavy_M4_w",
				freq = 2.5,
				amount_max = 3,
				tactics = self._tactics.CS_swat_heavy,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.CS_tazers = {
		amount = {3, 9},
		spawn = {
			{
				unit = "CS_tazer",
				freq = 3,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.CS_tazer,
				rank = 2
			},
			{
				unit = "CS_swat_MP5",
				freq = 3,
				amount_max = 6,
				tactics = self._tactics.CS_cop_stealth,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.CS_tanks = {
		amount = {3, 6},
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
		amount = {9, 9},
		spawn = {
			{
				unit = "FBI_suit_C45_M4",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "CS_cop_C45_R870",
				freq = 3,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_b = {
		amount = {9, 9},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_suit,
				rank = 2
			},
			{
				unit = "FBI_swat_M4",
				freq = 3,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_c = {
		amount = {9, 9},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 3,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_defend_d = {
		amount = {6, 9},
		spawn = {
			{
				unit = "FBI_heavy_G36",
				freq = 3,
				tactics = self._tactics.FBI_suit,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_stealth_a = {
		amount = {6, 9},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_suit_stealth,
				rank = 1
			},
			{
				unit = "CS_tazer",
				freq = 3,
				amount_max = 6,
				tactics = self._tactics.CS_tazer,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.FBI_stealth_b = {
		amount = {6, 9},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_suit_stealth,
				rank = 1
			},
			{
				unit = "FBI_suit_M4_MP5",
				freq = 2.5,
				tactics = self._tactics.FBI_suit,
				rank = 2
			}
		}
	}

	self.enemy_spawn_groups.FBI_swats = {
		amount = {9, 12},
		spawn = {
			{
				unit = "FBI_swat_M4",
				freq = 3,
				amount_min = 3,
				tactics = self._tactics.FBI_swat_rifle,
				rank = 2
			},
			{
				unit = "FBI_swat_M4",
				freq = 2.5,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 3
			},
			{
				unit = "FBI_swat_R870",
				freq = 1.5,
				amount_max = 6,
				tactics = self._tactics.FBI_swat_shotgun,
				rank = 1
			},
			{
				unit = "spooc",
				freq = 0.15,
				amount_max = 6,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_heavys = {
		amount = {3, 6},
		spawn = {
			{
				unit = "FBI_heavy_G36",
				freq = 3,
				tactics = self._tactics.FBI_swat_rifle,
				rank = 1
			},
			{
				unit = "FBI_heavy_G36",
				freq = 2.5,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 2
			},
			{
				unit = "CS_tazer",
				freq = 0.75,
				amount_max = 3,
				tactics = self._tactics.CS_tazer,
				rank = 3
			}
		}
	}

	self.enemy_spawn_groups.FBI_shields = {
		amount = {9, 12},
		spawn = {
			{
				unit = "FBI_shield",
				freq = 3,
				amount_min = 3,
				amount_max = 6,
				tactics = self._tactics.FBI_shield_flank,
				rank = 3
			},
			{
				unit = "CS_tazer",
				freq = 2.5,
				amount_max = 3,
				tactics = self._tactics.CS_tazer,
				rank = 2
			},
			{
				unit = "FBI_heavy_G36",
				freq = 1.5,
				amount_max = 3,
				tactics = self._tactics.FBI_swat_rifle_flank,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.FBI_tanks = {
		amount = {6, 8},
		spawn = {
			{
				unit = "FBI_tank",
				freq = 2,
				amount_max = 3,
				tactics = self._tactics.FBI_tank,
				rank = 1
			},
			{
				unit = "FBI_shield",
				freq = 2,
				amount_min = 3,
				amount_max = 6,
				tactics = self._tactics.FBI_shield_flank,
				rank = 3
			},
			{
				unit = "FBI_heavy_G36_w",
				freq = 2.5,
				amount_min = 3,
				tactics = self._tactics.FBI_heavy_flank,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.single_spooc = {
		amount = {2, 2},
		spawn = {
			{
				unit = "spooc",
				freq = 2,
				amount_min = 3,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.FBI_spoocs = self.enemy_spawn_groups.single_spooc

end

-- END OF FILE
