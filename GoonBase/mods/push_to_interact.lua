----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local interact_menu_id = "goonbase_pushtointeract_menu"

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "PushToInteract"
Mod.Name = "Push to Interact"
Mod.Desc = "Push interact key to toggle interacting with an object"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Push to Interact
_G.GoonBase.PushToInteract = _G.GoonBase.PushToInteract or {}
local PushToInteract = _G.GoonBase.PushToInteract

-- Options
if not GoonBase.Options.PushToInteract then
	GoonBase.Options.PushToInteract = {}
	GoonBase.Options.PushToInteract.Enabled = true
	GoonBase.Options.PushToInteract.GraceTime = 0.2
	GoonBase.Options.PushToInteract.ShowHelper = false
end

-- Localization
local Localization = GoonBase.Localization
Localization.OptionsMenu_PushInteractSubmenuTitle = "Push to Interact"
Localization.OptionsMenu_PushInteractSubmenuDesc = "Change settings for Push to Interact"
Localization.OptionsMenu_PushInteractEnableTitle = "Enable Push to Interact"
Localization.OptionsMenu_PushInteractEnableDesc = "Enable Push to Interact, pushing the interact button will automatically hold the button until it is pushed again"
Localization.OptionsMenu_PushInteractTimeTitle = "Push Grace Period"
Localization.OptionsMenu_PushInteractTimeDesc = "Grace period of the push in seconds. Push-to-interact will only take effect if the button is held for this long"
Localization.OptionsMenu_PushInteractHelperTitle = "Enable Helper Indicator"
Localization.OptionsMenu_PushInteractHelperDesc = "Show a blue outline around the interaction timer when Push-to-interact will hold the interaction for you"
Localization.OptionsMenu_PushInteractTimeDesc_Default = Localization.OptionsMenu_PushInteractTimeDesc

-- Functions
function PushToInteract:CreateInteractionIndicator()

	if not self._workspace and GoonBase.Options.PushToInteract.ShowHelper then

		self._workspace = Overlay:newgui():create_screen_workspace(0, 0, 1, 1)
		self._interaction_radius = self._workspace:panel():w() / 12
		self._interaction_circle = CircleBitmapGuiObject:new(self._workspace:panel(), {
			use_bg = false,
			radius = self._interaction_radius,
			sides = 64,
			current = 64,
			total = 64,
			color = Color.white:with_alpha(1),
			blend_mode = "add",
			image = "guis/textures/pd2/specialization/progress_ring",
			layer = 2,
			x = self._workspace:panel():w() / 2 - self._interaction_radius - 0.5,
			y = self._workspace:panel():h() / 2 - self._interaction_radius - 0.5,
		})
		self._interaction_circle:set_current( 0 )

	end

end

function PushToInteract:DestroyWorkspace()
	
	if self._workspace and alive(self._workspace) then
		Overlay:newgui():destroy_workspace(self._workspace)
		self._workspace = nil
	end

end

function PushToInteract:ShowInteractionHelper()
	if not GoonBase.Options.PushToInteract.ShowHelper then
		return
	end
	if not self._interaction_circle then
		PushToInteract:CreateInteractionIndicator()
	end
	self._interaction_circle:set_current( 1 )
end

function PushToInteract:UpdateInteractionHelper(t)
	if not GoonBase.Options.PushToInteract.ShowHelper then
		return
	end
	if not self._interaction_circle then
		PushToInteract:CreateInteractionIndicator()
	end
	self._interaction_circle:set_current( t )
end

function PushToInteract:HideInteractionHelper()
	if not GoonBase.Options.PushToInteract.ShowHelper then
		return
	end
	if not self._interaction_circle then
		PushToInteract:CreateInteractionIndicator()
	end
	self._interaction_circle:set_current( 0 )
end

-- Hooks
Hooks:Add("PlayerStandardCheckActionInteract", "PlayerStandardCheckActionInteract_PushToInteract", function(ply, t, input)

	if not GoonBase.Options.PushToInteract.Enabled then
		return
	end

	local grace_time = (GoonBase.Options.PushToInteract.GraceTime or 0.2)
	ply._last_interact_press_t = ply._last_interact_press_t or 0

	if input.btn_interact_press then

		ply._last_interact_press_t = t

		if ply:_interacting() then
			ply:_interupt_action_interact()
			PushToInteract:HideInteractionHelper()
			return false
		end

	elseif input.btn_interact_release then

		local dt = t - ply._last_interact_press_t
		local always_use = grace_time < 0.001
		if always_use or dt >= grace_time then
			return false
		end

	end

	if ply._last_interact_press_t and ply:_interacting() then
		local dt = t - ply._last_interact_press_t
		if dt >= grace_time then

			if ply._interact_expire_t then
				local x = (t - ply._last_interact_press_t) / (ply._interact_expire_t - ply._last_interact_press_t)
				PushToInteract:UpdateInteractionHelper( x )
			else
				PushToInteract:ShowInteractionHelper()
			end

		else
			PushToInteract:HideInteractionHelper()
		end
	else
		PushToInteract:HideInteractionHelper()
	end

end)

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_PushToInteract", function( menu_manager, menu_nodes )
	GoonBase.MenuHelper:NewMenu( interact_menu_id )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_PushToInteract", function( menu_manager )

	-- Add corpse mod menu button
	GoonBase.MenuHelper:AddButton({
		id = "pushtointeract_mod_menu_button",
		title = "OptionsMenu_PushInteractSubmenuTitle",
		desc = "OptionsMenu_PushInteractSubmenuDesc",
		next_node = interact_menu_id,
		menu_id = "goonbase_options_menu"
	})

	-- Callbacks
	MenuCallbackHandler.toggle_pushtointeract = function(this, item)
		GoonBase.Options.PushToInteract.Enabled = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.set_pushtointeract_grace_period = function(this, item)
		GoonBase.Options.PushToInteract.GraceTime = tonumber( item:value() )
		GoonBase.Options:Save()
	end

	MenuCallbackHandler.toggle_pushtointeract_helper = function(this, item)
		GoonBase.Options.PushToInteract.ShowHelper = item:value() == "on" and true or false
		GoonBase.Options:Save()
	end

	-- Menu
	GoonBase.MenuHelper:AddToggle({
		id = "pushtointeract_toggle",
		title = "OptionsMenu_PushInteractEnableTitle",
		desc = "OptionsMenu_PushInteractEnableDesc",
		callback = "toggle_pushtointeract",
		value = GoonBase.Options.PushToInteract.Enabled,
		menu_id = interact_menu_id,
		priority = 50
	})

	GoonBase.MenuHelper:AddSlider({
		id = "pushtointeract_timer_slider",
		title = "OptionsMenu_PushInteractTimeTitle",
		desc = "OptionsMenu_PushInteractTimeDesc",
		callback = "set_pushtointeract_grace_period",
		value = GoonBase.Options.PushToInteract.GraceTime,
		min = 0,
		max = 2,
		step = 0.01,
		show_value = true,
		menu_id = interact_menu_id,
		priority = 49
	})

	GoonBase.MenuHelper:AddToggle({
		id = "pushtointeract_toggle_showhelper",
		title = "OptionsMenu_PushInteractHelperTitle",
		desc = "OptionsMenu_PushInteractHelperDesc",
		callback = "toggle_pushtointeract_helper",
		value = GoonBase.Options.PushToInteract.ShowHelper or false,
		menu_id = interact_menu_id,
		priority = 48
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_PushToInteract", function( menu_manager, mainmenu_nodes )
	mainmenu_nodes[interact_menu_id] = GoonBase.MenuHelper:BuildMenu( interact_menu_id )
end)
-- END OF FILE
