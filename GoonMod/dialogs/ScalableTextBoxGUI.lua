
ScalableTextBoxGui = ScalableTextBoxGui or class( TextBoxGui )

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return text:x(), text:y(), w, h
end

function ScalableTextBoxGui:set_size(x, y)

	ScalableTextBoxGui.super.set_size(self, x, y)

	local padding = 10
	local info_area = self._panel:child("info_area")
	local buttons_panel = info_area:child("buttons_panel")
	local scroll_panel = info_area:child("scroll_panel")
	scroll_panel:set_w( info_area:w() - scroll_panel:x() * 2 )
	scroll_panel:set_h( info_area:h() - buttons_panel:h() - padding * 3 )

	make_fine_text( scroll_panel:child("text") )

	buttons_panel:set_right( info_area:right() - padding )
	buttons_panel:set_bottom( info_area:bottom() - padding )

end
