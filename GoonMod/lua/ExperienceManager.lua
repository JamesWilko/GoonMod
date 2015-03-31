
CloneClass( ExperienceManager )

Hooks:RegisterHook("ExperienceManagerGetRankString")
function ExperienceManager.rank_string(self, rank)
	local r = Hooks:ReturnCall("ExperienceManagerGetRankString", self, rank)
	if r ~= nil then
		return r
	end
	return self.orig.rank_string(self, rank)
end
