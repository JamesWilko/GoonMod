----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MissionBriefingGui )

Hooks:RegisterHook("MissionBriefingGUIPreInit")
Hooks:RegisterHook("MissionBriefingGUIPostInit")
function MissionBriefingGui.init(self, saferect_ws, fullrect_ws, node)
	Hooks:Call( "MissionBriefingGUIPreInit", self, saferect_ws, fullrect_ws, node )
	self.orig.init(self, saferect_ws, fullrect_ws, node)
	Hooks:Call( "MissionBriefingGUIPostInit", self, saferect_ws, fullrect_ws, node )
end

-- END OF FILE
