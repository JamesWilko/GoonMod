----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( AchievmentManager )

AchievmentManager._disabled_stack = {}

Hooks:RegisterHook("AchievementManagerPreAward")
function AchievmentManager.award(self, id)

	Hooks:Call("AchievementManagerPreAward", self, id)

	AchievmentManager:CheckAchievementsDisabled()
	if self:AchievementsDisabled() then
		return
	end

	self.orig.award(self, id)

end

Hooks:RegisterHook("AchievementManagerPreAwardProgress")
function AchievmentManager.award_progress(self, stat, value)

	Hooks:Call("AchievementManagerPreAwardProgress", self, stat, value)
	
	AchievmentManager:CheckAchievementsDisabled()
	if self:AchievementsDisabled() then
		return
	end

	self.orig.award_progress(self, stat, value)

end

function AchievmentManager:AchievementsDisabled()
	local disabled = false
	for k, v in pairs( self._disabled_stack ) do
		if v ~= nil and v == true then
			disabled = true
		end
	end
	return disabled
end

function AchievmentManager:DisableAchievements(id)
	self._disabled_stack[id] = true
end

function AchievmentManager:EnableAchievements(id)
	self._disabled_stack[id] = nil
end

Hooks:RegisterHook("AchievementManagerCheckDisable")
function AchievmentManager:CheckAchievementsDisabled()
	AchievmentManager._disabled_stack = {}
	Hooks:Call("AchievementManagerCheckDisable", self)
end
-- END OF FILE
