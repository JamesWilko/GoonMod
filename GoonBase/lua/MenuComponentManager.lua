----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuComponentManager )

Hooks:RegisterHook("PostCreateCrimenetContractGUI")
function MenuComponentManager._create_crimenet_contract_gui(self, node)
	self.orig._create_crimenet_contract_gui(self, node)
	Hooks:Call("PostCreateCrimenetContractGUI", self, node, self._crimenet_contract_gui)
end
-- END OF FILE
