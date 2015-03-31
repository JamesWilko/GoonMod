
CloneClass( GroupAIManager )

function GroupAIManager.set_state(self, name)
	-- Print("Setting Group AI State to: " .. name)
	self.orig.set_state(self, name)
end
