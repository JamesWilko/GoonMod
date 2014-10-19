----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/20/2014 8:26:44 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "BlackmarketModShop"
Mod.Name = "Gage's Weapon Mod Shop"
Mod.Desc = "Gage will sell you specific weapon parts and mask customization items in return for Gage Coins"
Mod.Requirements = { "ExtendedInventory", "GageCoins" }
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mod Shop
_G.GoonBase.ModShop = _G.GoonBase.ModShop or {}
local ModShop = _G.GoonBase.ModShop
local ExtendedInv = _G.GoonBase.ExtendedInventory

ModShop.PurchaseCurrency = "gage_coin"
ModShop.CostRegular = 1
ModShop.CostInfamous = 3

ModShop.ExclusionList = {
	["nothing"] = true,
	["no_color_no_material"] = true,
	["plastic"] = true,
}

-- Localization
local Localization = GoonBase.Localization
Localization.ModShop_BlackmarketPurchaseWithGageCoins = "Purchase with Gage Coins"
Localization.ModShop_PurchaseWindowTitle = "Purchase"
Localization.ModShop_PurchaseWindowMessage = [[You are about to purchase {1}. This will cost you {2} Gage Coin/s.

Purchasing:
			{1}, {2} GC/s
Balance before purchase:
			{3} GC
Balance after purchase:
			{4} GC]]
Localization.ModShop_PurchaseWindowAccept = "Purchase"
Localization.ModShop_PurchaseWindowCancel = "Cancel"
Localization.ModShop_FreeOfChargeTitle = "Cannot Purchase"
Localization.ModShop_FreeOfChargeMessage = "{1} is free of charge and can be applied to as many weapons as you wish."
Localization.ModShop_FreeOfChargeAccept = "OK"
Localization.ModShop_NotEnoughCoinsWindowTitle = "Cannot Purchase"
Localization.ModShop_NotEnoughCoinsWindowMessage = "You cannot purchase {1}, as you do not have enough Gage Coins to afford it. To purchase {1}, you need {2} GC/s."
Localization.ModShop_NotEnoughCoinsWindowAccept = "OK"

-- Blackmarket Menu
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_" .. Mod:ID(), function(gui, is_start_page, component_data)

	Hooks:RegisterHook("ModShopAttemptPurchaseWeaponMod")
	gui.modshop_purchase_weaponmod_callback = function(self, data)
		Hooks:Call("ModShopAttemptPurchaseWeaponMod", data)
	end

	Hooks:RegisterHook("ModShopAttemptPurchaseMaskPart")
	gui.modshop_purchase_mask_part_callback = function(self, data)
		Hooks:Call("ModShopAttemptPurchaseMaskPart", data)
	end

	local wm_modshop = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "ModShop_BlackmarketPurchaseWithGageCoins",
		callback = callback(gui, gui, "modshop_purchase_weaponmod_callback")
	}

	local mp_modshop = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "ModShop_BlackmarketPurchaseWithGageCoins",
		callback = callback(gui, gui, "modshop_purchase_mask_part_callback")
	}

	local btn_x = 10
	gui._btns["wm_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, wm_modshop, btn_x)
	gui._btns["mp_modshop"] = BlackMarketGuiButtonItem:new(gui._buttons, mp_modshop, btn_x)

end)

Hooks:Add("BlackMarketGUIOnPopulateModsActionList", "BlackMarketGUIOnPopulateModsActionList_" .. Mod:ID(), function(gui, data)
	if data.global_value == nil or data.global_value == "normal" or managers.dlc:has_dlc(data.global_value) then
		table.insert(data, "wm_modshop")
	end
end)

Hooks:Add("BlackMarketGUIOnPopulateMaskModsActionList", "BlackMarketGUIOnPopulateMaskModsActionList_" .. Mod:ID(), function(gui, data)
	if ModShop.ExclusionList[data.name] ~= true then
		if data.global_value == nil or data.global_value == "normal" or managers.dlc:has_dlc(data.global_value) then
			table.insert(data, "mp_modshop")
		end
	end
end)

Hooks:Add("BlackMarketManagerModifyGetInventoryCategory", "BlackMarketManagerModifyGetInventoryCategory_" .. Mod:ID(), function(blackmarket, category, data)

	for k, v in pairs( tweak_data.blackmarket[category] ) do

		local already_in_table = false
		for x, y in pairs( data ) do
			if y.id == k then
				already_in_table = true
			end
		end

		if not already_in_table and ModShop.ExclusionList[k] ~= true then
			table.insert(data, {
				id = k,
				global_value = v.dlc or v.global_value or "normal",
				amount = 0
			})
		end
		
	end

end)

-- Purchase Hooks
Hooks:Add("ModShopAttemptPurchaseWeaponMod", "ModShopAttemptPurchaseWeaponMod_" .. Mod:ID(), function(data)
	ModShop:SetPurchaseData(data)
	ModShop:ShowPurchaseMenu()
end)

Hooks:Add("ModShopAttemptPurchaseMaskPart", "ModShopAttemptPurchaseMaskPart_" .. Mod:ID(), function(data)
	ModShop:SetPurchaseData(data)
	ModShop:ShowPurchaseMenu()
end)

-- Purchase Menu
function ModShop:SetPurchaseData(data)

	local psuccess, perror = pcall(function()

	self._purchase_data = {}
	self._purchase_data.name = data.name
	self._purchase_data.name_localized = data.name_localized
	self._purchase_data.category = data.category
	self._purchase_data.global_value = data.global_value
	self._purchase_data.cost = ModShop.CostRegular

	-- Weapon mod costs
	if ModShop:IsWeaponMod(data.category) then
		if data.free_of_charge ~= nil and data.free_of_charge == true then
			self._purchase_data.free_of_charge = true
		end
	end

	-- Infamous mask part costs
	if ModShop:IsMaskPart(data.category) then

		local mod_data = tweak_data.blackmarket[data.category][data.name]
		if mod_data ~= nil then

			if mod_data.infamous ~= nil and mod_data.infamous == true then
				self._purchase_data.cost = ModShop.CostInfamous
			end

			if mod_data.global_value == "infamy" or mod_data.infamy_lock ~= nil then
				self._purchase_data.cost = ModShop.CostInfamous
			end

		end

	end

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

function ModShop:ShowPurchaseMenu()

	local gage_coins = ExtendedInv:GetItem( ModShop.PurchaseCurrency )
	local purchase_cost = self._purchase_data.cost

	-- Check if item is free of charge
	if self._purchase_data.free_of_charge ~= nil and self._purchase_data.free_of_charge == true then
		self:ShowFreeOfCharge()
		return
	end

	-- Check if we can afford this
	if gage_coins.amount < purchase_cost or purchase_cost <= 0 then
		self:ShowNotEnoughCoins( purchase_cost )
		return
	end
	
	-- Show purchase menu
	local title = managers.localization:text("ModShop_PurchaseWindowTitle")
	local message = managers.localization:text("ModShop_PurchaseWindowMessage")
	message = message:gsub("{1}", self._purchase_data.name_localized)
	message = message:gsub("{2}", purchase_cost)
	message = message:gsub("{3}", gage_coins.amount)
	message = message:gsub("{4}", gage_coins.amount - purchase_cost)

	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("ModShop_PurchaseWindowAccept"),
		callback = ModShop.PurchaseItem
	}
	menuOptions[2] = {
		text = managers.localization:text("ModShop_PurchaseWindowCancel"),
		callback = nil,
		is_cancel_button = true
	}
	local window = SimpleMenu:New(title, message, menuOptions)
	window:Show()

end

function ModShop:ShowFreeOfCharge()

	local title = managers.localization:text("ModShop_FreeOfChargeTitle")
	local message = managers.localization:text("ModShop_FreeOfChargeMessage")
	message = message:gsub("{1}", self._purchase_data.name_localized)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("ModShop_FreeOfChargeAccept"),
		is_cancel_button = true
	}
	local window = SimpleMenu:New(title, message, menuOptions)
	window:Show()

end

function ModShop:ShowNotEnoughCoins(cost)

	local title = managers.localization:text("ModShop_NotEnoughCoinsWindowTitle")
	local message = managers.localization:text("ModShop_NotEnoughCoinsWindowMessage")
	message = message:gsub("{1}", self._purchase_data.name_localized)
	message = message:gsub("{2}", cost)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("ModShop_NotEnoughCoinsWindowAccept"),
		is_cancel_button = true
	}
	local window = SimpleMenu:New(title, message, menuOptions)
	window:Show()

end

function ModShop:PurchaseItem()

	local psuccess, perror = pcall(function()
		
		local item = ModShop._purchase_data.name
		local category = ModShop._purchase_data.category
		local cost = ModShop._purchase_data.cost

		-- Add to weapon inventory
		if ModShop:IsWeaponMod(category) then
			managers.blackmarket:add_to_inventory(ModShop._purchase_data.global_value, "weapon_mods", item, true)
			managers.menu:back(true)
		end

		-- Add to mask inventory
		if ModShop:IsMaskPart(category) then
			managers.blackmarket:add_traded_mask_part_to_inventory(item, category)
		end

		-- Remove coins
		ExtendedInv:TakeItem( ModShop.PurchaseCurrency, cost )
		
	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

function ModShop:IsWeaponMod(category)
	if category == "primaries" or category == "secondaries" then
		return true
	end
	return false
end

function ModShop:IsMaskPart(category)
	if category == "colors" or category == "textures" or category == "materials" then
		return true
	end
	return false
end

-- END OF FILE
