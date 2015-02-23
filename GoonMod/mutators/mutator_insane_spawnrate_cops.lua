
local Mutator = class(BaseMutator)
Mutator.Id = "InsaneSpawnRateCops"
Mutator.OptionsName = "Excessive Force - Cops Only"
Mutator.OptionsDesc = "Increases the number of police that spawn"
Mutator.Incompatibilities = { "SuicidalSpawnRate", "SuicidalSpawnRateCops", "InsaneSpawnRate" }

Mutator.HookSpawnGroups = "GroupAITweakDataPostInitEnemySpawnGroups_InsaneSpawnRateCops"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_InsaneSpawnRateCops", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	Hooks:Add("GroupAITweakDataPostInitEnemySpawnGroups", self.HookSpawnGroups, function(data, difficulty_index)
		self:ModifyTweakData(data, difficulty_index)
	end)
end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookSpawnGroups)
end

function Mutator:ModifyTweakData(data, difficulty_index)

	local self = data
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
				freq = 1,
				amount_max = 1,
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
				amount_max = 1,
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
				amount_max = 1,
				tactics = self._tactics.CS_tazer,
				rank = 3
			}
		}
	}

end
