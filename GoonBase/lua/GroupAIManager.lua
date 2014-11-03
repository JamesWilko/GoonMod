----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/3/2014 6:23:30 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GroupAIManager )

function GroupAIManager.set_state(self, name)
	-- Print("Setting Group AI State to: " .. name)
	self.orig.set_state(self, name)
end

-- END OF FILE
