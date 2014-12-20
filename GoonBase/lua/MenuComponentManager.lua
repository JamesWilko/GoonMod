----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuComponentManager )

Hooks:RegisterHook("PostCreateCrimenetContractGUI")
function MenuComponentManager._create_crimenet_contract_gui(self, node)
	self.orig._create_crimenet_contract_gui(self, node)
	Hooks:Call("PostCreateCrimenetContractGUI", self, node, self._crimenet_contract_gui)
end

-- END OF FILE
