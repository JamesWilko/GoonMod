
core:module("SystemMenuManager")
require("lib/managers/dialogs/GenericDialog")

RedeemCodeItemsDialog = RedeemCodeItemsDialog or class(GenericDialog)
local tweak_data = _G.tweak_data
local item_size = 80
local redeem_max_items_w = 5
local item_padding = 8

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

function RedeemCodeItemsDialog:init(manager, data)

	Dialog.init(self, manager, data)
	if not self._data.focus_button then
		if #self._button_text_list > 0 then
			self._data.focus_button = #self._button_text_list
		else
			self._data.focus_button = 1
		end
	end
	self._ws = self._data.ws or manager:_get_ws()
	self._panel_script = _G.ScalableTextBoxGui:new(self._ws, self._data.title or "", (self._data.text or ""), self._data, {
		no_close_legend = true,
		use_indicator = data.indicator or data.no_buttons,
		is_title_outside = is_title_outside,
	})
	self._panel_script:add_background()
	self._panel_script:set_layer(tweak_data.gui.DIALOG_LAYER)
	self._panel_script:set_fade(0)
	self._panel_script:set_size( 500, 340 )
	self._panel_script:set_centered()
	self._controller = self._data.controller or manager:_get_controller()
	self._confirm_func = callback(self, self, "button_pressed_callback")
	self._cancel_func = callback(self, self, "dialog_cancel_callback")
	self._resolution_changed_callback = callback(self, self, "resolution_changed_callback")
	managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)
	if data.counter then
		self._counter = data.counter
		self._counter_time = self._counter[1]
	end

	self._panel = self._panel_script._panel
	self._item_panel = self._panel:panel()
	
	local w, h = item_size * redeem_max_items_w + item_padding * redeem_max_items_w, item_size + item_padding * 2
	local x, y = self._panel_script:w() * 0.5, self._panel_script:h() * 0.465
	self._item_panel:set_size( w, h )
	self._item_panel:set_center( x, y )

	self._panel_box = _G.BoxGuiObject:new(self._item_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	if data.items then

		self._code_items = {}
		for k, v in pairs( data.items ) do
			local item = ExtendedInventoryCodeItem:new( self._item_panel, k, v )
			table.insert( self._code_items, item )
		end

	end

end

function RedeemCodeItemsDialog:mouse_moved(o, x, y)

	RedeemCodeItemsDialog.super.mouse_moved(self, o, x, y)

	if self._code_items then
		for k, v in pairs( self._code_items ) do
			v:check_mouse( x, y )
		end
	end

end

ExtendedInventoryCodeItem = ExtendedInventoryCodeItem or class()
function ExtendedInventoryCodeItem:init( panel, index, data )
	
	local padding = item_padding
	local w, h = item_size, item_size
	local x, y = padding * index + w * (index - 1), padding

	local item_name, item_icon = _G.GoonBase.ExtendedInventory:GetDisplayDataForItem( data )
	if item_name and data.quantity then
		item_name = item_name .. ( data.quantity > 1 and " x" .. tostring(data.quantity) or "" )
	end

	self._panel = panel
	self._item = panel:bitmap({
		name = "item_" .. index,
		texture = item_icon or "guis/textures/pd2/blackmarket/icons/cash",
		x = x,
		y = y,
		w = w,
		h = h,
		color = Color.white
	})

	self._item_name = panel:text({
		text = item_name or "Item",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		blend_mode = "add",
		color = Color.white,
	})
	make_fine_text( self._item_name )
	self._item_name:set_center( x + w * 0.5, y + h )
	self._item_name:set_alpha(0)

	return self

end

function ExtendedInventoryCodeItem:destroy()
	self._panel:remove( self._item )
	self._panel:remove( self._item_name )
	self._item = nil
	self._item_name = nil
end

function ExtendedInventoryCodeItem:check_mouse(x, y)

	if self._item:inside(x, y) then
		if self._item_name:alpha() < 1 then
			managers.menu:post_event("highlight")
		end
		self._item_name:set_alpha( 1 )
	else
		self._item_name:set_alpha( 0 )
	end

end
