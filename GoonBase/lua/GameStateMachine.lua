----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/26/2014 12:35:33 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GameStateMachine )

Hooks:RegisterHook("GameStateMachineChangeStateByName")
function GameStateMachine.change_state_by_name(self, state_name, params)
	Hooks:Call("GameStateMachineChangeStateByName", self, state_name, params)
	self.orig.change_state_by_name(self, state_name, params)
end

-- END OF FILE
