
core:module("SystemMenuManager")
require("lib/managers/dialogs/GenericDialog")

RedeemCodeDialog = RedeemCodeDialog or class(GenericDialog)
local tweak_data = _G.tweak_data
local code_color_normal = Color.white
local code_color_no_code = Color.white:with_alpha(0.3)
local max_code_length = 15

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

function RedeemCodeDialog:init(manager, data)

	Dialog.init(self, manager, data)
	if not self._data.focus_button then
		if #self._button_text_list > 0 then
			self._data.focus_button = #self._button_text_list
		else
			self._data.focus_button = 1
		end
	end
	self._ws = self._data.ws or manager:_get_ws()
	-- TODO: Remove this \n spam and find a way to set the height properly
	self._panel_script = _G.TextBoxGui:new(self._ws, self._data.title or "", (self._data.text or "") .. "\n\n\n\n ", self._data, {
		no_close_legend = true,
		use_indicator = data.indicator or data.no_buttons,
		is_title_outside = is_title_outside,
	})
	self._panel_script:add_background()
	self._panel_script:set_layer(tweak_data.gui.DIALOG_LAYER)
	self._panel_script:set_centered()
	self._panel_script:set_fade(0)
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

	local layer = tweak_data.gui.MOUSE_LAYER - 50
	local w, h = self._panel_script:w() * 0.85, self._panel_script:h() * 0.3
	local x, y = self._panel_script:w() * 0.5, self._panel_script:h() * 0.65

	self._code_rect = self._panel:rect({
		w = w,
		h = h,
	})
	self._code_rect:set_color( Color.black:with_alpha(0.5) )
	self._code_rect:set_center( x, y )

	self._code_text = self._panel:text({
		name = "code_text",
		text = managers.localization:text("gm_ex_inv_redeem_code_default"),
		font = tweak_data.menu.pd2_large_font,
		font_size = tweak_data.menu.pd2_large_font_size,
		blend_mode = "add",
		layer = layer
	})
	self._code_text:set_text( managers.localization:text("gm_ex_inv_redeem_code_default") )
	self._code_text:set_color( code_color_no_code )
	make_fine_text( self._code_text )
	self._code_text:set_center( x, y )

	if not self._connected_keyboard then
		self._ws:connect_keyboard(Input:keyboard())
		self._panel:enter_text(callback(self, self, "enter_text"))
		self._panel:key_press(callback(self, self, "key_press"))
		self._connected_keyboard = true
	end

	self._is_entering_code = true
	self._entered_code = ""

end

function RedeemCodeDialog:UpdateCodeText()

	if not alive( self._code_text ) then
		return
	end

	self._code_text:set_text( tostring(self._entered_code):upper() )
	if self._entered_code:is_nil_or_empty() then
		self._code_text:set_color( code_color_no_code )
		self._code_text:set_text( managers.localization:text("gm_ex_inv_redeem_code_default") )
	else
		self._code_text:set_color( code_color_normal )
	end

	local x, y = self._panel_script:w() * 0.5, self._panel_script:h() * 0.65
	make_fine_text( self._code_text )
	self._code_text:set_center( x, y )

end

function RedeemCodeDialog:enter_text( o, s )

	if not self._is_entering_code then
		return
	end

	local n = utf8.len(self._entered_code)
	if n < max_code_length then
		self._entered_code = self._entered_code .. tostring(s)
		self._entered_code = self._entered_code:lower()
	end

	self:UpdateCodeText()

end

function RedeemCodeDialog:key_press( o, k )

	if not self._is_entering_code then
		return
	end

	if k == Idstring("backspace") then
		local n = utf8.len(self._entered_code)
		self._entered_code = utf8.sub(self._entered_code, 0, math.max(n - 1, 0))
	end

	self:UpdateCodeText()

end

function RedeemCodeDialog:close()

	if self._connected_keyboard then
		self._ws:disconnect_keyboard()
		self._panel:enter_text(nil)
		self._panel:key_press(nil)
		self._connected_keyboard = false
	end

	local code = self._entered_code
	RedeemCodeDialog.super.close(self)
	_G.GoonBase.ExtendedInventory:EnteredRedeemCode( code )

end

function RedeemCodeDialog:button_pressed_callback()
	log("RedeemCodeDialog:button_pressed_callback()")
	RedeemCodeDialog.super.button_pressed_callback(self)
end

function RedeemCodeDialog:dialog_cancel_callback()
	log("RedeemCodeDialog:dialog_cancel_callback()")
	RedeemCodeDialog.super.dialog_cancel_callback(self)
end
