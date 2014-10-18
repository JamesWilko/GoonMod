----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( GroupAIStateBesiege )

Hooks:RegisterHook("GroupAIStateBesiegeInit")
function GroupAIStateBesiege.init(self)
	self.orig.init(self)
	Hooks:Call("GroupAIStateBesiegeInit", self)
end

-- END OF FILE
