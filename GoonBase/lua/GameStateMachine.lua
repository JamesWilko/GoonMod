----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GameStateMachine )

Hooks:RegisterHook("GameStateMachineChangeStateByName")
function GameStateMachine.change_state_by_name(self, state_name, params)
	Hooks:Call("GameStateMachineChangeStateByName", self, state_name, params)
	self.orig.change_state_by_name(self, state_name, params)
end
-- END OF FILE
