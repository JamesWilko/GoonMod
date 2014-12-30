----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( LocalizationManager )

function LocalizationManager.text(this, str, macros)

	if _G.GoonBase.Localization[str] then

		local return_str =_G.GoonBase.Localization[str]
		if macros and type(macros) == "table" then
			for k, v in pairs( macros ) do
				return_str = return_str:gsub( "$" .. k, v )
			end
		end
		return return_str

	end
	return this.orig.text(this, str, macros)

end
-- END OF FILE
