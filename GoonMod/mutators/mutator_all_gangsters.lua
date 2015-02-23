
local Mutator = class(BaseMutator)
Mutator.Id = "AllGangsterSpawns"
Mutator.OptionsName = "Gangsters Only"
Mutator.OptionsDesc = "Replace all spawning units with various gangsters"
Mutator.Incompatibilities = { "AllCloakerSpawns", "AllBulldozerSpawns", "AllShieldSpawns" }

Mutator.HookTaskData = "GroupAITweakDataPostInitTaskData_" .. Mutator.Id
Mutator.HookUnitCategories = "GroupAITweakDataPostInitUnitCategories_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator.Id, function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("GroupAITweakDataPostInitUnitCategories", self.HookUnitCategories, function(data, difficulty_index)
		self:ModifyUnitCategories(data, difficulty_index)
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookUnitCategories)
end

function Mutator:ModifyUnitCategories(data, difficulty_index)

	local gang_mexican = {
		Idstring("units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1"),
		Idstring("units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2"),
		Idstring("units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3"),
		Idstring("units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4"),
	}
	local gang_russian = {
		Idstring("units/payday2/characters/ene_gang_russian_1/ene_gang_russian_1"),
		Idstring("units/payday2/characters/ene_gang_russian_2/ene_gang_russian_2"),
		Idstring("units/payday2/characters/ene_gang_russian_3/ene_gang_russian_3"),
		Idstring("units/payday2/characters/ene_gang_russian_4/ene_gang_russian_4"),
		Idstring("units/payday2/characters/ene_gang_russian_5/ene_gang_russian_5"),
	}
	local gang_mobster = {
		Idstring("units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1"),
		Idstring("units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2"),
		Idstring("units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3"),
		Idstring("units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"),
	}

	data.unit_categories.CS_tazer.units = {
		gang_mexican[math.random(1, #gang_mexican)],
		gang_russian[math.random(1, #gang_russian)],
		gang_russian[math.random(1, #gang_russian)],
		-- gang_mobster[math.random(1, #gang_mobster)],
		-- gang_mobster[math.random(1, #gang_mobster)],
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
