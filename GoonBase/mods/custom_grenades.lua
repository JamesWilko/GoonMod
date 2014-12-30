----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

Hooks:Add("BlackMarketManagerPostSetup", "BlackMarketManagerPostSetup_CustomGrenades", function(blackmarket_manager)

	-- blackmarket_manager._defaults.grenade = "flashbang"

end)

Hooks:Add("BlackMarketTweakDataPostInitGrenades", "BlackMarketTweakDataPostInitGrenades_CustomGrenades", function(tweak_data)
	
	tweak_data.grenades.flashbang = {}
	tweak_data.grenades.flashbang.name_id = "bm_grenade_flashbang"
	tweak_data.grenades.flashbang.unit = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade"
	tweak_data.grenades.flashbang.unit_dummy = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade_husk"
	tweak_data.grenades.flashbang.sprint_unit = "units/payday2/weapons/wpn_frag_grenade/wpn_frag_grenade_sprint"
	tweak_data.grenades.flashbang.icon = "frag_grenade"
	tweak_data.grenades.flashbang.dlc = "gage_pack"

end)

Hooks:Add("GrenadeBaseClassInit", "GrenadeBaseClassInit_CustomGrenades", function(grenade_base)

	table.insert( grenade_base.types, "flashbang" )
	table.insert( grenade_base.types, "smoke" )
	table.insert( grenade_base.types, "incendiary" )

	dofile( "GoonBase/mods/weapons/flashbang_grenade.lua" )

end)
-- END OF FILE
