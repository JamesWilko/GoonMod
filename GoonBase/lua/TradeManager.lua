
CloneClass( TradeManager )

function TradeManager.on_hostage_traded(this, trading_unit)
	if trading_unit ~= nil then
		return this.orig.on_hostage_traded(this, trading_unit)
	end
end


function TradeManager.set_trade_countdown(this, enabled)

	if GoonHUD.Ironman:IsEnabled() then
		enabled = false
	end

	this._trade_countdown = enabled
	if Network:is_server() and managers.network then
		managers.network:session():send_to_peers("set_trade_countdown", enabled)
	end

end
