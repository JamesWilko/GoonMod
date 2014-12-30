----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( ActionSpooc )

Hooks:RegisterHook("ActionSpoocInitialize")
function ActionSpooc.init(self, action_desc, common_data)
	Hooks:Call("ActionSpoocInitialize", self, action_desc, common_data)
	return self.orig.init(self, action_desc, common_data)
end

Hooks:RegisterHook("ActionSpoocAnimActCallback")
function ActionSpooc.anim_act_clbk(self, anim_act)
	Hooks:Call("ActionSpoocAnimActCallback", self, anim_act)
	return self.orig.anim_act_clbk(self, anim_act)
end
-- END OF FILE
