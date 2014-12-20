----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( BaseInteractionExt )

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")
Hooks:RegisterHook("BaseInteractionExtPreSetContour")
function BaseInteractionExt.set_contour(self, color, opacity)
	local r = Hooks:ReturnCall("BaseInteractionExtPreSetContour", self, color, opacity)
	if r ~= nil then
		color = r.color
		opacity = r.opacity
	end
	self.orig.set_contour(self, color, opacity)
end

-- END OF FILE
