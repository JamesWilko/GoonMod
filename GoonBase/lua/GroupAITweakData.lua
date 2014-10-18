----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
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
