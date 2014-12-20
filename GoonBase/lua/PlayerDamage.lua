----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( PlayerDamage )

Hooks:RegisterHook( "PlayerDamageOnPostInit" )
function PlayerDamage.init(this, unit)
	this.orig.init(this, unit)
	Hooks:Call("PlayerDamageOnPostInit", this, unit)
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
