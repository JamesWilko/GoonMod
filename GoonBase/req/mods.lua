----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/16/2014 9:49:42 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.Mods = _G.GoonBase.Mods or {}
local Mods = _G.GoonBase.Mods
Mods.MenuID = "goonbase_mods_menu"
Mods.LoadedMods = Mods.LoadedMods or {}
Mods.EnabledMods = Mods.EnabledMods or {}

-- Localization
local Localization = GoonBase.Localization
Localization.ModsMenu_Button = "Modifications"
Localization.ModsMenu_ButtonDesc = "Control which modifications are loaded"
Localization.ModsMenu_ButtonInfoButton = "Help"
Localization.ModsMenu_ButtonInfoButtonDesc = "Show the modifications menu help"
Localization.ModsMenu_ButtonInfoButtonTitle = "Modifications"
Localization.ModsMenu_ButtonInfoButtonMessage = [[This menu allows you to enable and disable specific modifications in GoonMod. If a modification is enabled, it will load itself when Payday 2 is launched.

Modifications highlighted in red require another modification to be enabled before they can be loaded, these modifications will be shown at the top of the screen.

Once a modification is enabled/disabled, you will be required to restart your game to ensure that the modifications fully and successfully load or unload.]]
Localization.ModsMenu_ButtonInfoButtonAccept = "Close"

-- Menus
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then
		GoonBase.MenuHelper:NewMenu( Mods.MenuID )
	end

end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then

		-- Options menu
		GoonBase.MenuHelper:AddButton({
			id = "goonbase_mods_menu_button",
			title = "ModsMenu_Button",
			desc = "ModsMenu_ButtonDesc",
			next_node = Mods.MenuID,
			menu_id = "goonbase_options_menu",
			priority = 901,
		})

		GoonBase.MenuHelper:AddDivider({
			id = "goonbase_mods_menu_divider",
			menu_id = "goonbase_options_menu",
			size = 16,
			priority = 900,
		})

		-- Mods Menu
		MenuCallbackHandler.open_mods_menu_help = function(this, item)
			Mods:ShowHelpMenu()
		end

		GoonBase.MenuHelper:AddButton({
			id = "goonbase_mods_menu_help_button",
			title = "ModsMenu_ButtonInfoButton",
			desc = "ModsMenu_ButtonInfoButtonDesc",
			callback = "open_mods_menu_help",
			menu_id = Mods.MenuID,
			priority = 1000,
		})

		GoonBase.MenuHelper:AddDivider({
			id = "goonbase_mods_menu_help_divider",
			menu_id = Mods.MenuID,
			size = 16,
			priority = 999,
		})

		-- Add mods
		Mods:AddLoadedModsToMenu()

	end

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then

		menu_nodes[Mods.MenuID] = GoonBase.MenuHelper:BuildMenu( Mods.MenuID )
		Mods:VerifyAllRequirements()

	end

end)

function Mods:ShowHelpMenu()

	local title = managers.localization:text("ModsMenu_ButtonInfoButtonTitle")
	local message = managers.localization:text("ModsMenu_ButtonInfoButtonMessage")
	local menu_options = {}
	menu_options[1] = { text = managers.localization:text("ModsMenu_ButtonInfoButtonAccept"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menu_options)
	tradeMenu:Show()

end

function Mods:RegisterMod( mod )
	Print("[Mods] Registering mod '" .. mod:ID() .. "'")
	Mods.LoadedMods[ mod:ID() ] = mod
end

function Mods:LoadMods()

	if GoonBase.SupportedVersion then
		for k, v in pairs( GoonBase.ModFiles ) do
			dofile( GoonBase.Path .. v )
		end
	end

end

function Mods:SetupMods()

	for k, v in pairs( Mods.LoadedMods ) do
		v:Setup()
	end

end

function Mods:AddLoadedModsToMenu()

	for k, v in pairs( Mods.LoadedMods ) do
		if v.HideInOptionsMenu ~= true then
			v:SetupMenu()
		end
	end

end

function Mods:EnableMod( mod, enabled )
	if enabled == nil then
		enabled = true
	end
	Mods.EnabledMods = Mods.EnabledMods or {}
	Mods.EnabledMods[ mod:ID() ] = enabled
end

function Mods:LoadEnabledMods()
	Mods.EnabledMods = GoonBase.Options.EnabledMods or {}
end

function Mods:SaveEnabledMods()
	GoonBase.Options.EnabledMods = Mods.EnabledMods
	GoonBase.Options:Save()
end

function Mods:VerifyAllRequirements()
	for k, v in pairs( Mods.LoadedMods ) do
		v:VerifyRequirements()
	end
end

function Mods:IsEnabled( mod_id )
	if Mods.EnabledMods ~= nil and Mods.EnabledMods[mod_id] ~= nil then
		return Mods.EnabledMods[mod_id]:IsEnabled()
	end
	return false
end

-- Hooks
Hooks:RegisterHook("GoonBaseRegisterMods")
Hooks:Add("GoonBasePostLoadMods", "GoonBasePostLoadMods_Mods", function()

	Print("[Mods] Loading Mods")
	Mods:LoadEnabledMods()
	Mods:LoadMods()

	Hooks:Call("GoonBaseRegisterMods")

	Print("[Mods] Setting up mods")
	Mods:SetupMods()

end)

-- Base Mod Definition
BaseMod = class()
BaseMod.id = "BaseMod"
BaseMod.Name = "Base Modification"
BaseMod.Desc = "The Base Modification"
BaseMod.MenuPrefix = "toggle_mod_"
BaseMod.MenuSuffix = ""
BaseMod.HideInOptionsMenu = false
BaseMod.Requirements = {}
BaseMod.Incompatibilities = {}
BaseMod.Path = nil
BaseMod.Priority = 0
BaseMod.EnabledByDefault = false

function BaseMod:ID()
	return self.id
end

function BaseMod:IsEnabled()
	local requirements = self:RequirementsAreEnabled()
	local incompatibles = self:IncompatibilitiesAreDisabled()
	if not requirements or not incompatibles then
		return false
	end
	if Mods.EnabledMods[ self:ID() ] == nil then
		return self.EnabledByDefault
	end
	return Mods.EnabledMods[ self:ID() ]
end

function BaseMod:GetName()
	return self.Name
end

function BaseMod:GetDesc()
	return self.Desc
end

function BaseMod:NameKey()
	return self.MenuPrefix .. self:ID() .. self.MenuSuffix
end

function BaseMod:DescKey()
	return self.MenuPrefix .. self:ID() .. self.MenuSuffix .. "_desc"
end

function BaseMod:SetPath(path)
	self.Path = path
end

function BaseMod:GetPath()
	return self.Path
end

function BaseMod:GetRequirements()
	return self.Requirements
end

function BaseMod:GetIncompatibilities()
	return self.Incompatibilities
end

function BaseMod:Setup()
	self:SetupLocalization()
end

function BaseMod:SetupLocalization()
	local Localization = _G.GoonBase.Localization
	Localization[ self:NameKey() ] = self:GetName()
	self.DescOrig = self.Desc
	Localization[ self:DescKey() ] = self:GetDesc()
end

function BaseMod:SetupMenu()

	-- Callback
	local menu_name = self.MenuPrefix .. self:ID() .. self.MenuSuffix
	MenuCallbackHandler[menu_name] = function(this, item)
		
		local psuccess, perror = pcall(function()

			local enabled = item:value() == "on" and true or false

			Mods:EnableMod( self, enabled )
			if enabled then
				self:OnEnabled()
			else
				self:OnDisabled()
			end

			Mods:SaveEnabledMods()
			Mods:VerifyAllRequirements()

		end)
		if not psuccess then
			Print("[Error] " .. perror)
		end

	end

	-- Add to menu
	GoonBase.MenuHelper:AddToggle({
		id = menu_name,
		title = self:NameKey(),
		desc = self:DescKey(),
		callback = menu_name,
		value = self:IsEnabled(),
		disabled_color = Color( 0.8, 0.3, 0.3, 0.3 ),
		menu_id = Mods.MenuID,
		priority = self.Priority or 0
	})

end

function BaseMod:OnEnabled()
	Print("[Mods] Mod '" .. self:ID() .. "' enabled")
end

function BaseMod:OnDisabled()
	Print("[Mods] Mod '" .. self:ID() .. "' disabled")
end

function BaseMod:VerifyRequirements()
	self:ResetLocalization()
	local enabled = (self:IncompatibilitiesAreDisabled() and self:RequirementsAreEnabled()) and true or false
	self:SetEnabledModMenuItem( enabled )
end

function BaseMod:RequirementsAreEnabled()

	local enabled = true
	for k, v in pairs( self:GetRequirements() ) do
		if v ~= nil and Mods.LoadedMods[v] ~= nil and not Mods.LoadedMods[v]:IsEnabled() then
			enabled = false
		end
	end

	self:ModifyLocalizationDescWithRequirements(enabled)
	return enabled

end

function BaseMod:IncompatibilitiesAreDisabled()

	local enabled = true
	for k, v in pairs( self:GetIncompatibilities() ) do
		if Mods.LoadedMods[v]:IsEnabled() then
			enabled = false
		end
	end

	self:ModifyLocalizationDescWithIncompatibilities(enabled)
	return enabled

end

function BaseMod:ResetLocalization()
	local Localization = _G.GoonBase.Localization
	Localization[ self:DescKey() ] = self.DescOrig
end

function BaseMod:ModifyLocalizationDescWithRequirements(enabled)

	if enabled then
		return
	end

	local Localization = _G.GoonBase.Localization
	local str = self.DescOrig

	local reqsStr = ""
	for k, v in pairs( self:GetRequirements() ) do
		if not Mods.LoadedMods[v]:IsEnabled() then
			if reqsStr ~= "" then
				reqsStr = reqsStr .. ", "
			end
			reqsStr = reqsStr .. Mods.LoadedMods[v]:GetName()
		end
	end

	str = str .. "\n"
	str = str .. "Requires: " .. reqsStr

	Localization[ self:DescKey() ] = str

end

function BaseMod:ModifyLocalizationDescWithIncompatibilities(enabled)

	if enabled then
		return
	end

	local Localization = _G.GoonBase.Localization
	local str = self.DescOrig

	local reqsStr = ""
	for k, v in pairs( self:GetIncompatibilities() ) do
		if Mods.LoadedMods[v]:IsEnabled() then
			if reqsStr ~= "" then
				reqsStr = reqsStr .. ", "
			end
			reqsStr = reqsStr .. Mods.LoadedMods[v]:GetName()
		end
	end

	str = str .. "\n"
	str = str .. "Incompatible with: " .. reqsStr

	Localization[ self:DescKey() ] = str

end

function BaseMod:SetEnabledModMenuItem(enabled)

	local menu = GoonBase.MenuHelper:GetMenu( Mods.MenuID )
	for k, v in pairs( menu["_items"] ) do
		local menu_name = v["_parameters"]["name"]:gsub(self.MenuPrefix, "")
		if menu_name == self:ID() then
			v:set_enabled( enabled )
			if not enabled and v:value() == "on" then
				v:set_value( "off" )
			end
			v:dirty()
		end
	end
	
end

-- END OF FILE
