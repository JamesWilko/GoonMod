
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
