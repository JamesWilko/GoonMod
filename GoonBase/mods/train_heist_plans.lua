----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "TrainHeistPlans"
Mod.Name = "Seperate Train Heist"
Mod.Desc = "The train heist from the Armoured Transport DLC is available as a separate heist"
Mod.Requirements = { "ExtendedInventory" }
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

local Localization = GoonBase.Localization
Localization.TrainHeist_PlansInv = "Train Intel"
Localization.TrainHeist_PlansInvDesc = [[Details of a train transporting an experimental turret. This unlocks the Train Transport heist in Crime.net while you have intel in reserve.

Found in an Armoured Transport.]]

Hooks:Add("NarrativeTweakDataInit", "NarrativeTweakDataInit_" .. Mod:ID(), function(data)

	local ExtendedInv = _G.GoonBase.ExtendedInventory
	if ExtendedInv == nil then
		return
	end

	if ExtendedInv:HasItem("train_heist_plans") then
		table.insert( data._jobs_index, "arm_for_prof" )
		data:set_job_wrappers()
	end

end)

Hooks:Add("LevelsTweakDataInit", "LevelsTweakDataInit_" .. Mod:ID(), function(data)

	local ExtendedInv = _G.GoonBase.ExtendedInventory
	if ExtendedInv == nil then
		return
	end

	if ExtendedInv:HasItem("train_heist_plans") then
		data.arm_for_prof = deep_clone( data.arm_for )
		data.arm_for_prof.bonus_escape = false
		data.arm_for_prof.static_experience = {
			60000,
			70000,
			80000,
			90000,
			100000
		}
		table.insert(data._level_index, "arm_for_prof")
	end
	
end)

Hooks:Add("ExtendedInventoryInitialized", "ExtendedInventoryInitialized_TrainHeistPlans", function()
	
	local ExtendedInv = _G.GoonBase.ExtendedInventory
	if ExtendedInv == nil then
		return
	end

	ExtendedInv:RegisterItem({
		id = "train_heist_plans",
		name = "TrainHeist_PlansInv",
		desc = "TrainHeist_PlansInvDesc",
		texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/train_01",
		hide_when_none_in_stock = true,
	})

end)

Hooks:Add("JobManagerOnSetNextInteruptStage", "JobManagerOnSetNextInteruptStage_TrainHeistPlans", function(job_manager, interupt)

	if interupt == "arm_for" then
		
		managers.job:set_next_interupt_stage(nil)

		local ExtendedInv = _G.GoonBase.ExtendedInventory
		if ExtendedInv ~= nil then
			ExtendedInv:AddItem("train_heist_plans", 1)
		end

	end

end)

-- END OF FILE
