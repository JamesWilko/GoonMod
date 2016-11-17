
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "MaskModSearch"
Mod.Name = "Search Bar for Mask Customization"
Mod.Desc = "Adds a search bar to the mask customization screen"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Search Mod
_G.GoonBase.MaskModsSearch = _G.GoonBase.MaskModsSearch or {}
_G.GoonBase.MaskModsSearch._stored_data = {}

function GoonBase.MaskModsSearch:IsMaskMod(category)
	return category == "materials" or category == "textures" or category == "colors"
end

function GoonBase.MaskModsSearch:AttemptToRestoreData(data)
	if self._stored_data[data.category] then
		for k, v in pairs( self._stored_data[data.category] ) do
			if v ~= nil then
				data[k] = v
			end
		end
		self._stored_data[data.category] = nil
	end
end

-- Search Bar Class
BlackmarketSearchBar = BlackmarketSearchBar or class()
function BlackmarketSearchBar:init( parent, parent_panel )

	local search_height = 32
	local search_padding = 2
	local padding = 6
	local info_box_panel = parent_panel:child("info_box_panel")
	self._blackmarket = parent
	self._parent = parent_panel

	self._enabled = false
	self._selected = false

	self._current_search = ""
	self._search_text = ""

	-- Create search panel
	self._search_panel = self._parent:panel({
		x = info_box_panel:x(),
		y = info_box_panel:y() - search_height - search_padding,
		w = info_box_panel:w(),
		h = search_height,
		layer = 1,
		alpha = 1
	})

	self._search_panel_hightlight = self._search_panel:rect({
		x = search_padding,
		y = search_padding,
		w = self._search_panel:w() - search_padding * 2,
		h = self._search_panel:h() - search_padding * 2,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0,
		layer = 0,
	})

	self._search_panel_box = BoxGuiObject:new(self._search_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._search_panel_label = self._search_panel:text({
		name = "search_label",
		x = padding,
		y = padding,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		layer = 2,
		color = tweak_data.screen_colors.text,
		alpha = 0.6,
		text = managers.localization:to_upper_text("gm_bm_search")
	})
	BlackMarketGui:make_fine_text(self._search_panel_label)

	self._search_cancel_label = self._search_panel:text({
		name = "search_cancel_label",
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		layer = 2,
		color = tweak_data.screen_colors.text,
		text = "X",
		alpha = 0
	})
	BlackMarketGui:make_fine_text(self._search_cancel_label)
	local tx, ty, tw, th = self._search_cancel_label:text_rect()
	self._search_cancel_label:set_position(self._search_panel:w() - padding * 2 - tw, padding)

	self._search_cancel_highlight = self._search_panel:rect({
		x = self._search_cancel_label:x() - 8,
		y = self._search_cancel_label:y() - 2,
		w = self._search_cancel_label:w() + 16,
		h = self._search_cancel_label:h() + 4,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0,
		layer = 0,
	})

	self:set_enabled( self._enabled )

end

function BlackmarketSearchBar:set_enabled( enable )
	self._enabled = enable
	self._search_panel:set_alpha( self._enabled and 1 or 0 )
end

function BlackmarketSearchBar:inside(x, y)
	return self._search_panel:inside(x, y)
end

function BlackmarketSearchBar:inside_cancel_button(x, y)
	if self._search_cancel_label:alpha() < 0.1 then
		return false
	end
	return self._search_cancel_label:inside(x, y)
end

function BlackmarketSearchBar:set_highlight( highlight )
	if self._enabled and self._highlighted ~= highlight then
		self._highlighted = highlight
		if highlight then
			managers.menu_component:post_event("highlight")
			self._search_panel_hightlight:set_alpha(0.3)
		else
			self._search_panel_hightlight:set_alpha(0)
		end
	end
end

function BlackmarketSearchBar:set_cancel_highlight( highlight )
	if self._enabled and self._cancel_highlighted ~= highlight then
		self._cancel_highlighted = highlight
		if highlight then
			managers.menu_component:post_event("highlight")
			self._search_cancel_highlight:set_alpha(0.3)
		else
			self._search_cancel_highlight:set_alpha(0)
		end
	end
end

function BlackmarketSearchBar:is_typing()
	return self._selected
end

function BlackmarketSearchBar:start_typing()
	if not self._enabled or self._selected then
		return
	end
	self._selected = true
	self._blackmarket._ws:connect_keyboard(Input:keyboard())
	self._blackmarket._panel:enter_text(callback(self, self, "enter_text"))
	self._blackmarket._panel:key_press(callback(self, self, "key_press"))
end

function BlackmarketSearchBar:stop_typing()
	if not self._enabled or not self._selected then
		return
	end
	self._selected = false
	self._blackmarket._ws:disconnect_keyboard()
	self._blackmarket._panel:enter_text(nil)
	self._blackmarket._panel:key_press(nil)
end

function BlackmarketSearchBar:clear_search()
	self._current_search = ""
	self._search_text = ""
	self:update_text()
	self:reload_blackmarket()
end

function BlackmarketSearchBar:do_search()
	if not self._enabled or not self._selected then
		return
	end
	self._current_search = self._search_text

	self._blackmarket._ws:disconnect_keyboard()
	self._blackmarket._panel:enter_text(nil)
	self._blackmarket._panel:key_press(nil)

	self._search_panel:animate(callback(self, self, "__stop_search"))

	managers.menu_component:post_event("menu_enter")
	self:reload_blackmarket()
end

function BlackmarketSearchBar:reload_blackmarket()
	local blackmarket_gui = managers.menu_component._blackmarket_gui
	if blackmarket_gui then
		blackmarket_gui.__block_enter = true
		blackmarket_gui:reload()
	end
end

function BlackmarketSearchBar:__stop_search()
	wait(5.0)
	self._selected = false
	self._search_panel:stop()
end

function BlackmarketSearchBar:cancel_typing()
	self:stop_typing()
	self._search_text = self._current_search
end

function BlackmarketSearchBar:enter_text(o, s)
	if not self._selected then
		return
	end
	self._search_text = self._search_text .. tostring(s)
	self._search_text = self._search_text:lower()
	self:update_text()
end

function BlackmarketSearchBar:key_press(o, k)
	if not self._selected then
		return
	end
	if k == Idstring("enter") then
		self:do_search()
		return
	end
	if k == Idstring("backspace") then
		local n = utf8.len(self._search_text)
		self._search_text = utf8.sub(self._search_text, 0, math.max(n - 1, 0))
	end
	self:update_text()
end

function BlackmarketSearchBar:has_search()
	return self._current_search ~= ""
end

function BlackmarketSearchBar:get_current_search()
	return self._current_search
end

function BlackmarketSearchBar:set_search_text( text )
	self._search_text = text
	self._current_search = text
	self:update_text()
end

function BlackmarketSearchBar:update_text()
	if self._search_text ~= "" then
		self._search_panel_label:set_text(string.upper(self._search_text))
		self._search_panel_label:set_alpha(1)
		self._search_cancel_label:set_alpha(1)
		BlackMarketGui:make_fine_text(self._search_panel_label)
	else
		self._search_panel_label:set_text(managers.localization:to_upper_text("gm_bm_search"))
		self._search_panel_label:set_alpha(0.6)
		self._search_cancel_label:set_alpha(0)
		BlackMarketGui:make_fine_text(self._search_panel_label)
	end
end

-- Hooks
Hooks:Add("BlackMarketGUIPostSetup", "BlackMarketGUIPostSetup." .. Mod.id, function(gui, is_start_page, component_data)

	local current_search = nil
	if gui._search_bar then
		current_search = gui._search_bar:get_current_search()
	end

	gui._search_bar = BlackmarketSearchBar:new( gui, gui._panel )
	if current_search then
		gui._search_bar:set_search_text(current_search)
	end

	if component_data and component_data[1] and component_data[1][1] then
		local item = component_data[1][1]
		if GoonBase.MaskModsSearch:IsMaskMod(item.category) then
			gui._search_bar:set_enabled(true)
		else
			gui._search_bar:set_enabled(false)
		end
	else
		gui._search_bar:set_enabled(false)
	end

end)

Hooks:Add("BlackMarketGUIOnMouseMoved", "BlackMarketGUIOnMouseMoved." .. Mod.id, function(gui, o, x, y)

	local search = gui._search_bar
	if search:inside(x, y) then
		if search:inside_cancel_button(x, y) then
			search:set_highlight( false )
			search:set_cancel_highlight( true )
		else
			search:set_highlight( true )
			search:set_cancel_highlight( false )
		end
	else
		search:set_highlight( false )
	end

end)

Hooks:Add("BlackMarketGUIOnMousePressed", "BlackMarketGUIOnMousePressed." .. Mod.id, function(gui, button, x, y)

	local search = gui._search_bar
	if search:inside(x, y) then
		if search:inside_cancel_button(x, y) then
			search:clear_search()
		else
			search:start_typing()
		end
		managers.menu_component:post_event("menu_enter")
	else
		search:stop_typing()
	end

end)

Hooks:Add("BlackMarketGUIOnPressFirstButton", "BlackMarketGUIOnPressFirstButton." .. Mod.id, function(gui, button)
	if gui.__block_enter then
		gui.__block_enter = false
		return true
	end
end)

-- Populate mods list with search results
Hooks:Add("BlackMarketGUIOnPopulateMaskMods", "BlackMarketGUIOnPopulateMaskMods_" .. Mod.id, function(gui, data)

	local blackmarket_gui = managers.menu_component._blackmarket_gui
	if blackmarket_gui and blackmarket_gui._search_bar and blackmarket_gui._search_bar:has_search() then

		-- Store data so we can retrieve it after cancelling a search
		if not GoonBase.MaskModsSearch._stored_data[data.category] then
			GoonBase.MaskModsSearch._stored_data[data.category] = CoreTable.deep_clone(data)
		end
		
		local search_term = string.lower( blackmarket_gui._search_bar:get_current_search() )
		local clear_items = {}

		-- Clear all mods which do not contain the search term
		for i, mods in pairs(data.on_create_data) do

			-- Search for name match
			local name_id = tweak_data.blackmarket[data.category][mods.id].name_id
			local loc_name = string.lower( managers.localization:text(name_id) )
			local found_name = string.find(loc_name, search_term) ~= nil

			-- Search for dlc name match
			local found_gv = false
			if mods.global_value ~= "normal" then
				local gv_tweak = tweak_data.lootdrop.global_values[mods.global_value]
				local gv_name = string.lower( managers.localization:text(gv_tweak.name_id) )
				found_gv = string.find(gv_name, search_term) ~= nil
			end

			-- Flag items which are not included to be removed
			if not found_name and not found_gv then
				table.insert( clear_items, i )
			end

		end

		-- Check if we found anything that matches
		if #clear_items == #data.on_create_data then
			GoonBase.MaskModsSearch:AttemptToRestoreData(data)
			return
		end

		-- Found something, so trim the data to the search results
		for _, i in ipairs( clear_items ) do
			data[i] = nil
			data.on_create_data[i] = nil
		end

		-- Keep references to the data so we can sort it
		local mod_data = {}
		local mod_on_create_data = {}
		local count = 1

		-- Sort mods into order and remove the old references in the table
		-- We use a separate table so that if the index and current count match up we don't overwrite anything and lose data
		for i, mod in pairs(data) do
			if type(mod) == "table" and mod.slot and GoonBase.MaskModsSearch:IsMaskMod(mod.category) then
				mod.slot = count
				table.insert( mod_data, mod )
				table.insert( mod_on_create_data, data.on_create_data[i] )
				data[i] = nil
				data.on_create_data[i] = nil
				count = count + 1
			end
		end

		-- Reorder table so that we begin from the first cell and don't have to scroll through a ton of empty cells
		for i, mod in pairs(mod_data) do
			data[i] = mod
			data.on_create_data[i] = mod_on_create_data[i]
		end

	else
		-- Load stored data
		GoonBase.MaskModsSearch:AttemptToRestoreData(data)
	end

end)

-- Block special action keys while typing
Hooks:Add("BlackMarketGUIOnMoveUp", "BlackMarketGUIOnMoveUp." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnMoveDown", "BlackMarketGUIOnMoveDown." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnMoveLeft", "BlackMarketGUIOnMoveLeft." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnMoveRight", "BlackMarketGUIOnMoveRight." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnNextPage", "BlackMarketGUIOnNextPage." .. Mod.id, function(gui, no_sound)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnPreviousPage", "BlackMarketGUIOnPreviousPage." .. Mod.id, function(gui, no_sound)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnPressButton", "BlackMarketGUIOnPressButton." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnPressedSpecialButton", "BlackMarketGUIOnPressedSpecialButton." .. Mod.id, function(gui, button)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)

Hooks:Add("BlackMarketGUIOnConfirmPressed", "BlackMarketGUIOnConfirmPressed." .. Mod.id, function(gui)
	if gui._search_bar and gui._search_bar:is_typing() then
		return false
	end
end)
