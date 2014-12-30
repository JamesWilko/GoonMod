----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GroupAITweakData )

Hooks:RegisterHook( "GroupAITweakDataPostInitTaskData" )
function GroupAITweakData._init_task_data(self, difficulty_index, difficulty)
	self.orig._init_task_data(self, difficulty_index, difficulty)
	Hooks:Call( "GroupAITweakDataPostInitTaskData", self, difficulty_index, difficulty )
end

Hooks:RegisterHook( "GroupAITweakDataPostInitUnitCategories" )
function GroupAITweakData._init_unit_categories(self, difficulty_index)
	self.orig._init_unit_categories(self, difficulty_index)
	Hooks:Call( "GroupAITweakDataPostInitUnitCategories", self, difficulty_index )
end

Hooks:RegisterHook( "GroupAITweakDataPostInitEnemySpawnGroups" )
function GroupAITweakData._init_enemy_spawn_groups(self, difficulty_index)
	self.orig._init_enemy_spawn_groups(self, difficulty_index)
	Hooks:Call( "GroupAITweakDataPostInitEnemySpawnGroups", self, difficulty_index )
end
-- END OF FILE
