----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GroupAIManager )

function GroupAIManager.set_state(self, name)
	-- Print("Setting Group AI State to: " .. name)
	self.orig.set_state(self, name)
end
-- END OF FILE
