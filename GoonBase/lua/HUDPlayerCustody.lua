
CloneClass( HUDPlayerCustody )

function HUDPlayerCustody.init(this, hud)
	this.orig.init(this, hud)
end

function HUDPlayerCustody.set_trade_delay(this, time)

	if GoonHUD.Ironman:IsEnabled() then
		local trade_delay = this._hud_panel:child("custody_panel"):child("trade_delay")
		trade_delay:set_text( managers.localization:text("Ironman_NoTrade") )
	else
		this.orig.set_trade_delay(this, time)
	end

end


function HUDPlayerCustody.set_civilians_killed(this, amount)

	if GoonHUD.Ironman:IsEnabled() then
		local trade_delay = this._hud_panel:child("custody_panel"):child("civilians_killed")
		trade_delay:set_text( managers.localization:text("Ironman_NoRespawn") )
	else
		this.orig.set_civilians_killed(this, amount)
	end

end

function HUDPlayerCustody.set_negotiating_visible(this, visible)

	if GoonHUD.Ironman:IsEnabled() then
		this._hud.trade_text2:set_text("")
	else
		this.orig.set_negotiating_visible(this, visible)
	end

end

function HUDPlayerCustody.set_can_be_trade_visible(this, visible)

	if GoonHUD.Ironman:IsEnabled() then
		this._hud.trade_text1:set_text( managers.localization:text("Ironman_NoTradeTitle") )
	else
		this.orig.set_can_be_trade_visible(this, visible)
	end

end
