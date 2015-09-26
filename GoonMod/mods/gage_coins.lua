
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GageCoins"
Mod.Name = "Gage-Coins"
Mod.Desc = "Gage has started up his own currency. For every courier assignment you complete, you'll get a whole Gage-Coin from the big man himself"
Mod.Requirements = { "ExtendedInventory" }
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mod Data
_G.GoonBase.GageCoins = _G.GoonBase.GageCoins or {}
local GageCoins = _G.GoonBase.GageCoins
local ExtendedInv = _G.GoonBase.ExtendedInventory
GageCoins.CoinID = "gage_coin"

-- Hooks
Hooks:Add("ExtendedInventoryInitialized", "ExtendedInventoryInitialized_" .. Mod:ID(), function()
	
	if not ExtendedInv or not GageCoins then
		return
	end

	ExtendedInv:RegisterItem({
		id = GageCoins.CoinID,
		name = "gm_exinv_gage_coin",
		desc = "gm_exinv_gage_coin_desc",
		reserve_text = "gm_exinv_gage_coin_reserve",
		texture = "guis/textures/pd2/blackmarket/icons/cash",
		hide_when_none_in_stock = false,
	})

end)

Hooks:Add("GageAssignmentManagerOnMissionCompleted", "GageAssignmentManagerOnMissionCompleted_" .. Mod:ID(), function(assignment_manager)

	if not ExtendedInv or not GageCoins then
		return
	end

	local self = assignment_manager
	local total_pickup = 0

	if self._progressed_assignments then
		for assignment, value in pairs(self._progressed_assignments) do

			if value > 0 then

				local collected = Application:digest_value(self._global.active_assignments[assignment], false) + value
				local to_aquire = self._tweak_data:get_value(assignment, "aquire") or 1
				while collected >= to_aquire do
					collected = collected - to_aquire
					ExtendedInv:AddItem(GageCoins.CoinID, 1)
				end

			end

			total_pickup = total_pickup + value
		end
	end

end)

Hooks:Add("PlayerProfileGuiObjectPostInit", "PlayerProfileGuiObjectPostInit_" .. Mod:ID(), function( gui, ws )

	if not ExtendedInv or not GageCoins or not gui._panel then
		return
	end
	if not ExtendedInv:HasItem( GageCoins.CoinID ) then
		return
	end

	local offshore_text = nil
	for k, v in pairs( gui._panel:children() ) do
		if v.text then
			if string.match( tostring(v:text()), tostring(managers.experience:cash_string(managers.money:offshore())) ) then
				offshore_text = v
			end
		end
	end

	if offshore_text then

		local font = tweak_data.menu.pd2_small_font
		local font_size = tweak_data.menu.pd2_small_font_size
		local gage_coins_text = gui._panel:text({
			text = gui:get_text("gm_exinv_gage_coin_plural") .. ": " .. ExtendedInv:GetItem( GageCoins.CoinID ).amount,
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		gui:_make_fine_text(gage_coins_text)
		gage_coins_text:set_left( math.round(offshore_text:left()) )
		gage_coins_text:set_top( math.round(offshore_text:bottom()) )

		local skillpoints = managers.skilltree:points()
		local skill_text, skill_icon, skill_glow

		if skillpoints > 0 then

			for k, v in pairs( gui._panel:children() ) do

				if v.text then
					local skillpoint_text = gui:get_text("menu_spendable_skill_points", { points = tostring(skillpoints) })
					if string.match( tostring(v:text()), tostring(skillpoint_text) ) then
						skill_text = v
					end
				end

				if v.texture_name then
					local tex_name = v:texture_name()
					if tex_name == Idstring("guis/textures/pd2/shared_skillpoint_symbol") then
						skill_icon = v
					end
					if tex_name == Idstring("guis/textures/pd2/crimenet_marker_glow") then
						skill_glow = v
					end
				end

			end

			skill_text:set_top(math.round(gage_coins_text:bottom()))
			if skill_icon then
				skill_icon:set_center_y(skill_text:center_y() + 1)
			end
			if skill_glow then
				skill_glow:set_center_y(skill_icon:center_y())
			end

		end

	end

end)

Hooks:Add("WalletGuiObjectOnSetWallet", "WalletGuiObjectOnSetWallet_" .. Mod:ID(), function( panel, layer )

	if not ExtendedInv or not GageCoins then
		return
	end

	local gage_coins_icon = Global.wallet_panel:bitmap({
		name = "gage_coins_icon",
		texture = "guis/textures/pd2/shared_wallet_symbol"
	})

	local text = tostring( ExtendedInv:GetItem( GageCoins.CoinID ).amount )
	local gage_coins_text = Global.wallet_panel:text({
		name = "gage_coins_text",
		text = text,
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})
	
	local align_object = Global.wallet_panel:child("wallet_skillpoint_text")
	gage_coins_icon:set_leftbottom( align_object:right() + 8, Global.wallet_panel:h() - 2 )
	gage_coins_text:set_left(gage_coins_icon:right() + 2)
	gage_coins_text:set_center_y(gage_coins_icon:center_y())
	gage_coins_text:set_y( math.round(gage_coins_icon:y() - 2) )

end)

Hooks:Add("WalletGuiObjectOnRefresh", "WalletGuiObjectOnRefresh_" .. Mod:ID(), function()

	if Global.wallet_panel then

		local text = tostring( ExtendedInv:GetItem( GageCoins.CoinID ).amount )
		local gage_coins_icon = Global.wallet_panel:child("gage_coins_icon")
		local gage_coins_text = Global.wallet_panel:child("gage_coins_text")
		local align_object = Global.wallet_panel:child("wallet_skillpoint_text")

		gage_coins_icon:set_leftbottom( align_object:right() + 8, Global.wallet_panel:h() - 2 )
		gage_coins_text:set_text( text )
		gage_coins_text:set_left(gage_coins_icon:right() + 2)
		gage_coins_text:set_center_y(gage_coins_icon:center_y())
		gage_coins_text:set_y( math.round(gage_coins_icon:y() - 2) )

	end

end)

Hooks:Add("WalletGuiObjectSetObjectVisible", "WalletGuiObjectSetObjectVisible_" .. Mod:ID(), function()

	if Global.wallet_panel then

		local gage_coins_icon = Global.wallet_panel:child("gage_coins_icon")
		local gage_coins_text = Global.wallet_panel:child("gage_coins_text")
		local money_icon = Global.wallet_panel:child("wallet_money_icon")

		if gage_coins_icon then
			gage_coins_icon:set_visible( money_icon:visible() )
		end
		if gage_coins_text then
			gage_coins_text:set_visible( money_icon:visible() )
		end

	end

end)
