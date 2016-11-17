
CloneClass( WeaponTweakData )

Hooks:RegisterHook("WeaponTweakDataPostInit")
function WeaponTweakData.init(self, tweak_data)
	self.orig.init(self, tweak_data)
	Hooks:Call("WeaponTweakDataPostInit", self, tweak_data)
end

Hooks:RegisterHook("WeaponTweakDataPostInitPlayerWeaponData")
function WeaponTweakData._init_data_player_weapons(self, tweak_data)
	self.orig._init_data_player_weapons(self, tweak_data)
	Hooks:Call("WeaponTweakDataPostInitPlayerWeaponData", self, tweak_data)
end

Hooks:RegisterHook("WeaponTweakDataPostInitNewWeapons")
function WeaponTweakData._init_new_weapons(self, autohit_rifle_default, autohit_pistol_default, autohit_shotgun_default, autohit_lmg_default, autohit_snp_default, autohit_smg_default, autohit_minigun_default, damage_melee_default, damage_melee_effect_multiplier_default, aim_assist_rifle_default, aim_assist_pistol_default, aim_assist_shotgun_default, aim_assist_lmg_default, aim_assist_snp_default, aim_assist_smg_default, aim_assist_minigun_default)
	self.orig._init_new_weapons(self, autohit_rifle_default, autohit_pistol_default, autohit_shotgun_default, autohit_lmg_default, autohit_snp_default, autohit_smg_default, autohit_minigun_default, damage_melee_default, damage_melee_effect_multiplier_default, aim_assist_rifle_default, aim_assist_pistol_default, aim_assist_shotgun_default, aim_assist_lmg_default, aim_assist_snp_default, aim_assist_smg_default, aim_assist_minigun_default)
	Hooks:Call("WeaponTweakDataPostInitNewWeapons", self, autohit_rifle_default, autohit_pistol_default, autohit_shotgun_default, autohit_lmg_default, autohit_snp_default, autohit_smg_default, autohit_minigun_default, damage_melee_default, damage_melee_effect_multiplier_default, aim_assist_rifle_default, aim_assist_pistol_default, aim_assist_shotgun_default, aim_assist_lmg_default, aim_assist_snp_default, aim_assist_smg_default, aim_assist_minigun_default)
end
