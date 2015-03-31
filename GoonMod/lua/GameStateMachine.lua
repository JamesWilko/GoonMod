
CloneClass( GameStateMachine )

Hooks:RegisterHook("GameStateMachineChangeStateByName")
function GameStateMachine.change_state_by_name(self, state_name, params)
	Hooks:Call("GameStateMachineChangeStateByName", self, state_name, params)
	self.orig.change_state_by_name(self, state_name, params)
end
