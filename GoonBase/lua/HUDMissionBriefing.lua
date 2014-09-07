
CloneClass( HUDMissionBriefing )

Hooks:RegisterHook( "HUDMissionBriefingInitialize" )
function HUDMissionBriefing.init(this, hud, workspace)

	local temp = tweak_data.screen_colors.risk
	tweak_data.screen_colors.risk = (GoonHUD.Ironman:IsEnabled() and tweak_data.screen_colors.important_1) or tweak_data.screen_colors.risk
	this.orig.init(this, hud, workspace)
	tweak_data.screen_colors.risk = temp

	Hooks:Call("HUDMissionBriefingInitialize", this, hud, workspace)

end
