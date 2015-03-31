
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "RomanInfamy"
Mod.Name = "Infamy Roman Numerals"
Mod.Desc = "Restores the infamy system to use Roman instead of Arabic numerals"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

Hooks:Add("ExperienceManagerGetRankString", "ExperienceManagerGetRankString_" .. Mod:ID(), function(exp_manager, rank)

	-- Credit to Overkill Software for the original code
	if not rank or rank <= 0 then
		return nil
	end
	local numbers = {
		1,
		5,
		10,
		50,
		100,
		500,
		1000
	}
	local chars = {
		"I",
		"V",
		"X",
		"L",
		"C",
		"D",
		"M"
	}
	local roman = ""
	for i = #numbers, 1, -1 do
		local num = numbers[i]
		while rank - num >= 0 and rank > 0 do
			roman = roman .. chars[i]
			rank = rank - num
		end
		for j = 1, i - 1 do
			local num2 = numbers[j]
			if rank - (num - num2) >= 0 and num > rank and rank > 0 and num - num2 ~= num2 then
				roman = roman .. chars[j] .. chars[i]
				rank = rank - (num - num2)
				break
			end
		end
	end
	return roman

end)
