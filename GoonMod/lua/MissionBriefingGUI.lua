
CloneClass( MissionBriefingGui )

Hooks:RegisterHook("MissionBriefingGUIPreInit")
Hooks:RegisterHook("MissionBriefingGUIPostInit")
function MissionBriefingGui.init(self, saferect_ws, fullrect_ws, node)
	Hooks:Call( "MissionBriefingGUIPreInit", self, saferect_ws, fullrect_ws, node )
	self.orig.init(self, saferect_ws, fullrect_ws, node)
	Hooks:Call( "MissionBriefingGUIPostInit", self, saferect_ws, fullrect_ws, node )
end
