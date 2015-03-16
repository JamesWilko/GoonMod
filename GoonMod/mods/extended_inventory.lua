
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "ExtendedInventory"
Mod.Name = "Extended Inventory"
Mod.Desc = "Allows mods to add special items to your inventory"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Extended Inventory
_G.GoonBase.ExtendedInventory = _G.GoonBase.ExtendedInventory or {}
local ExtendedInv = _G.GoonBase.ExtendedInventory
ExtendedInv.InitialLoadComplete = false
ExtendedInv.RegisteredItems = {}
ExtendedInv.SaveFile = SavePath .. "goonmod_inventory.txt"
ExtendedInv.OldFormatSaveFile = SavePath .. "inventory.ini"

ExtendedInv.Items = {}
ExtendedInv.RedeemedCodes = {}

ExtendedInv.APIRedeem = "http://api.paydaymods.com/goonmod/redeem/{1}"
ExtendedInv.APIRedeemInfo = "http://api.paydaymods.com/goonmod/redeem_info/{1}"

-- Menu Layout
local redeem_max_items_w = 5
local item_padding = 8
local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

-- Initialize
Hooks:RegisterHook("ExtendedInventoryInitialized")
Hooks:Add("GoonBasePostLoadedMods", "GoonBasePostLoadedMods_ExtendedInv", function()
	Hooks:Call("ExtendedInventoryInitialized")
end)

-- Functions
function ExtendedInv:_MissingItemError(item)
	Print("[Error] Could not find item '" .. item .. "' in Extended Inventory!")
end

function ExtendedInv:ItemIsRegistered(id)
	return ExtendedInv.RegisteredItems[id] == true
end

function ExtendedInv:RegisterItem(data)

	if not ExtendedInv.InitialLoadComplete then
		ExtendedInv:Load()
		ExtendedInv.InitialLoadComplete = true
	end

	ExtendedInv.RegisteredItems[data.id] = true
	ExtendedInv.Items[data.id] = ExtendedInv.Items[data.id] or {}
	for k, v in pairs( data ) do
		ExtendedInv.Items[data.id][k] = v
	end
	ExtendedInv.Items[data.id].amount = ExtendedInv.Items[data.id].amount or 0

end

function ExtendedInv:AddItem(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = ExtendedInv.Items[item].amount + amount
		ExtendedInv:Save()
	else
		ExtendedInv:_MissingItemError(item)
	end
end

function ExtendedInv:TakeItem(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = ExtendedInv.Items[item].amount - amount
		ExtendedInv:Save()
	else
		ExtendedInv:_MissingItemError(item)
	end
end

function ExtendedInv:SetItemAmount(item, amount)
	if ExtendedInv.Items[item] ~= nil then
		ExtendedInv.Items[item].amount = amount
		ExtendedInv:Save()
	else
		ExtendedInv:_MissingItemError(item)
	end
end


function ExtendedInv:GetItem(item)
	return ExtendedInv.Items[item] or nil
end

function ExtendedInv:HasItem(item)
	if ExtendedInv.Items[item] == nil then
		return false
	end
	return ExtendedInv.Items[item].amount > 0 or nil
end

function ExtendedInv:GetAllItems()
	return ExtendedInv.Items
end

function ExtendedInv:GetReserveText(item)
	return item.reserve_text or managers.localization:text("bm_ex_inv_in_reserve")
end

-- Code Redemption
function ExtendedInv:GetDisplayDataForItem( data )

	local category = data.category
	local name = data.item

	if category == "extended_inv" then
		local item_data = self:GetItem( name )
		return managers.localization:text(item_data.name), item_data.texture
	end

	local item_data = tweak_data.blackmarket[category][name]
	if not item_data then
		return nil, nil
	end

	if category == "masks" then
		local guis_catalog = "guis/"
		local bundle_folder = item_data.texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end
		local bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. name
		return managers.localization:text(item_data.name_id), bitmap_texture
	end

end

function ExtendedInv:HasUsedCode( code )
	for k, v in pairs( ExtendedInv.RedeemedCodes ) do
		if v == code then
			return true
		end
	end
	return false
end

function ExtendedInv:_ShowCodeRedeemWindow()

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_window_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_window_message")
	dialog_data.id = "ex_inv_redeem_window"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeem_window_accept")

	dialog_data.button_list = {ok_button}
	managers.system_menu:show_redeem_code_window( dialog_data )

end

function ExtendedInv:EnteredRedeemCode( code )

	if code:is_nil_or_empty() then
		return
	end

	self._code_to_redeem = code
	self:ShowContactingServerWindow()

	local api_url = ExtendedInv.APIRedeemInfo:gsub( "{1}", code:lower() )
	dohttpreq( api_url, function(data, id) self:RetrievedServerData( data, id ) end )

end

function ExtendedInv:RetrievedServerData( data, id )

	managers.system_menu:close("ex_inv_redeem_attempt")

	if data:is_nil_or_empty() then
		self:ShowFailedToContactServerWindow()
		return
	end

	local code_data = json.decode( data )
	if code_data.success then
		if not self:HasUsedCode( code_data.code ) then
			self:ShowRedeemInfoWindow( code_data.data )
		else
			self:ShowCodeRedeemFailureWindow( "already_used" )
		end
	else
		self:ShowCodeRedeemFailureWindow( code_data.code )
	end

end

function ExtendedInv:ShowContactingServerWindow()
	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_contact_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_contact_message")
	dialog_data.id = "ex_inv_redeem_attempt"
	dialog_data.no_buttons = true
	dialog_data.indicator = true
	managers.system_menu:show(dialog_data)
end

function ExtendedInv:ShowFailedToContactServerWindow()
	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_contact_failed_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_contact_failed_message")
	dialog_data.id = "ex_inv_redeem_failed"
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)
end

function ExtendedInv:ShowCodeRedeemFailureWindow( error )

	local errors = {
		["not_found"] = "gm_ex_inv_redeem_invalid_not_found",
		["no_uses_remaining"] = "gm_ex_inv_redeem_invalid_no_uses_left",
		["already_used"] = "gm_ex_inv_redeem_invalid_already_used"
	}

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_invalid_title")
	dialog_data.text = managers.localization:text( errors[error] )
	dialog_data.id = "ex_inv_redeem_failed"
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)

end

function ExtendedInv:ShowRedeemInfoWindow( data )
		
	data = json.decode( data )

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeem_info_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeem_info_message")
	dialog_data.id = "ex_inv_redeem_attempt"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeem_info_accept")
	ok_button.callback_func = callback(self, self, "RedeemCode")

	local cancel_button = {}
	cancel_button.text = managers.localization:text("gm_ex_inv_redeem_info_cancel")
	cancel_button.cancel_button = true

	dialog_data.button_list = {ok_button, cancel_button}
	dialog_data.items = data
	managers.system_menu:show_redeem_code_items_window( dialog_data )

end

function ExtendedInv:RedeemCode()

	if not self._code_to_redeem then
		return
	end

	local code = self._code_to_redeem
	self._code_to_redeem = nil

	self:ShowContactingServerWindow()

	local api_url = ExtendedInv.APIRedeem:gsub( "{1}", code:lower() )
	dohttpreq( api_url, function(data, id) self:RedeemedCode( data, id ) end )

end

function ExtendedInv:RedeemedCode( data, id )

	managers.system_menu:close("ex_inv_redeem_attempt")

	if data:is_nil_or_empty() then
		self:ShowFailedToContactServerWindow()
		return
	end

	local code_data = json.decode( data )
	code_data.data = json.decode( code_data.data )

	if code_data.success then

		table.insert( ExtendedInv.RedeemedCodes, code_data.code )
		self:Save()

		self:AddRedeemedItemsToInventory( code_data.data )
		self:ShowRedeemedCodeWindow( code_data.data )

	else
		self:ShowCodeRedeemFailureWindow( code_data.code )
	end

end

function ExtendedInv:ShowRedeemedCodeWindow( data )

	local dialog_data = {}
	dialog_data.title = managers.localization:text("gm_ex_inv_redeemed_confirm_title")
	dialog_data.text = managers.localization:text("gm_ex_inv_redeemed_confirm_message")
	dialog_data.id = "ex_inv_redeemed_items"

	local ok_button = {}
	ok_button.text = managers.localization:text("gm_ex_inv_redeemed_confirm_accept")
	ok_button.cancel_button = true

	dialog_data.button_list = {ok_button}
	dialog_data.items = data
	managers.system_menu:show_redeem_code_items_window( dialog_data )

end

function ExtendedInv:AddRedeemedItemsToInventory( data )

	PrintTable( data )

	for k, v in pairs( data ) do

		local name = v.item
		local category = v.category
		local quantity = v.quantity

		if category == "extended_inv" then
			self:AddItem(name, quantity)
		else

			local entry = tweak_data:get_raw_value("blackmarket", category, name)
			if entry then
				for i = 1, quantity or 1 do
					local global_value = entry.infamous and "infamous" or entry.global_value or entry.dlc or entry.dlcs and entry.dlcs[math.random(#entry.dlcs)] or "normal"
					managers.blackmarket:add_to_inventory(global_value, category, name)
				end
			end

		end

	end

end

-- Hooks
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup_ExtendedInventory", function(gui, is_start_page, component_data)
	gui.identifiers.extended_inv = Idstring("extended_inv")
end)

function ExtendedInv.do_populate_extended_inventory(self, data)

	local new_data = {}
	local guis_catalog = "guis/"
	local index = 0

	for i, item_data in pairs( ExtendedInv:GetAllItems() ) do

		local hide = item_data.hide_when_none_in_stock or false
		if ExtendedInv:ItemIsRegistered(i) and (hide == false or (hide == true and item_data.amount > 0)) then

			local item_id = item_data.id
			local name_id = item_data.name
			local desc_id = item_data.desc
			local texture_id = item_data.texture

			index = index + 1
			new_data = {}
			new_data.name = item_id
			new_data.name_localized = managers.localization:text( name_id )
			new_data.desc_localized = managers.localization:text( desc_id )
			new_data.category = "extended_inv"
			new_data.slot = index
			new_data.amount = item_data.amount
			new_data.unlocked = (new_data.amount or 0) > 0
			new_data.level = item_data.level or 0
			new_data.skill_based = new_data.level == 0
			new_data.skill_name = new_data.level == 0 and "bm_menu_skill_locked_" .. new_data.name
			new_data.bitmap_texture = texture_id
			new_data.lock_texture = self:get_lock_icon(new_data)
			data[index] = new_data

		end

	end

	-- Fill empty slots
	local max_items = data.override_slots[1] * data.override_slots[2]
	for i = 1, max_items do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.desc_localized = ""
			new_data.category = "extended_inv"
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end
	end

end

Hooks:Add("BlackMarketGUIStartPageData", "BlackMarketGUIStartPageData_ExtendedInventory", function(gui, data)

	local should_hide_tab = true
	for k, v in pairs( ExtendedInv:GetAllItems() ) do
		if v.hide_when_none_in_stock == false or (v.hide_when_none_in_stock == true and v.amount > 0) then
			should_hide_tab = false
		end
	end
	if should_hide_tab then
		return
	end

	gui.populate_extended_inventory = ExtendedInv.do_populate_extended_inventory

	table.insert(data, {
		name = "bm_menu_extended_inv",
		category = "extended_inv",
		on_create_func_name = "populate_extended_inventory",
		identifier = gui.identifiers.extended_inv,
		override_slots = {5, 2},
		start_crafted_item = 1
	})

end)

Hooks:Add("BlackMarketGUIUpdateInfoText", "BlackMarketGUIUpdateInfoText_ExtendedInventory", function(gui)

	local self = gui
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	local updated_texts = {
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""},
		{text = ""}
	}
	
	if ids_category == self.identifiers.extended_inv then

		updated_texts[1].text = slot_data.name_localized or ""
		updated_texts[2].text = tostring(slot_data.amount or 0) .. " " .. ExtendedInv:GetReserveText(slot_data.name)
		updated_texts[4].text = slot_data.desc_localized or ""

		gui:_update_info_text(slot_data, updated_texts)

	end

end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function(menu_manager, menu_nodes)

	-- Menu
	MenuCallbackHandler.extended_inv_open_redeem_code = function(this, item)
		ExtendedInv:_ShowCodeRedeemWindow()
	end

	MenuHelper:AddDivider({
		id = "gm_ex_inv_divider",
		menu_id = "goonbase_options_menu",
		size = 16,
		priority = -99,
	})

	MenuHelper:AddButton({
		id = "gm_ex_inv_redeem_button",
		title = "gm_ex_inv_redeem_code",
		desc = "gm_ex_inv_redeem_code_desc",
		callback = "extended_inv_open_redeem_code",
		menu_id = "goonbase_options_menu",
		priority = -100,
	})

end)

Hooks:Add("GenericSystemMenuManagerPostInit", "GenericSystemMenuManagerPostInit_" .. Mod:ID(), function( menu_manager )

	local dialog_path = GoonBase.Path .. "dialogs/"
	dofile( dialog_path .. "RedeemCodeDialog.lua" )
	dofile( dialog_path .. "RedeemCodeItemsDialog.lua" )

	SystemMenuManager.GenericSystemMenuManager.GENERIC_REDEEM_CODE_DIALOG = SystemMenuManager.RedeemCodeDialog
	SystemMenuManager.GenericSystemMenuManager.REDEEM_CODE_CLASS = SystemMenuManager.RedeemCodeDialog

	SystemMenuManager.GenericSystemMenuManager.GENERIC_REDEEM_CODE_ITEMS_DIALOG = SystemMenuManager.RedeemCodeItemsDialog
	SystemMenuManager.GenericSystemMenuManager.REDEEM_CODE_ITEMS_CLASS = SystemMenuManager.RedeemCodeItemsDialog

	SystemMenuManager.GenericSystemMenuManager.show_redeem_code_window = function( self, data )
		local success = self:_show_class(data, self.GENERIC_REDEEM_CODE_DIALOG, self.REDEEM_CODE_CLASS, data.force)
		self:_show_result(success, data)
	end

	SystemMenuManager.GenericSystemMenuManager.show_redeem_code_items_window = function( self, data )
		local success = self:_show_class(data, self.GENERIC_REDEEM_CODE_ITEMS_DIALOG, self.REDEEM_CODE_ITEMS_CLASS, data.force)
		self:_show_result(success, data)
	end

end)

-- Saving and Loading
function ExtendedInv:Save( file_name )

	if file_name == nil then
		file_name = ExtendedInv.SaveFile
	end

	local save_data = {
		["items"] = ExtendedInv.Items,
		["codes"] = ExtendedInv.RedeemedCodes,
	}
	if #ExtendedInv.RedeemedCodes < 1 then
		save_data["codes"] = nil
	end

	local file = io.open(file_name, "w+")
	local data = json.encode( save_data )
	data = GoonBase.Utils.Base64:Encode( data )
	file:write( data )
	file:close()

end

function ExtendedInv:Load( file_name )

	file_name = file_name or ExtendedInv.SaveFile
	local file = io.open(file_name, "r")
	if not file then
		Print( "Could not open GoonMod Extended Inventory save file, attempting to load old format..." )
		if ExtendedInv:LoadOldFormat() then
			self:Save()
		end
		return 
	end

	local file_data = file:read("*all")
	file_data = GoonBase.Utils.Base64:Decode( file_data )
	local loaded_data = json.decode( file_data )
	ExtendedInv.Items = loaded_data["items"] or {}
	ExtendedInv.RedeemedCodes = loaded_data["codes"] or {}

end

function ExtendedInv:LoadOldFormat( file_name )

	file_name = file_name or ExtendedInv.OldFormatSaveFile

	local file = io.open(file_name, 'r')

	if not file then
		Print( "Could not open old format save file (" .. file_name .. ")! Does it exist?" )
		return false
	end

	local key
	local fileString = ""
	for line in file:lines() do
		fileString = fileString .. line .. "\n"
	end
	fileString = GoonBase.Utils.Base64:Decode( fileString )

	local fileLines = string.split(fileString, "[\n]")
	for i, line in pairs( fileLines ) do

		local loadKey = line:match('^%[([^%[%]]+)%]$')
		if loadKey then
			key = tonumber(loadKey) and tonumber(loadKey) or loadKey
			ExtendedInv.Items[key] = ExtendedInv.Items[key] or {}
		end

		local param, val = line:match('^([%w|_]+)%s-=%s-(.+)$')
		if param and val ~= nil then

			if tonumber(val) then
				val = tonumber(val)
			elseif val == "true" then
				val = true
			elseif val == "false" then
				val = false
			end

			if tonumber(param) then
				param = tonumber(param)
			end

			ExtendedInv.Items[key][param] = val

		end

	end

	file:close()
	return true

end
