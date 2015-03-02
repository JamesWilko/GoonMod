
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GageCoins"
Mod.Name = "Gage-Coins"
Mod.Desc = "Gage has started up his own currency. For every courier assignment you complete, you'll get a whole Gage-Coin from the big man himself"
Mod.Requirements = { "ExtendedInventory" }
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mod Data
_G.GoonBase.GageCoins = _G.GoonBase.GageCoins or {}
local GageCoins = _G.GoonBase.GageCoins
local ExtendedInv = _G.GoonBase.ExtendedInventory
GageCoins.CoinID = "gage_coin"

-- Hooks
Hooks:Add("ExtendedInventoryInitialized", "ExtendedInventoryInitialized_" .. Mod:ID(), function()
	
	if not ExtendedInv or not GageCoins then
		return
	end

	ExtendedInv:RegisterItem({
		id = GageCoins.CoinID,
		name = "gm_exinv_gage_coin",
		desc = "gm_exinv_gage_coin_desc",
		reserve_text = "gm_exinv_gage_coin_reserve",
		texture = "guis/textures/pd2/blackmarket/icons/cash",
		hide_when_none_in_stock = false,
	})

end)

Hooks:Add("GageAssignmentManagerOnMissionCompleted", "GageAssignmentManagerOnMissionCompleted_" .. Mod:ID(), function(assignment_manager)

	if not ExtendedInv or not GageCoins then
		return
	end

	local self = assignment_manager
	local total_pickup = 0

	if self._progressed_assignments then
		for assignment, value in pairs(self._progressed_assignments) do

			if value > 0 then

				local collected = Application:digest_value(self._global.active_assignments[assignment], false) + value
				local to_aquire = self._tweak_data:get_value(assignment, "aquire") or 1
				while collected >= to_aquire do
					collected = collected - to_aquire
					ExtendedInv:AddItem(GageCoins.CoinID, 1)
				end

			end

			total_pickup = total_pickup + value
		end
	end

end)
