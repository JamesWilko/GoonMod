----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "AllLightningSpeed"
Mutator.OptionsName = "Blitzkrieg"
Mutator.OptionsDesc = "All police units move lightning fast"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_AllLightningSpeed", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.Units = {}
Mutator.Units.Cop = "CharacterTweakDataPostInitCop_" .. Mutator:ID()
Mutator.Units.FBI = "CharacterTweakDataPostInitFBI_" .. Mutator:ID()
Mutator.Units.SWAT = "CharacterTweakDataPostInitSWAT_" .. Mutator:ID()
Mutator.Units.HeavySWAT = "CharacterTweakDataPostInitHeavySWAT_" .. Mutator:ID()
Mutator.Units.FBISWAT = "CharacterTweakDataPostInitFBISWAT_" .. Mutator:ID()
Mutator.Units.FBIHeavySWAT = "CharacterTweakDataPostInitFBIHeavySWAT_" .. Mutator:ID()
Mutator.Units.CitySWAT = "CharacterTweakDataPostInitCitySWAT_" .. Mutator:ID()
Mutator.Units.Shield = "CharacterTweakDataPostInitShield_" .. Mutator:ID()
Mutator.Units.Taser = "CharacterTweakDataPostInitTaser_" .. Mutator:ID()
Mutator.Units.Tank = "CharacterTweakDataPostInitTank_" .. Mutator:ID()
Mutator.Units.GeneralSpeed = "CharacterTweakDataPostMultiplyAllSpeeds_" .. Mutator:ID()
Mutator.Units.SpawnCategories = "GroupAITweakDataPostInitUnitCategories_" .. Mutator:ID()

function Mutator:OnEnabled()
	
	Hooks:Add("CharacterTweakDataPostInitCop", self.Units.Cop, function(data, presets)
		data.cop.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitFBI", self.Units.FBI, function(data, presets)
		data.fbi.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitSWAT", self.Units.SWAT, function(data, presets)
		data.swat.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitHeavySWAT", self.Units.HeavySWAT, function(data, presets)
		data.heavy_swat.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitFBISWAT", self.Units.FBISWAT, function(data, presets)
		data.fbi_swat.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitFBIHeavySWAT", self.Units.FBIHeavySWAT, function(data, presets)
		data.fbi_heavy_swat.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitCitySWAT", self.Units.CitySWAT, function(data, presets)
		data.city_swat.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitShield", self.Units.Shield, function(data, presets)
		data.shield.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitTaser", self.Units.Taser, function(data, presets)
		data.taser.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostInitTank", self.Units.Tank, function(data, presets)
		data.tank.move_speed = presets.move_speed.lightning
	end)

	Hooks:Add("CharacterTweakDataPostMultiplyAllSpeeds", self.Units.GeneralSpeed, function(data, walk_mul, run_mul)

		walk_mul = 3
		run_mul = 5

		local self = data
		local all_units = {
			"security",
			"cop",
			"fbi",
			"swat",
			"heavy_swat",
			"sniper",
			"gangster",
			"tank",
			"spooc",
			"shield",
			"taser"
		}
		for _, name in ipairs(all_units) do
			local speed_table = self[name].SPEED_WALK
			speed_table.hos = speed_table.hos * walk_mul
			speed_table.cbt = speed_table.cbt * walk_mul
		end
		self.security.SPEED_RUN = self.security.SPEED_RUN * run_mul
		self.cop.SPEED_RUN = self.cop.SPEED_RUN * run_mul
		self.fbi.SPEED_RUN = self.fbi.SPEED_RUN * run_mul
		self.swat.SPEED_RUN = self.swat.SPEED_RUN * run_mul
		self.heavy_swat.SPEED_RUN = self.heavy_swat.SPEED_RUN * run_mul
		self.fbi_heavy_swat.SPEED_RUN = self.fbi_heavy_swat.SPEED_RUN * run_mul
		self.sniper.SPEED_RUN = self.sniper.SPEED_RUN * run_mul
		self.gangster.SPEED_RUN = self.gangster.SPEED_RUN * run_mul
		self.tank.SPEED_RUN = self.tank.SPEED_RUN * run_mul
		self.spooc.SPEED_RUN = self.spooc.SPEED_RUN * run_mul
		self.shield.SPEED_RUN = self.shield.SPEED_RUN * run_mul
		self.taser.SPEED_RUN = self.taser.SPEED_RUN * run_mul
		self.biker_escape.SPEED_RUN = self.biker_escape.SPEED_RUN * run_mul

	end)

	Hooks:Add("GroupAITweakDataPostInitUnitCategories", self.Units.SpawnCategories, function(data, difficulty_index)
		local access_type_all = {walk = true, acrobatic = true}
		data.unit_categories.FBI_shield.access = access_type_all
		data.unit_categories.FBI_tank.access = access_type_all
		data.unit_categories.CS_tazer.access = access_type_all
		data.unit_categories.CS_shield.access = access_type_all
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.Units.Cop)
	Hooks:Remove(self.Units.FBI)
	Hooks:Remove(self.Units.SWAT)
	Hooks:Remove(self.Units.HeavySWAT)
	Hooks:Remove(self.Units.FBISWAT)
	Hooks:Remove(self.Units.FBIHeavySWAT)
	Hooks:Remove(self.Units.CitySWAT)
	Hooks:Remove(self.Units.Shield)
	Hooks:Remove(self.Units.Taser)
	Hooks:Remove(self.Units.Tank)
	Hooks:Remove(self.Units.GeneralSpeed)
	Hooks:Remove(self.Units.SpawnCategories)
end

-- END OF FILE
