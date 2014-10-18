----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( PlayerDamage )

function PlayerDamage.init(this, unit)
	this.orig.init(this, unit)
end

Hooks:RegisterHook( "PlayerDamageOnRegenerated" )
function PlayerDamage._regenerated(this, no_messiah)
	this.orig._regenerated(this, no_messiah)
	Hooks:Call("PlayerDamageOnRegenerated", this, no_messiah)
end

Hooks:RegisterHook( "PlayerDamageOnDowned" )
function PlayerDamage.on_downed(self)
	self.orig.on_downed(self)
	Hooks:Call("PlayerDamageOnDowned", self)
end

-- END OF FILE
