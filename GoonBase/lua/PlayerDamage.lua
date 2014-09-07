
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

	self._downed_timer = (GoonHUD.Ironman:IsEnabled() and GoonHUD.Ironman:PlayerShouldDie(self)) and 0 or self:down_time()
	self._downed_start_time = self._downed_timer
	self._downed_paused_counter = 0
	managers.hud:pd_start_timer({
		time = self._downed_timer
	})
	managers.hud:on_downed()
	self:_stop_tinnitus()

	Hooks:Call("PlayerDamageOnDowned", self)

end
