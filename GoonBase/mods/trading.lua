----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "Trading"
Mod.Name = "Crime.net Cargo"
Mod.Desc = "Send and receive weapons, weapon mods, masks, and mask parts between your friends and other players"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Trading
_G.GoonBase.Trading = _G.GoonBase.Trading or {}
local Trading = _G.GoonBase.Trading

Trading.TradablePeers = Trading.TradablePeers or {}
Trading.BlackMarketGUI = nil
Trading.TradeData = {}
Trading.ActiveTradeWindow = nil
Trading.MenuId = "goonbase_trading_options_menu"

-- Categories
Trading.Categories = {}
Trading.Categories.PrimaryWeapon = "primaries"
Trading.Categories.SecondaryWeapon = "secondaries"
Trading.Categories.WeaponMod = "weapon_mod"
Trading.Categories.Mask = "masks"
Trading.Categories.MaskColour = "colors"
Trading.Categories.MaskPattern = "textures"
Trading.Categories.MaskMaterial = "materials"

-- Network
Trading.Network = Trading.Network or {}
Trading.Network.MessageType = Trading.Network.MessageType or {}
Trading.Network.MessageType.System = "TradeSystem"
Trading.Network.MessageType.Request = "TradeRequest"
Trading.Network.MessageType.RequestResponse = "TradeRequestResponse"
Trading.Network.MessageType.Cancel = "TradeCancel"
Trading.Network.MessageType.Category = "TradeCategory"
Trading.Network.MessageType.Weapon = "TradeWeapon"
Trading.Network.MessageType.WeaponMods = "TradeWeaponMods"
Trading.Network.MessageType.SingleWeaponMod = "TradeSingleWeaponMod"
Trading.Network.MessageType.Mask = "TradeMask"
Trading.Network.MessageType.MaskColour = "TradeColour"
Trading.Network.MessageType.MaskPattern = "TradePattern"
Trading.Network.MessageType.MaskMaterial = "TradeMaterial"

Trading.Network.RequestTradability = "RequestTradability"
Trading.Network.TradabilityHandshake = "TradabilityHandshake"

Trading.Network.TradeAccept = "Accept"
Trading.Network.TradeDecline = "Decline"
Trading.Network.AutoDecline_PrimaryWeaponSlots = "DeclinePrimarySlots"
Trading.Network.AutoDecline_SecondaryWeaponSlots = "DeclineSecondarySlots"
Trading.Network.AutoDecline_MaskSlots = "DeclineMaskSlots"
Trading.Network.AutoDecline_AlreadyTrading = "AlreadyTrading"

-- Options
GoonBase.Options.Trading = {}
GoonBase.Options.Trading.Enabled = true

-- Localization
local Localization = GoonBase.Localization
Localization.Trading_OptionsMenuTitle = "Crime.net Cargo"
Localization.Trading_OptionsMenuMessage = "Modify Crime.net Cargo Settings"
Localization.Trading_OptionsTitle = "Enable Crime.net Cargo"
Localization.Trading_OptionsMessage = "Enable Crime.net Cargo Modification"

Localization.Trading_InventorySendToPlayer = "Crime.net Cargo"
Localization.Trading_TradeWindowTitle = "Crime.net Cargo"
Localization.Trading_TradeWindowMessage = "Send {1} to:"
Localization.Trading_TradeWindowCancel = "Cancel"
Localization.Trading_TradeWindowOk = "OK"

Localization.Trading_OnlineOnlyTitle = "Crime.net Cargo Offline"
Localization.Trading_OnlineOnlyMessage = "You must be in a lobby to send cargo to somebody!";
Localization.Trading_OnlineOnlyCancel = "OK"

Localization.Trading_NoPeersTitle = "Crime.net Cargo"
Localization.Trading_NoPeersMessage = "There are no players who can receive cargo in the lobby!"
Localization.Trading_NoPeersCancel = "OK"

Localization.Trading_TradeRequestMessage = "{1} would like to send you {2} ({3})."
Localization.Trading_TradeRequestAccept = "Accept"
Localization.Trading_TradeRequestDecline = "Decline"
Localization.Trading_TradeAccepted = "You have sent {1} to {2}!"
Localization.Trading_TradeDeclined = "{1} declined your {2}."

Localization.Trading_InventoryFull = "{1} is trying to send you {2}, but you do not have any free {3} slots."
Localization.Trading_InventoryFullReason = "{1} could not be sent to {2}, as they do not have enough free {3} slots."

Localization.Trading_WeaponModRemovedDLC = "The {1} attached to this weapon has been removed as you do not own the '{2}' downloadable content."
Localization.Trading_WeaponSendWithMods = "Do you want to send the mods attached to this weapon too?"
Localization.Trading_WeaponSendMods = "Send with mods"
Localization.Trading_WeaponDontSendMods = "Don't send mods"

Localization.Trading_WeaponModReceived = "You have received {1} from {2}."
Localization.Trading_WeaponModReceivedNoDLC = "You have received {1} from {2}, but you do not own the '{3}' downloadable content and may not be able to use it."
Localization.Trading_WeaponModAccept = "OK"

Localization.Trading_MaskReceived = "You have received {1} from {2}."
Localization.Trading_MaskReceivedNoDLC = "You have received {1} from {2}, but you do not own the {3} downloadable content/s. Your items have been added to your stash."
Localization.Trading_MaskReceivedAccept = "OK"

Localization.Trading_UntradableMask = "The mask '{1}' is untradable. {2} must be returned to the stash and can not be traded to other players."
Localization.Trading_UntradableMaskAccept = "OK"

Localization.Trading_UntradableMaskMod = "The mask mod '{1}' is untradable, as it must be returned to the stash and can not be traded to other players."
Localization.Trading_UntradableMaskModAccept = "OK"

Localization.Trading_WaitingResponseTitle = "Awaiting Response"
Localization.Trading_WaitingResponseMessage = "Awaiting response from {1}."
Localization.Trading_WaitingResponseCancel = "Cancel Trade"

Localization.Trading_OtherCancelledTitle = "Trade Cancelled"
Localization.Trading_OtherCancelledMessage = "{1} has cancelled the trade with you."
Localization.Trading_OtherCancelledAccept = "OK"

Localization.Trading_AlreadyTradingTitle = "Trade Unavailable"
Localization.Trading_AlreadyTradingMessage = "{1} is unavailable to trade with at the moment, as they are already in another trade."
Localization.Trading_AlreadyTradingAccept = "OK"

-- DLC Names
Trading.DLCNames = {
	infamous = "Infamy",
	twitch_pack = "Twitch Pack",
	dlc1 = "Armoured Transport",
	armored_transport = "Armoured Transport",
	gage_pack = "Gage Weapon Pack #01",
	gage_pack_lmg = "Gage Weapon Pack #02",
	gage_pack_jobs = "Gage Mod Courier",
	gage_pack_snp = "Gage Sniper Pack",
	gage_pack_assault = "Gage Assault Pack",
	big_bank = "The Big Bank Heist",
	gage_pack_shotgun = "Gage Shotgun Pack",
	season_pass = "Season Pass",
	animal = "Animal"
}

-- Options Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_Trading", function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( Trading.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_Trading", function( menu_manager )

	GoonBase.MenuHelper:AddButton({
		id = "trading_submenu_options_button",
		title = "Trading_OptionsMenuTitle",
		desc = "Trading_OptionsMenuMessage",
		next_node = Trading.MenuId,
		menu_id = "goonbase_options_menu",
		priority = 100
	})

	MenuCallbackHandler.toggle_trading_enabled = function(this, item)
		GoonBase.Options.Trading.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end
	
	GoonBase.MenuHelper:AddToggle({
		id = "toggle_trading_enabled",
		title = "Trading_OptionsTitle",
		desc = "Trading_OptionsMessage",
		callback = "toggle_trading_enabled",
		value = GoonBase.Options.Trading.Enabled,
		menu_id = Trading.MenuId,
		priority = 50
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_Trading", function(menu_manager, mainmenu_nodes)
	mainmenu_nodes[Trading.MenuId] = GoonBase.MenuHelper:BuildMenu( Trading.MenuId )
end)

-- Blackmarket Menu
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_InjectTradeButton", function(gui, is_start_page, component_data)

	Hooks:RegisterHook("TradingAttemptTradeWeapon")
	gui.trade_weapon_callback = function(self, data)
		Hooks:Call("TradingAttemptTradeWeapon", data)
	end

	Hooks:RegisterHook("TradingAttemptTradeWeaponMod")
	gui.trade_weaponmod_callback = function(self, data)
		Hooks:Call("TradingAttemptTradeWeaponMod", data)
	end

	Hooks:RegisterHook("TradingAttemptTradeMask")
	gui.trade_mask_callback = function(self, data)
		Hooks:Call("TradingAttemptTradeMask", data)
	end

	Hooks:RegisterHook("TradingAttemptTradeMaskPart")
	gui.trade_mask_part_callback = function(self, data)
		Hooks:Call("TradingAttemptTradeMaskPart", data)
	end

	local w_trade = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "Trading_InventorySendToPlayer",
		callback = callback(gui, gui, "trade_weapon_callback")
	}

	local m_trade = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "Trading_InventorySendToPlayer",
		callback = callback(gui, gui, "trade_mask_callback")
	}

	local wm_trade = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "Trading_InventorySendToPlayer",
		callback = callback(gui, gui, "trade_weaponmod_callback")
	}

	local mp_trade = {
		prio = 5,
		btn = "BTN_X",
		pc_btn = nil,
		name = "Trading_InventorySendToPlayer",
		callback = callback(gui, gui, "trade_mask_part_callback")
	}

	local btn_x = 10
	gui._btns["w_trade"] = BlackMarketGuiButtonItem:new(gui._buttons, w_trade, btn_x)
	gui._btns["m_trade"] = BlackMarketGuiButtonItem:new(gui._buttons, m_trade, btn_x)
	gui._btns["wm_trade"] = BlackMarketGuiButtonItem:new(gui._buttons, wm_trade, btn_x)
	gui._btns["mp_trade"] = BlackMarketGuiButtonItem:new(gui._buttons, mp_trade, btn_x)

end)

Hooks:Add("BlackMarketGUIOnPopulateWeaponActionList", "BlackMarketGUIOnPopulateWeaponActionList_" .. Mod:ID(), function(gui, data)

	if GoonBase.Options.Trading.Enabled and not data.last_weapon and not data.equipped then
		table.insert(data, "w_trade")
	end

end)

Hooks:Add("BlackMarketGUIOnPopulateMasksActionList", "BlackMarketGUIOnPopulateMasksActionList_" .. Mod:ID(), function(gui, data)

	if GoonBase.Options.Trading.Enabled and not data.equipped then
		table.insert(data, "m_trade")
	end

end)

Hooks:Add("BlackMarketGUIOnPopulateModsActionList", "BlackMarketGUIOnPopulateModsActionList_" .. Mod:ID(), function(gui, data)

	if GoonBase.Options.Trading.Enabled then
		if type(data.unlocked) ~= "number" or data.unlocked > 0 then
			table.insert(data, "wm_trade")
		end
	end

end)

Hooks:Add("BlackMarketGUIOnPopulateMaskModsActionList", "BlackMarketGUIOnPopulateMaskModsActionList_" .. Mod:ID(), function(gui, data)

	if GoonBase.Options.Trading.Enabled and not data.equipped and data.amount ~= nil and data.amount > 0 then
		table.insert(data, "mp_trade")
	end

end)

-- Request client tradability when we open the inventory
Hooks:Add("BlackMarketGUIOnPopulateWeapons", "BlackMarketGUIOnPopulateWeapons_Trading", function(gui, category, data)

	if not GoonBase.Options.Trading.Enabled then
		return
	end

	Trading.BlackMarketGUI = gui

	-- Request tradability from peers
	if GoonBase.Network:IsMultiplayer() then
		Trading.TradablePeers = {}
		GoonBase.Network:SendToPeers(Trading.Network.MessageType.System, Trading.Network.RequestTradability)
	end

end)

Hooks:Add("BlackMarketGUIOnPopulateMasks", "BlackMarketGUIOnPopulateMasks_Trading", function(gui, category, data)
	
	if not GoonBase.Options.Trading.Enabled then
		return
	end

	Trading.BlackMarketGUI = gui

end)

Hooks:Add("BlackMarketGUIOnPopulateMods", "BlackMarketGUIOnPopulateMods_Trading", function(gui, category, data)
	
	if not GoonBase.Options.Trading.Enabled then
		return
	end

	Trading.BlackMarketGUI = gui

end)

Hooks:Add("BlackMarketGUIOnPopulateMaskMods", "BlackMarketGUIOnPopulateMaskMods_Trading", function(gui, category, data)
	
	if not GoonBase.Options.Trading.Enabled then
		return
	end

	Trading.BlackMarketGUI = gui

end)

-- Check if we have any tradable peers
function Trading:HasTradablePeers()

	local tradable_peers = 0
	for k, v in pairs( managers.network:session():peers() ) do
		if Trading.TradablePeers[k] == true then
			tradable_peers = tradable_peers + 1
		end
	end

	if tradable_peers < 1 then
		return false
	end

	return true

end

-- Process trade messages
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_Trading", function(sender, messageType, data)

	-- Don't process if disabled
	if not GoonBase.Options.Trading.Enabled then
		return
	end

	-- Trade System Messages
	if messageType == Trading.Network.MessageType.System then

		if data == Trading.Network.RequestTradability then
			Trading:RequestTradabilityHandshake(sender)
			return
		end
		if data == Trading.Network.TradabilityHandshake then
			Trading:CompleteTradabilityHandshake(sender)
			return
		end

	end

	-- Trade Response
	if messageType == Trading.Network.MessageType.RequestResponse then
		Trading:TradeResponseReceived(sender, data)
		return
	end

	-- Trade Already-In-Progress Reply
	if Trading.TradeData.CurrentlyTradingWith ~= nil and Trading.TradeData.CurrentlyTradingWith ~= sender then
		GoonBase.Network:SendToPeer(sender, Trading.Network.MessageType.RequestResponse, Trading.Network.AutoDecline_AlreadyTrading)
		return
	end

	-- Make sure player only ever gets trade data from one player
	Trading.TradeData.CurrentlyTradingWith = sender

	-- Trade Requests
	if messageType == Trading.Network.MessageType.Request then
		Trading:TradeRequested(sender)
		return
	end

	-- Trade Cancel
	if messageType == Trading.Network.MessageType.Cancel then
		Trading:HandleTradeCancelled(sender)
		return
	end

	-- Trade Data
	if messageType == Trading.Network.MessageType.Category then
		Trading.TradeData.Category = data
		return
	end

	if messageType == Trading.Network.MessageType.Weapon then
		Trading.TradeData.Weapon = data
		return
	end

	if messageType == Trading.Network.MessageType.WeaponMods then
		if Trading.TradeData.WeaponMods == nil then
			Trading.TradeData.WeaponMods = {}
		end
		table.insert( Trading.TradeData.WeaponMods, data )
		return
	end

	if messageType == Trading.Network.MessageType.SingleWeaponMod then
		Trading.TradeData.WeaponMod = data
		return
	end

	-- Mask Data
	if messageType == Trading.Network.MessageType.Mask then
		Trading.TradeData.Mask = data
	end

	-- Mask Mod Data
	if messageType == Trading.Network.MessageType.MaskPattern then
		if Trading.TradeData.MaskMods == nil then
			Trading.TradeData.MaskMods = {}
		end
		Trading.TradeData.MaskMods.Pattern = data
		return
	end

	if messageType == Trading.Network.MessageType.MaskMaterial then
		if Trading.TradeData.MaskMods == nil then
			Trading.TradeData.MaskMods = {}
		end
		Trading.TradeData.MaskMods.Material = data
		return
	end

	if messageType == Trading.Network.MessageType.MaskColour then
		if Trading.TradeData.MaskMods == nil then
			Trading.TradeData.MaskMods = {}
		end
		Trading.TradeData.MaskMods.Colour = data
		return
	end

end)

-- Handle tradability handshake
function Trading:RequestTradabilityHandshake(sender)
	if GoonBase.Options.Trading.Enabled then
		GoonBase.Network:SendToPeer(sender, Trading.Network.MessageType.System, Trading.Network.TradabilityHandshake)
	end
end
function Trading:CompleteTradabilityHandshake(sender)
	Trading.TradablePeers[sender] = true
end

-- Handle trade request
function Trading:TradeRequested(sender, data)

	Trading.TradeData.Trader = sender	
	local category = Trading.TradeData.Category

	-- Check if player has enough primary weapon slots to trade
	if category == Trading.Categories.PrimaryWeapon then

		local slot = managers.blackmarket:_get_free_weapon_slot( Trading.Categories.PrimaryWeapon )
		local weaponName = managers.weapon_factory:get_weapon_name_by_weapon_id( Trading.TradeData.Weapon )
		if slot ~= nil then
			
			Trading:ShowTradeResponseWindow(sender, { name = weaponName, category = "Primary Weapon" })
		else
			Trading:ShowFullInventoryWindow(sender, { item = weaponName, slot = "primary weapon" })
			GoonBase.Network:SendToPeer(sender, Trading.Network.MessageType.RequestResponse, Trading.Network.AutoDecline_PrimaryWeaponSlots)
		end

	end

	-- Check if player has enough secondary weapon slots to trade
	if category == Trading.Categories.SecondaryWeapon then

		local slot = managers.blackmarket:_get_free_weapon_slot( Trading.Categories.SecondaryWeapon )
		local weaponName = managers.weapon_factory:get_weapon_name_by_weapon_id( Trading.TradeData.Weapon )
		if slot ~= nil then
			Trading:ShowTradeResponseWindow(sender, { name = weaponName, category = "Secondary Weapon" })
		else
			Trading:ShowFullInventoryWindow(sender, { item = weaponName, slot = "secondary weapon" })
			GoonBase.Network:SendToPeer(sender, Trading.Network.MessageType.RequestResponse, Trading.Network.AutoDecline_SecondaryWeaponSlots)
		end

	end

	-- Single Weapon Mod Trade
	if category == Trading.Categories.WeaponMod then
		local modName = managers.weapon_factory:get_part_name_by_part_id( Trading.TradeData.WeaponMod )
		Trading:ShowTradeResponseWindow(sender, { name = modName, category = "Weapon Mod" })
	end

	-- Mask Trading
	local success, err = pcall(function()

	if category == Trading.Categories.Mask then

		local mask_name = managers.blackmarket:get_mask_name( Trading.TradeData.Mask )

		-- Check if player is trying to send premodded mask
		if Trading.TradeData.MaskMods ~= nil then

			-- Check if player has free mask slots
			local slot = managers.blackmarket:get_free_mask_slot()
			if slot ~= nil then
				Trading:ShowTradeResponseWindow(sender, { name = mask_name or "error: mask_name", category = "Mask" })
			else
				Trading:ShowFullInventoryWindow(sender, { item = mask_name or "error: mask_name", slot = "mask" })
				GoonBase.Network:SendToPeer(sender, Trading.Network.MessageType.RequestResponse, Trading.Network.AutoDecline_MaskSlots)
			end

		else
			Trading:ShowTradeResponseWindow(sender, { name = mask_name or "error: mask_name", category = "Mask" })
		end

	end

	-- Mask Material
	if category == Trading.Categories.MaskMaterial then
		local mod_name = managers.blackmarket:get_mask_mod_name( Trading.TradeData.MaskMods.Material, Trading.Categories.MaskMaterial )
		Trading:ShowTradeResponseWindow(sender, { name = mod_name or "error: mod_name", category = "Mask Material" })
	end

	-- Mask Pattern
	if category == Trading.Categories.MaskPattern then
		local mod_name = managers.blackmarket:get_mask_mod_name( Trading.TradeData.MaskMods.Pattern, Trading.Categories.MaskPattern )
		Trading:ShowTradeResponseWindow(sender, { name = mod_name or "error: mod_name", category = "Mask Pattern" })
	end

	-- Mask Color
	if category == Trading.Categories.MaskColour then
		local mod_name = managers.blackmarket:get_mask_mod_name( Trading.TradeData.MaskMods.Colour, Trading.Categories.MaskColour )
		Trading:ShowTradeResponseWindow(sender, { name = mod_name or "error: mod_name", category = "Mask Colours" })
	end

	end)
	if not success then Print(err) end

end

function Trading:ShowTradeResponseWindow(sender, data)

	local senderName = GoonBase.Network:GetNameFromPeerID(sender)

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_TradeRequestMessage")
	message = message:gsub("{1}", senderName)
	message = message:gsub("{2}", data.name)
	message = message:gsub("{3}", data.category)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_TradeRequestAccept"),
		callback = Trading.TradeRequestAccept,
		is_cancel_button = true
	}
	menuOptions[2] = {
		text = managers.localization:text("Trading_TradeRequestDecline"),
		callback = Trading.TradeRequestDecline,
		is_cancel_button = true
	}
	Trading.ActiveTradeWindow = SimpleMenu:New(title, message, menuOptions)
	Trading.ActiveTradeWindow:Show()

end

function Trading:ShowFullInventoryWindow(sender, data)

	local senderName = GoonBase.Network:GetNameFromPeerID(sender)

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_InventoryFull")
	message = message:gsub("{1}", senderName)
	message = message:gsub("{2}", data.item)
	message = message:gsub("{3}", data.slot)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_TradeWindowOk"),
		is_cancel_button = true
	}
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

function Trading.TradeRequestAccept(data)

	GoonBase.Network:SendToPeer(Trading.TradeData.Trader, Trading.Network.MessageType.RequestResponse, Trading.Network.TradeAccept)
	
	local category = Trading.TradeData.Category

	if category == Trading.Categories.PrimaryWeapon then
		Trading:AddWeaponToInventory( Trading.TradeData.Weapon, Trading.TradeData.WeaponMods )
		managers.menu:back(true)
	end

	if category == Trading.Categories.SecondaryWeapon then
		Trading:AddWeaponToInventory( Trading.TradeData.Weapon, Trading.TradeData.WeaponMods )
		managers.menu:back(true)
	end

	if category == Trading.Categories.WeaponMod then
		Trading:AddTradedModToInventory()
		managers.menu:back(true)
		managers.menu:back(true)
	end

	if category == Trading.Categories.Mask then
		Trading:AddTradedMaskToInventory()
		managers.menu:back(true)
	end

	if category == Trading.Categories.MaskMaterial or category == Trading.Categories.MaskPattern or category == Trading.Categories.MaskColour then
		Trading:AddTradedMaskModToInventory()
	end

	Trading.TradeData = {}

end

function Trading.TradeRequestDecline(data)
	GoonBase.Network:SendToPeer(Trading.TradeData.Trader, Trading.Network.MessageType.RequestResponse, Trading.Network.TradeDecline)
	Trading.TradeData = {}
end

-- Handle Trade Response
function Trading:TradeResponseReceived(sender, data)

	if data == Trading.Network.TradeAccept then
		Trading:TradeResponseAccept(sender)
		return
	end

	if data == Trading.Network.AutoDecline_PrimaryWeaponSlots then
		Trading:TradeResponseFullInventory("primary weapon")
		return
	end

	if data == Trading.Network.AutoDecline_SecondaryWeaponSlots then
		Trading:TradeResponseFullInventory("secondary weapon")
		return
	end

	if data == Trading.Network.AutoDecline_MaskSlots then
		Trading:TradeResponseFullInventory("mask")
		return
	end

	if data == Trading.Network.AutoDecline_AlreadyTrading then
		Trading:TradeResponseAlreadyTrading()
		return
	end
	
	Trading:TradeResponseDecline(sender)

end

function Trading:TradeResponseAccept(sender)

	local success, err = pcall(function()

	local category = Trading.TradeData.Category

	if category == Trading.Categories.PrimaryWeapon or category == Trading.Categories.SecondaryWeapon then
		Trading:ShowTradeResponseAcceptWindow( sender, Trading.TradeData.RawData.slot.name_localized )
		Trading:RemoveWeaponFromInventory()
		managers.menu:back(true)
	end

	if category == Trading.Categories.WeaponMod then
		Trading:ShowTradeResponseAcceptWindow( sender, Trading.TradeData.RawData.slot.name_localized )
		Trading:RemoveModFromInventory()
		managers.menu:back(true)
		managers.menu:back(true)
	end

	if category == Trading.Categories.Mask then
		Trading:ShowTradeResponseAcceptWindow( sender, managers.blackmarket:get_mask_name( Trading.TradeData.RawData.slot.mask_id ) )
		managers.blackmarket:remove_mask_from_inventory( Trading.TradeData.RawData.slot )
		managers.menu:back(true)
	end

	if category == Trading.Categories.MaskMaterial or category == Trading.Categories.MaskPattern or category == Trading.Categories.MaskColour then
		Trading:ShowTradeResponseAcceptWindow( sender, managers.blackmarket:get_mask_mod_name( Trading.TradeData.RawData.slot.name, Trading.TradeData.RawData.slot.category ) )
		-- TODO
		managers.blackmarket:remove_mask_mod_from_inventory( Trading.TradeData.RawData.slot.name, Trading.TradeData.RawData.slot.category )
	end

	end)

	if not success then Print(err) end

end

function Trading:ShowTradeResponseAcceptWindow(sender, item_name)

	Trading:CloseActiveWindow()

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_TradeAccepted")
	message = message:gsub("{1}", item_name)
	message = message:gsub("{2}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Recipient))
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

function Trading:TradeResponseDecline(sender)

	local success, err = pcall(function()

	Trading:CloseActiveWindow()

	if Trading.TradeData.Recipient == nil then
		return
	end

	local category = Trading.TradeData.Category
	local item_name = "trade"
	if category == Trading.Categories.PrimaryWeapon or category == Trading.Categories.SecondaryWeapon or category == Trading.Categories.WeaponMod then
		item_name = Trading.TradeData.RawData.slot.name_localized or item_name
	end
	if category == Trading.Categories.Mask then
		item_name = managers.blackmarket:get_mask_name( Trading.TradeData.RawData.slot.mask_id )
	end

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_TradeDeclined")
	message = message:gsub("{1}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Recipient))
	message = message:gsub("{2}", item_name)
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

	Trading.TradeData = {}

	end)
	if not success then Print(err) end

end

function Trading:TradeResponseAlreadyTrading()

	local success, err = pcall(function()

	Trading:CloseActiveWindow()

	if Trading.TradeData.Recipient == nil then
		return
	end

	local title = managers.localization:text("Trading_AlreadyTradingTitle")
	local message = managers.localization:text("Trading_AlreadyTradingMessage")
	message = message:gsub("{1}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Recipient))
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_AlreadyTradingAccept"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

	Trading.TradeData = {}

	end)
	if not success then Print(err) end

end

function Trading:TradeResponseFullInventory(reason)

	Trading:CloseActiveWindow()

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_InventoryFullReason")
	message = message:gsub("{1}", managers.weapon_factory:get_weapon_name_by_weapon_id(Trading.TradeData.Weapon))
	message = message:gsub("{2}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Recipient))
	message = message:gsub("{3}", reason)
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

-- Show Trade Menu when player clicks the trade button
Hooks:Add("TradingAttemptTradeWeapon", "TradingAttemptTradeWeapon_ShowMenu", function(weapon)
	Trading:ShowSendToPlayerMenu(weapon.name_localized, weapon)
end)

Hooks:Add("TradingAttemptTradeWeaponMod", "TradingAttemptTradeWeaponMod_ShowMenu", function(mod)
	-- Mods use 'primaries' and 'secondaries' which we use for weapons
	-- So we use a custom category to make the trading work with them
	mod.category = Trading.Categories.WeaponMod
	Trading:ShowSendToPlayerMenu(mod.name_localized, mod)
end)

Hooks:Add("TradingAttemptTradeMask", "TradingAttemptTradeMask_ShowMenu", function(mask)

	local data = managers.blackmarket:get_mask_slot_data(mask)
	data.category = "masks"
	data.slot = mask.slot

	-- Verify mask parts before sending the mask
	-- Some mods get returned to the inventory when selling the mask, stop masks with these on from being traded
	-- so that we don't duplicate mods. TODO: Ask Overkill about this before release!
	if Trading:VerifyMaskTradability(data) then
		Trading:ShowSendToPlayerMenu(mask.name_localized, data)
	end

end)

Hooks:Add("TradingAttemptTradeMaskPart", "TradingAttemptTradeMaskPart_ShowMenu", function(mod)

	-- Verify mask mod before sending the mask
	if Trading:VerifyMaskModTradability(mod) then
		Trading:ShowSendToPlayerMenu(mod.name_localized, mod)
	end

end)

function Trading:ShowSendToPlayerMenu(item_name, item_data)

	if GoonBase.Network:IsMultiplayer() then

		-- Check for tradable peers
		if not Trading:HasTradablePeers() then
			Trading:NoTradablePeersWindow()
			return
		end

		-- Show tradable peers
		local title = managers.localization:text("Trading_TradeWindowTitle")
		local message = managers.localization:text("Trading_TradeWindowMessage"):gsub("{1}", item_name)
		local menuOptions = {}

		for k, v in pairs( managers.network:session():peers() ) do

			if Trading.TradablePeers[k] == true then

				local plyData = {
					text = v._name,
					callback = Trading.SendToPlayerCallback,
					data = {
						peer = k,
						slot = item_data
					}
				}
				table.insert( menuOptions, plyData )

			end

		end
		table.insert( menuOptions, { text = managers.localization:text("Trading_TradeWindowCancel"), is_cancel_button = true } )

		local tradeMenu = SimpleMenu:New(title, message, menuOptions)
		tradeMenu:Show()

	else
		Trading:ShowOnlineOnlyWindow()
	end

end

function Trading.SendToPlayerCallback(data)

	local success, err = pcall(function()

		local category = data.slot.category
		Trading.TradeData = {
			Recipient = data.peer,
			Category = category,
			RawData = data
		}

		-- Send category to recepient
		GoonBase.Network:SendToPeer(data.peer, Trading.Network.MessageType.Category, category)

		-- Weapon trading
		if category == Trading.Categories.PrimaryWeapon or category == Trading.Categories.SecondaryWeapon then

			-- Ask if we should send just the weapon or with the mods
			local title = managers.localization:text("Trading_TradeWindowTitle")
			local message = managers.localization:text("Trading_WeaponSendWithMods")
			local menuOptions = {}
			menuOptions[1] = {
				text = managers.localization:text("Trading_WeaponSendMods"),
				callback = Trading.CallbackSendWeaponToPlayer,
				data = {
					trade_data = data,
					send_mods = true
				}
			}
			menuOptions[2] = {
				text = managers.localization:text("Trading_WeaponDontSendMods"),
				callback = Trading.CallbackSendWeaponToPlayer,
				data = {
					trade_data = data,
					send_mods = false
				}
			}
			local tradeMenu = SimpleMenu:New(title, message, menuOptions)
			tradeMenu:Show()

		end

		-- Weapon Mod Trading
		if category == Trading.Categories.WeaponMod then
			Trading:CallbackSendModToPlayer(data)
		end

		-- Mask Trading
		if category == Trading.Categories.Mask then
			Trading:CallbackSendMaskToPlayer(data)
		end

		-- Mask Material/Pattern/Colour Trading
		if category == Trading.Categories.MaskMaterial or category == Trading.Categories.MaskPattern or category == Trading.Categories.MaskColour then
			Trading:CallbackSendMaskModToPlayer(data)
		end

	end)
	if not success then Print(err) end

end

function Trading.CallbackSendWeaponToPlayer(data)

	local trade_data = data.trade_data
	Trading.TradeData.SendWeaponMods = data.send_mods

	local weaponMods = BlackMarketManager:get_mods_on_weapon(trade_data.slot.category, trade_data.slot.slot)
	GoonBase.Network:SendToPeer(trade_data.peer, Trading.Network.MessageType.Weapon, trade_data.slot.name)

	if data.send_mods then
		for i, modName in pairs(weaponMods) do
			GoonBase.Network:SendToPeer(trade_data.peer, Trading.Network.MessageType.WeaponMods, modName)
		end
	end

	GoonBase.Network:SendToPeer(trade_data.peer, Trading.Network.MessageType.Request, "")
	Trading.TradeData.Weapon = trade_data.slot.name
	Trading.TradeData.WeaponMods = weaponMods
	Trading.TradeData.Slot = trade_data.slot

	-- Show waiting window
	Trading:ShowWaitingResponseWindow()

end

function Trading:CallbackSendModToPlayer(data)

	-- Send trade data to player
	GoonBase.Network:SendToPeer(data.peer, Trading.Network.MessageType.SingleWeaponMod, data.slot.name)

	-- Send request to player
	GoonBase.Network:SendToPeer(data.peer, Trading.Network.MessageType.Request, "")

	-- Show waiting window
	Trading:ShowWaitingResponseWindow()

end

function Trading:CallbackSendMaskToPlayer(data)

	-- Table stuff
	local peer = data.peer
	data = data.slot

	-- Send modded mask data to player
	if data.modded then
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskMaterial, data.blueprint.material.id)
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskPattern, data.blueprint.pattern.id)
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskColour, data.blueprint.color.id)
	end

	-- Send mask data to player
	GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.Mask, data.mask_id)

	-- Send request to player
	GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.Request, "")

	-- Show waiting window
	Trading:ShowWaitingResponseWindow()

end

function Trading:CallbackSendMaskModToPlayer(data)
	
	-- Table stuff
	local peer = data.peer
	data = data.slot

	-- Send data to player
	if data.category == Trading.Categories.MaskMaterial then
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskMaterial, data.name)
	end
	if data.category == Trading.Categories.MaskPattern then
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskPattern, data.name)
	end
	if data.category == Trading.Categories.MaskColour then
		GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.MaskColour, data.name)
	end

	-- Send request
	GoonBase.Network:SendToPeer(peer, Trading.Network.MessageType.Request, "")

	-- Show waiting window
	Trading:ShowWaitingResponseWindow()

end

-- Trading Offline Screen
function Trading:ShowOnlineOnlyWindow()
	
	local title = managers.localization:text("Trading_OnlineOnlyTitle")
	local message = managers.localization:text("Trading_OnlineOnlyMessage")
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_OnlineOnlyCancel"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

-- No Tradable Peers Screen
function Trading:NoTradablePeersWindow()

	local title = managers.localization:text("Trading_NoPeersTitle")
	local message = managers.localization:text("Trading_NoPeersMessage")
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_NoPeersCancel"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

-- Trade Wait Screen
function Trading:ShowWaitingResponseWindow()

	local title = managers.localization:text("Trading_WaitingResponseTitle")
	local message = managers.localization:text("Trading_WaitingResponseMessage")
	message = message:gsub("{1}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Recipient))
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_WaitingResponseCancel"),
		callback = Trading.WaitingResponseCancel,
	}
	Trading.ActiveTradeWindow = SimpleMenu:New(title, message, menuOptions)
	Trading.ActiveTradeWindow.dialog_data.indicator = true
	Trading.ActiveTradeWindow:Show()

end

-- Trade Cancelling
function Trading.WaitingResponseCancel()

	-- Close trade waiting screen
	Trading:CloseActiveWindow()

	-- Tell recipient to clear trade data
	GoonBase.Network:SendToPeer(Trading.TradeData.Recipient, Trading.Network.MessageType.Cancel, "")

	-- Clear local trade data
	Trading.TradeData = {}

end

function Trading:HandleTradeCancelled(sender)
	
	-- Remove trade response window
	Trading:CloseActiveWindow()

	-- Show trade cancelled window
	local title = managers.localization:text("Trading_OtherCancelledTitle")
	local message = managers.localization:text("Trading_OtherCancelledMessage")
	message = message:gsub("{1}", GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Trader))
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_OtherCancelledAccept"),
		is_cancel_button = true
	}
	Trading.ActiveTradeWindow = SimpleMenu:New(title, message, menuOptions)
	Trading.ActiveTradeWindow.dialog_data.indicator = true
	Trading.ActiveTradeWindow:Show()

	-- Clear local trade data
	Trading.TradeData = {}

end

-- Windows
function Trading:CloseActiveWindow()
	if Trading.ActiveTradeWindow ~= nil then
		managers.system_menu:close(Trading.ActiveTradeWindow.dialog_data.id)
		Trading.ActiveTradeWindow.visible = false
		Trading.ActiveTradeWindow = nil
	end
end

-- Weapon Inventory
function Trading:_GetWeaponTweakData(weapon)
	return tweak_data.weapon[weapon]
end

function Trading:AddWeaponToInventory(weapon, mods)

	local category = Trading.TradeData.Category or "primaries"
	local freeSlot = managers.blackmarket:_get_free_weapon_slot(category)

	if freeSlot ~= nil then

		managers.blackmarket:on_buy_weapon_platform(category, weapon, freeSlot, true)

		if mods ~= nil then

			-- Keep track of mods we can't equip
			local banned_mods = {}

			-- Attach mods
			for k, v in pairs(mods) do
				local factory = tweak_data.weapon.factory.parts[v]
				if factory then

					-- Attach weapons for DLC we own, add it to the inventory for mods we dont
					if factory.dlc ~= nil and not managers.dlc:has_dlc(factory.dlc) then
						banned_mods[v] = factory.dlc
						managers.blackmarket:add_to_inventory(factory.dlc, "weapon_mods", v, true)
					else
						managers.blackmarket:buy_and_modify_weapon(category, freeSlot, "normal", v, true, true)
					end

				end
			end

			-- Warn us about mods we can't use
			for k, v in pairs(banned_mods) do
				Trading:ShowModDLCNotOwned(tweak_data.weapon.factory.parts[k].name_id, tweak_data.weapon.factory.parts[k].dlc)
			end

		end

	end

end

function Trading:ShowModDLCNotOwned(mod, dlc)

	mod = managers.localization:text(mod)
	dlc = Trading.DLCNames[dlc] or ("error: " .. dlc)

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_WeaponModRemovedDLC")
	message = message:gsub("{1}", mod)
	message = message:gsub("{2}", dlc)
	local menuOptions = {}
	menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

function Trading:RemoveWeaponFromInventory()

	local category = Trading.TradeData.Slot.category
	local slot = Trading.TradeData.Slot.slot
	local remove_mods = not Trading.TradeData.SendWeaponMods

	-- Remove weapon and mods
	local success, err = pcall(function()
		managers.blackmarket:on_traded_weapon(category, slot, remove_mods)
	end)
	if not success then Print(err) end

	-- Reload gui
	if Trading.BlackMarketGUI ~= nil then
		Trading.BlackMarketGUI:reload()
	end

end

function Trading:RemoveModFromInventory()

	managers.blackmarket:on_traded_mod(Trading.TradeData.RawData.slot.name)

end

function Trading:AddTradedModToInventory()

	local success, err = pcall(function()

	local mod = Trading.TradeData.WeaponMod

	-- Show message about mod
	local factory = tweak_data.weapon.factory.parts[mod]
	if factory then

		local mod_name = managers.localization:text(factory.name_id)
		local ply_name = GoonBase.Network:GetNameFromPeerID(Trading.TradeData.Trader)

		-- Attach weapons for DLC we own, add it to the inventory for mods we dont
		if factory.dlc ~= nil and not managers.dlc:has_dlc(factory.dlc) then

			local dlc_name = Trading.DLCNames[factory.dlc] or ("error: " .. factory.dlc)

			-- DLC is not owned, show different message
			local title = managers.localization:text("Trading_TradeWindowTitle")
			local message = managers.localization:text("Trading_WeaponModReceivedNoDLC")
			message = message:gsub("{1}", mod_name)
			message = message:gsub("{2}", ply_name)
			message = message:gsub("{3}", dlc_name)
			local menuOptions = {}
			menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
			local tradeMenu = SimpleMenu:New(title, message, menuOptions)
			tradeMenu:Show()

		else

			-- Show default message
			local title = managers.localization:text("Trading_TradeWindowTitle")
			local message = managers.localization:text("Trading_WeaponModReceived")
			message = message:gsub("{1}", mod_name)
			message = message:gsub("{2}", ply_name)
			local menuOptions = {}
			menuOptions[1] = { text = managers.localization:text("Trading_TradeWindowOk"), is_cancel_button = true }
			local tradeMenu = SimpleMenu:New(title, message, menuOptions)
			tradeMenu:Show()

		end

	end

	-- Add mod to inventory
	managers.blackmarket:on_received_traded_mod( Trading.TradeData.WeaponMod )

	end)
	if not success then Print(err) end

end

function Trading:AddTradedMaskToInventory()

	local success, err = pcall(function()

	local mask_id = Trading.TradeData.Mask

	if Trading.TradeData.MaskMods ~= nil then

		-- Adding mods to mask
		local material = Trading.TradeData.MaskMods.Material
		local pattern = Trading.TradeData.MaskMods.Pattern
		local color = Trading.TradeData.MaskMods.Colour

		-- Check if user has all DLC for mask
		local dlc_check = managers.blackmarket:has_all_dlc_for_mask_and_parts(mask_id, material, pattern, color)
		if type(dlc_check) == "table" then

			-- User doesn't have all DLC, add items to inventory instead
			managers.blackmarket:add_traded_mask_to_inventory(mask_id)
			managers.blackmarket:add_traded_mask_part_to_inventory(material, Trading.Categories.MaskMaterial)
			managers.blackmarket:add_traded_mask_part_to_inventory(pattern, Trading.Categories.MaskPattern)
			managers.blackmarket:add_traded_mask_part_to_inventory(color, Trading.Categories.MaskColour)

			-- Localization strings
			local mask_name = managers.blackmarket:get_mask_name( Trading.TradeData.Mask )
			local player_name = GoonBase.Network:GetNameFromPeerID( Trading.TradeData.Trader )
			local missing_dlcs = ""

			-- Show DLC warning
			for k, v in pairs( dlc_check ) do
				if missing_dlcs ~= "" then
					missing_dlcs = missing_dlcs .. ", or "
				end
				missing_dlcs = (missing_dlcs .. "'{1}'"):gsub("{1}", Trading.DLCNames[k] or k)
			end
			Trading:ShowMaskTradeDLCWarning(mask_name, player_name, missing_dlcs)

			return
		end

		-- Add modded mask to inventory
		managers.blackmarket:add_traded_modded_mask_to_free_slot(mask_id, material, pattern, color)

	else

		-- Only sending mask, add to inventory
		managers.blackmarket:add_traded_mask_to_inventory(mask_id)

		-- Check player owns DLC
		local missing_dlc = managers.blackmarket:has_all_dlc_for_mask(mask_id)
		if type(missing_dlc) == "string" then
			local mask_name = managers.blackmarket:get_mask_name( Trading.TradeData.Mask )
			local player_name = GoonBase.Network:GetNameFromPeerID( Trading.TradeData.Trader )
			local dlc_name = ("'{1}'"):gsub("{1}", Trading.DLCNames[missing_dlc] or missing_dlc)
			Trading:ShowMaskTradeDLCWarning(mask_name, player_name, dlc_name)
		end

	end

	end)
	if not success then Print(err) end

end

function Trading:AddTradedMaskModToInventory()

	local success, err = pcall(function()

		-- Get mod ID and check mod is valid
		local mod_id = nil
		local category = Trading.TradeData.Category

		if category == Trading.Categories.MaskMaterial then
			mod_id = Trading.TradeData.MaskMods.Material
		end
		if category == Trading.Categories.MaskPattern then
			mod_id = Trading.TradeData.MaskMods.Pattern
		end
		if category == Trading.Categories.MaskColour then
			mod_id = Trading.TradeData.MaskMods.Colour
		end
		if mod_id == nil then
			return
		end

		-- Add mod to inventory
		managers.blackmarket:add_traded_mask_part_to_inventory(mod_id, category)

		-- Warn about DLC
		local missing_dlc = managers.blackmarket:has_all_dlc_for_mask_mod(mod_id, category)
		if type(missing_dlc) == "string" then
			local mod_name = managers.blackmarket:get_mask_mod_name( mod_id, category )
			local player_name = GoonBase.Network:GetNameFromPeerID( Trading.TradeData.Trader )
			local dlc_name = ("'{1}'"):gsub("{1}", Trading.DLCNames[missing_dlc] or missing_dlc)
			Trading:ShowMaskTradeDLCWarning(mod_name, player_name, dlc_name)
		end

	end)
	if not success then Print(err) end

end

function Trading:ShowMaskTradeDLCWarning(mask_name, player_name, missing_dlcs)

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_MaskReceivedNoDLC")
	message = message:gsub("{1}", mask_name)
	message = message:gsub("{2}", player_name)
	message = message:gsub("{3}", missing_dlcs)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_MaskReceivedAccept"),
		is_cancel_button = true
	}
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

function Trading:VerifyMaskTradability(data)

	-- Items which are untradable
	local untradable = nil

	-- Check mask itself is fine to trade
	local mask_data = managers.blackmarket:get_mask_data( data.mask_id )
	if mask_data == nil then
		return
	end
	if mask_data.dlc ~= nil and mask_data.value == 0 then
		if untradable == nil then untradable = {} end
		untradable["masks"] = data.mask_id
	end

	-- Check mask components are ok
	if data.blueprint ~= nil then

		-- Material
		local material_data = managers.blackmarket:get_mask_mod_data( data.blueprint.material.id, Trading.Categories.MaskMaterial )
		if material_data ~= nil and material_data.dlc ~= nil and material_data.value == 0 then
			if untradable == nil then untradable = {} end
			untradable["materials"] = data.blueprint.material.id
		end

		-- Pattern
		local pattern_data = managers.blackmarket:get_mask_mod_data( data.blueprint.pattern.id, Trading.Categories.MaskPattern )
		if pattern_data ~= nil and pattern_data.dlc ~= nil and pattern_data.value == 0 then
			if untradable == nil then untradable = {} end
			untradable["textures"] = data.blueprint.pattern.id
		end

		-- Colour
		local color_data = managers.blackmarket:get_mask_mod_data( data.blueprint.color.id, Trading.Categories.MaskColour )
		if color_data ~= nil and color_data.dlc ~= nil and color_data.value == 0 then
			if untradable == nil then untradable = {} end
			untradable["colors"] = data.blueprint.color.id
		end

	end

	-- Show untradables
	if untradable ~= nil then
		Trading:ShowMaskTradabilityMessage(managers.blackmarket:get_mask_name(data.mask_id), untradable)
		return false
	end

	-- Mask is clear, good to trade
	return true

end

function Trading:VerifyMaskModTradability(mod, category)

	local mod_data = managers.blackmarket:get_mask_mod_data( mod.name, mod.category )
	if mod_data ~= nil and mod_data.dlc ~= nil and mod_data.value == 0 then
		Trading:ShowMaskModTradabilityMessage(mod.name_localized)
		return false
	end
	return true

end

function Trading:ShowMaskTradabilityMessage(mask_name, items)

	local item_names = ""
	for k, v in pairs( items ) do
		if item_names ~= "" then
			item_names = item_names .. ", and "
		end
		item_names = (item_names .. "'{1}'"):gsub("{1}", managers.blackmarket:get_mask_mod_name(v, k))
	end

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_UntradableMask")
	message = message:gsub("{1}", mask_name)
	message = message:gsub("{2}", item_names)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_UntradableMaskAccept"),
		is_cancel_button = true
	}
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

function Trading:ShowMaskModTradabilityMessage(mod_name)

	local title = managers.localization:text("Trading_TradeWindowTitle")
	local message = managers.localization:text("Trading_UntradableMaskMod")
	message = message:gsub("{1}", mod_name)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Trading_UntradableMaskModAccept"),
		is_cancel_button = true
	}
	local tradeMenu = SimpleMenu:New(title, message, menuOptions)
	tradeMenu:Show()

end

-- END OF FILE
