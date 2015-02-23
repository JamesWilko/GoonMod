
CloneClass( MenuComponentManager )

Hooks:RegisterHook("PostCreateCrimenetContractGUI")
function MenuComponentManager._create_crimenet_contract_gui(self, node)
	self.orig._create_crimenet_contract_gui(self, node)
	Hooks:Call("PostCreateCrimenetContractGUI", self, node, self._crimenet_contract_gui)
end
