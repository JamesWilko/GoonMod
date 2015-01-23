----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/23/2015 10:01:12 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local WeaponCustomization = GoonBase.WeaponCustomization
if not GoonBase.WeaponCustomization then
	return
end

function WeaponCustomization:_GetLocalizedPartName( part_name, part )
	return string.upper( self:GetLocalizedPartName( part_name, part ) )
end

function WeaponCustomization:GetLocalizedPartName( part_name, part )
	if part == "nil" then
		return "No Name"
	end
	if WeaponCustomization.MissingPartLocalizations[ part_name ] then
		return WeaponCustomization.MissingPartLocalizations[ part_name ]
	end
	if WeaponCustomization.MissingPartLocalizations[ part.name_id ] then
		return WeaponCustomization.MissingPartLocalizations[ part.name_id ]
	end
	return (part.name_id and managers.localization:text( part.name_id ) or part_name)
end

local standard_barrel = "Standard Barrel"
local standard_magazine = "Standard Magazine"
local standard_grip = "Standard Grip"
local standard_foregrip = "Standard Foregrip"
local standard_body = "Standard Body"
local standard_stock = "Standard Stock"
local standard_slide = "Standard Slide"
local standard_rail = "Standard Rail"
local standard_sights = "Standard Sights"
local standard_compensator = "Standard Compensator"
local upper_receiver = "Upper Receiver"
local lower_receiver = "Lower Receiver"
local vertical_grip = "Vertical Grip"
local gadget_adapter = "Gadget Adapter"
local optic_adapter = "Optic Adapter"
local stock_adapter = "Stock Adapter"

WeaponCustomization.MissingPartLocalizations = {

	-- Secondaries
	["wpn_fps_pis_usp_body_standard"] = standard_body,
	["wpn_fps_pis_usp_m_standard"] = standard_magazine,
	["wpn_fps_pis_usp_fl_adapter"] = standard_body,
	
	["wpn_fps_pis_g17_body_standard"] = standard_body,
	["wpn_fps_pis_g17_b_standard"] = standard_slide,
	["wpn_fps_pis_g17_m_standard"] = standard_magazine,

	["wpn_fps_pis_beretta_b_std"] = standard_barrel,
	["wpn_fps_pis_beretta_body_beretta"] = standard_body,
	["wpn_fps_pis_beretta_m_std"] = standard_magazine,
	["wpn_fps_pis_beretta_g_std"] = standard_grip,
	["wpn_fps_pis_beretta_sl_std"] = standard_slide,
	["wpn_fps_pis_beretta_o_std"] = standard_sights,
	["bm_wp_beretta_body_rail"] = standard_rail,

	["bm_wp_deagle_body_standard"] = standard_body,
	["bm_wp_deagle_b_standard"] = standard_barrel,
	["bm_wp_deagle_g_standard"] = standard_grip,
	["bm_wp_deagle_m_standard"] = standard_magazine,
	["bm_wp_deagle_o_standard_front"] = "Front Sight",
	["bm_wp_deagle_o_standard_front_long"] = "Front Sight",
	["bm_wp_deagle_o_standard_rear"] = "Rear Sight",

	["bm_wp_c96_body_standard"] = standard_body,
	["bm_wp_c96_b_standard"] = standard_barrel,
	["bm_wp_c96_m_standard"] = standard_magazine,
	["bm_wp_c96_g_standard"] = standard_grip,

	["bm_wp_g18c_b_standard"] = standard_barrel,
	["bm_wp_g18c_body_frame"] = standard_body,

	["wpn_fps_pis_g26_body_stardard"] = standard_body,
	["wpn_fps_pis_g26_m_standard"] = standard_magazine,
	["wpn_fps_pis_g26_b_standard"] = standard_barrel,

	["bm_wp_g22c_body_standard"] = standard_body,
	["bm_wp_g22c_b_standard"] = standard_barrel,

	["wpn_fps_pis_judge_b_standard"] = standard_barrel,
	["wpn_fps_pis_judge_fl_adapter"] = gadget_adapter,
	["wpn_fps_pis_judge_g_standard"] = standard_grip,
	["wpn_fps_pis_judge_body_standard"] = standard_body,

	["wpn_fps_upg_vg_ass_smg_verticalgrip"] = vertical_grip,
	["wpn_fps_upg_vg_ass_smg_verticalgrip_vanilla"] = vertical_grip,

	["bm_wp_akmsu_fg_standard"] = standard_foregrip,
	["bm_wp_akmsu_b_standard"] = standard_barrel,
	["bm_wp_akmsu_body_lowerreceiver"] = lower_receiver,

	["wpn_fps_smg_thompson_barrel"] = standard_barrel,
	["wpn_fps_smg_thompson_body"] = standard_body,
	["wpn_fps_smg_thompson_drummag"] = "Drum Magazine",
	["wpn_fps_smg_thompson_fl_adapter"] = gadget_adapter,
	["wpn_fps_smg_thompson_foregrip"] = standard_foregrip,
	["wpn_fps_smg_thompson_grip"] = standard_grip,
	["wpn_fps_smg_thompson_ns_standard"] = standard_compensator,
	["wpn_fps_smg_thompson_o_adapter"] = optic_adapter,
	["wpn_fps_smg_thompson_stock"] = standard_stock,

	["wpn_fps_smg_uzi_b_standard"] = standard_barrel,
	["wpn_fps_smg_uzi_body_standard"] = standard_body,
	["wpn_fps_smg_uzi_fg_standard"] = standard_foregrip,
	["wpn_fps_smg_uzi_g_standard"] = standard_grip,
	["wpn_fps_smg_uzi_m_standard"] = standard_magazine,
	["wpn_fps_smg_uzi_s_unfolded"] = "Unfolded Stock",

	["bm_wp_mac10_b_dummy"] = "Dummy Body",
	["bm_wp_mac10_body_mac10"] = standard_body,

	["wpn_fps_smg_sterling_body_standard"] = standard_body,
	["wpn_fps_smg_sterling_o_adapter"] = optic_adapter,
	["wpn_fps_smg_sterling_s_standard"] = standard_stock,
	["wpn_fps_smg_sterling_m_medium"] = standard_magazine,
	["bm_wp_sterling_b_standard"] = standard_barrel,

	["bm_wp_mp5_body_mp5"] = standard_body,
	["bm_wp_mp5_body_rail"] = standard_rail,
	["bm_wp_mp5_m_std"] = standard_magazine,

	["bm_wp_mp7_b_standard"] = standard_magazine,
	["bm_wp_mp7_body_standard"] = standard_body,
	["bm_wp_mp7_m_short"] = "Short Magazine",
	["bm_wp_mp7_s_standard"] = standard_stock,

	["bm_wp_mp9_b_dummy"] = "Dummy Body",
	["bm_wp_mp9_body_mp9"] = standard_body,

	["bm_wp_p226_b_standard"] = standard_barrel,
	["bm_wp_p226_body_standard"] = standard_body,
	["bm_wp_p226_g_standard"] = standard_grip,
	["bm_wp_p226_m_standard"] = standard_magazine,
	["bm_wp_p226_o_long"] = standard_sights,
	["bm_wp_p226_o_standard"] = standard_sights,

	["bm_wp_p90_body_p90"] = standard_body,
	["bm_wp_p90_m_std"] = standard_magazine,

	["bm_wp_pis_rage_o_adapter"] = optic_adapter,
	["bm_wp_rage_b_standard"] = standard_barrel,
	["bm_wp_rage_body_standard"] = standard_body,
	["bm_wp_rage_g_standard"] = standard_grip,

	["bm_wp_scorpion_m_standard"] = standard_magazine,
	["wpn_fps_smg_scorpion_b_standard"] = standard_barrel,
	["wpn_fps_smg_scorpion_body_standard"] = standard_body,
	["wpn_fps_smg_scorpion_extra_rail"] = standard_rail,
	["wpn_fps_smg_scorpion_extra_rail_gadget"] = "Rail Gadget",
	["wpn_fps_smg_scorpion_g_standard"] = standard_grip,
	["wpn_fps_smg_scorpion_s_standard"] = standard_stock,

	["wpn_fps_smg_tec9_b_long"] = "Long Barrel",
	["wpn_fps_smg_tec9_body_standard"] = standard_body,
	["wpn_fps_smg_tec9_m_standard"] = standard_magazine,

	["wpn_fps_pis_ppk_b_standard"] = standard_barrel,
	["wpn_fps_pis_ppk_body_standard"] = standard_body,
	["wpn_fps_pis_ppk_fl_mount"] = gadget_adapter,
	["wpn_fps_pis_ppk_g_standard"] = standard_grip,
	["wpn_fps_pis_ppk_m_standard"] = standard_magazine,

	["wpn_fps_smg_m45_g_standard"] = standard_grip,
	["wpn_fps_smg_m45_s_standard"] = standard_stock,
	["wpn_fps_smg_m45_m_mag"] = standard_magazine,
	["wpn_fps_smg_m45_b_standard"] = standard_barrel,
	["wpn_fps_smg_m45_body_standard"] = standard_body,

	["bm_wp_upg_o_marksmansight_front"] = "Front Marksman Sight",

	["bm_wp_striker_b_standard"] = standard_barrel,
	["bm_wp_striker_body_standard"] = standard_body,

	-- Primaries
	["wpn_fps_amcar_uupg_fg_amcar"] = standard_foregrip,
	["wpn_fps_amcar_uupg_body_upperreciever"] = upper_receiver,
	["bm_wp_m4_lower_reciever"] = lower_receiver,
	["bm_wp_m4_g_standard"] = standard_grip,

	["wpn_fps_ass_fal_body_standard"] = standard_body,
	["wpn_fps_ass_fal_fg_standard"] = standard_foregrip,
	["wpn_fps_ass_fal_g_standard"] = standard_grip,
	["wpn_fps_ass_fal_m_standard"] = standard_magazine,
	["wpn_fps_ass_fal_s_standard"] = standard_stock,

	["wpn_fps_snp_msr_body_wood"] = "Wooden Body",
	["wpn_fps_snp_msr_m_standard"] = standard_magazine,
	["wpn_fps_snp_msr_b_standard"] = standard_barrel,

	["wpn_fps_snp_mosin_b_medium"] = "Medium Barrel",
	["wpn_fps_snp_mosin_rail"] = "Nagant Rail",
	["wpn_fps_snp_mosin_body_standard"] = standard_body,
	["wpn_fps_snp_mosin_m_standard"] = standard_magazine,

	["wpn_fps_snp_r93_b_standard"] = standard_barrel,
	["wpn_fps_snp_r93_body_standard"] = standard_body,
	["wpn_fps_snp_r93_m_std"] = standard_magazine,

	["wpn_fps_snp_m95_bipod"] = "Bipod",
	["wpn_fps_snp_m95_barrel_standard"] = standard_barrel,
	["wpn_fps_snp_m95_lower_reciever"] = lower_receiver,
	["wpn_fps_snp_m95_upper_reciever"] = upper_receiver,
	["wpn_fps_snp_m95_magazine"] = standard_magazine,

	["wpn_fps_aug_body_aug"] = standard_body,
	["wpn_fps_aug_m_pmag"] = standard_magazine,

	["bm_wp_famas_body_standard"] = standard_body,
	["bm_wp_famas_b_standard"] = standard_barrel,
	["bm_wp_famas_g_standard"] = standard_grip,
	["bm_wp_famas_m_standard"] = standard_magazine,
	["bm_wp_famas_o_extra"] = optic_adapter,

	["wpn_fps_sho_ben_s_collapsable"] = "Collapsable Stock",
	["wpn_fps_sho_ben_b_standard"] = standard_barrel,
	["wpn_fps_sho_ben_body_standard"] = standard_body,

	["bm_wp_r870_body_standard"] = standard_body,
	["bm_wp_r870_b_long"] = standard_barrel,
	["bm_wp_r870_fg_big"] = standard_foregrip,
	["wpn_fps_shot_r870_b_short"] = "Short Barrel",

	["bm_wp_ak5_b_std"] = standard_barrel,
	["bm_wp_ak5_body_ak5"] = standard_body,
	["bm_wp_ak5_body_rail"] = standard_rail,

	["bm_wp_ak_body_lowerreceiver"] = lower_receiver,
	["bm_wp_ak_g_standard"] = standard_grip,
	["bm_wp_ak_m_akm"] = standard_magazine,
	["bm_wp_ak_fg_standard"] = standard_foregrip,

	["bm_wp_akm_body_upperreceiver"] = "AK Dustcover",
	["bm_wp_akm_b_standard"] = standard_barrel,

	["bm_wp_74_m_standard"] = standard_magazine,
	["bm_wp_74_b_standard"] = standard_barrel,

	["bm_wp_ak_fg_standard_gold"] = "Golden Foregrip",
	["bm_wp_ak_m_akm_gold"] = "Golden Magazine",
	["bm_wp_akm_b_standard_gold"] = "Golden Barrel",
	["bm_wp_akm_body_upperreceiver_gold"] = "Golden Upper Receiver",
	["bm_wp_ak_body_lowerreceiver_gold"] = "Golden Lower Receiver",

	["bm_wp_gre_m79_barrel"] = "Barrel",
	["bm_wp_gre_m79_grenade"] = "Grenade",
	["bm_wp_m79_barrelcatch"] = "Barrel Catch",
	["bm_wp_m79_sight_up"] = "Sight",

	["bm_wp_g3_b_long"] = standard_barrel,
	["bm_wp_g3_body_lower"] = lower_receiver,
	["bm_wp_g3_body_upper"] = upper_receiver,
	["bm_wp_g3_fg_standard"] = standard_foregrip,
	["bm_wp_g3_m_standard"] = standard_magazine,

	["bm_wp_g36_body_standard"] = standard_body,
	["bm_wp_g36_body_sl8"] = "Sniper Body",
	["bm_wp_g36_g_standard"] = standard_grip,
	["bm_wp_g36_m_standard"] = standard_magazine,
	["bm_wp_g36_s_standard"] = standard_stock,

	["bm_wp_galil_body_standard"] = standard_body,
	["bm_wp_galil_fg_standard"] = standard_foregrip,
	["bm_wp_galil_g_standard"] = standard_grip,
	["bm_wp_galil_m_standard"] = standard_magazine,
	["bm_wp_galil_s_standard"] = standard_stock,

	["wpn_fps_lmg_hk21_b_short"] = "Short Barrel",
	["wpn_fps_lmg_hk21_body_lower"] = lower_receiver,
	["wpn_fps_lmg_hk21_body_upper"] = upper_receiver,
	["wpn_fps_lmg_hk21_fg_long"] = "Long Foregrip",
	["wpn_fps_lmg_hk21_g_standard"] = standard_grip,
	["wpn_fps_lmg_hk21_m_standard"] = standard_magazine,
	["wpn_fps_lmg_hk21_s_standard"] = standard_stock,

	["bm_wp_huntsman_body_standard"] = standard_body,

	["bm_wp_ksg_b_standard"] = standard_barrel,
	["bm_wp_ksg_body_standard"] = standard_body,
	["bm_wp_ksg_fg_short"] = standard_foregrip,
	["wpn_fps_sho_ksg_fg_standard"] = standard_foregrip,
	["bm_wp_upg_o_mbus_front"] = "Front Flip-up Sight",
	["bm_wp_upg_o_dd_front"] = "Front Sight",
	["bm_wp_upg_o_dd_rear"] = "Rear Sight",

	["wpn_fps_ass_l85a2_b_medium"] = "Medium Barrel",
	["wpn_fps_ass_l85a2_body_standard"] = standard_body,
	["wpn_fps_ass_l85a2_g_standard"] = standard_grip,
	["wpn_fps_ass_l85a2_ns_standard"] = standard_compensator,
	["wpn_fps_ass_l85a2_o_standard"] = standard_sights,
	["wpn_fps_ass_l85a2_fg_medium"] = standard_foregrip,

	["bm_wp_m14_m_standard"] = standard_magazine,
	["bm_wp_m14_b_standard"] = standard_barrel,
	["bm_wp_m14_body_lower"] = lower_receiver,
	["bm_wp_m14_body_upper"] = upper_receiver,

	["bm_wp_m16_fg_standard"] = standard_foregrip,
	["bm_wp_m16_s_solid"] = standard_stock,
	["bm_wp_m16_os_frontsight"] = standard_sights,

	["wpn_fps_lmg_m249_b_short"] = "Short Barrel",
	["wpn_fps_lmg_m249_body_standard"] = standard_body,
	["wpn_fps_lmg_m249_fg_standard"] = standard_foregrip,
	["wpn_fps_lmg_m249_m_standard"] = "Box Magazine",
	["wpn_fps_lmg_m249_s_modern"] = "Modern Stock",
	["wpn_fps_lmg_m249_s_para"] = standard_stock,
	["wpn_fps_lmg_m249_upper_reciever"] = upper_receiver,

	["bm_wp_m4_g_standard"] = standard_grip,
	["bm_wp_m4_lower_reciever"] = lower_receiver,
	["bm_wp_m4_s_adapter"] = stock_adapter,
	["bm_wp_m4_uupg_draghandle"] = "Drag Handle",
	["bm_wp_m4_uupg_fg_rail_ext"] = "Foregrip Rail",
	["bm_wp_m4_upg_b_sd_smr"] = "SMR",

	["wpn_fps_lmg_mg42_n42"] = standard_compensator,
	["wpn_fps_lmg_mg42_b_mg42"] = standard_barrel,
	["wpn_fps_lmg_mg42_reciever"] = "Receiver and Stock",

	["wpn_fps_lmg_rpk_b_standard"] = standard_barrel,
	["wpn_fps_lmg_rpk_body_lowerreceiver"] = lower_receiver,
	["wpn_fps_lmg_rpk_fg_wood"] = "Wooden Foregrip",
	["wpn_lmg_rpk_m_drum"] = "Drum Magazine",
	["wpn_fps_lmg_rpk_s_wood"] = "Wooden Stock",

	["bm_wp_saiga_b_standard"] = standard_barrel,
	["bm_wp_saiga_fg_standard"] = standard_foregrip,
	["bm_wp_saiga_m_5rnd"] = standard_magazine,

	["bm_wp_saw_b_normal"] = "Blade Guard",
	["bm_wp_saw_body_standard"] = "Saw Body",
	["bm_wp_saw_m_blade"] = "Saw Blade",

	["bm_wp_scar_b_medium"] = "Medium Barrel",
	["bm_wp_scar_body_standard"] = standard_body,
	["bm_wp_scar_m_standard"] = standard_magazine,
	["bm_wp_scar_ns_short"] = standard_compensator,
	["bm_wp_scar_ns_standard"] = standard_compensator,
	["bm_wp_scar_o_flipups_down"] = standard_sights,
	["bm_wp_scar_o_flipups_up"] = standard_sights,
	["bm_wp_scar_s_standard"] = standard_stock,

	["wpn_fps_sho_b_spas12_long"] = "Long Barrel",
	["wpn_fps_sho_b_spas12_short"] = "Short Barrel",
	["wpn_fps_sho_body_spas12_standard"] = standard_body,
	["wpn_fps_sho_fg_spas12_standard"] = standard_foregrip,
	["wpn_fps_sho_s_spas12_unfolded"] = standard_stock,

	["wpn_fps_ass_s552_m_standard"] = standard_magazine,
	["wpn_fps_ass_s552_o_flipup"] = standard_sights,
	["wpn_fps_ass_s552_g_standard"] = standard_grip,
	["wpn_fps_ass_s552_s_m4"] = "M4 Stock",
	["wpn_fps_ass_s552_s_standard"] = standard_stock,
	["wpn_fps_ass_s552_b_standard"] = standard_barrel,
	["wpn_fps_ass_s552_body_standard"] = standard_body,
	["wpn_fps_ass_s552_fg_standard"] = standard_foregrip,

	["wpn_fps_shot_shorty_m_extended_short"] = "Extended Magazine",

	["bm_wp_upg_vg_ass_smg_afg"] = "AFG",
	["bm_wp_upg_vg_ass_smg_stubby"] = "Stubby",
	["wpn_fps_upg_fl_ass_peq15_flashlight"] = "Flashlight",

}
-- END OF FILE
