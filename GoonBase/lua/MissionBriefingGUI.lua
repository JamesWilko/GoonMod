----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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
