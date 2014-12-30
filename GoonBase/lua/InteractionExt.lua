----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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
