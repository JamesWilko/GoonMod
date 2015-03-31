
CloneClass( UpgradesTweakData )

Hooks:RegisterHook("UpgradesTweakDataOnSetupPaydayValues")
function UpgradesTweakData._init_pd2_values( self )
	self.orig._init_pd2_values( self )
	Hooks:Call("UpgradesTweakDataOnSetupPaydayValues", self)
end

Hooks:RegisterHook("UpgradesTweakDataOnSetupPlayerDefinitions")
function UpgradesTweakData._player_definitions( self )
	self.orig._player_definitions( self )
	Hooks:Call("UpgradesTweakDataOnSetupPlayerDefinitions", self)
end
