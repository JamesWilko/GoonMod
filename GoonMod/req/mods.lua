
_G.GoonBase.Mods = _G.GoonBase.Mods or {}
local Mods = _G.GoonBase.Mods
Mods.MenuID = "goonbase_mods_menu"
Mods.LoadedMods = Mods.LoadedMods or {}
Mods.EnabledMods = Mods.EnabledMods or {}
Mods._cached_localization = Mods._cached_localization or {}

-- Menus
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then
		MenuHelper:NewMenu( Mods.MenuID )
	end

end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then

		-- Options menu
		MenuHelper:AddButton({
			id = "goonbase_mods_menu_button",
			title = "gm_mods_menu",
			desc = "gm_mods_menu_desc",
			next_node = Mods.MenuID,
			menu_id = "goonbase_options_menu",
			priority = 1002,
		})

		MenuHelper:AddDivider({
			id = "goonbase_mods_menu_divider",
			menu_id = "goonbase_options_menu",
			size = 16,
			priority = 1001,
		})

		-- Mods Menu
		MenuCallbackHandler.open_mods_menu_help = function(this, item)
			Mods:ShowHelpMenu()
		end

		MenuHelper:AddButton({
			id = "goonbase_mods_menu_help_button",
			title = "gm_mods_menu_info",
			desc = "gm_mods_menu_info_desc",
			callback = "open_mods_menu_help",
			menu_id = Mods.MenuID,
			priority = 1004,
		})

		MenuHelper:AddDivider({
			id = "goonbase_mods_menu_help_divider",
			menu_id = Mods.MenuID,
			size = 16,
			priority = 1003,
		})

		-- Add mods
		Mods:AddLoadedModsToMenu()

	end

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_ModsMenu", function( menu_manager, menu_nodes )

	if menu_nodes.main ~= nil or menu_nodes.lobby ~= nil then

		MenuCallbackHandler.GoonModFocusModsMenu = function( node, focus )
			if focus then
				Mods:ShowModManagerMenu()
			else
				Mods:HideModManagerMenu()
			end
		end

		local menu_data = {
			focus_changed_callback = "GoonModFocusModsMenu"
		}
		menu_nodes[Mods.MenuID] = MenuHelper:BuildMenu( Mods.MenuID, menu_data )
		Mods:VerifyAllRequirements()

	end

end)

function Mods:ShowModManagerMenu()

	if not managers.menu_component or not managers.gui_data then
		return
	end
	if managers.menu_component._contract_gui then
		managers.menu_component:close_contract_gui()
	end

	self._fullscreen_ws = self._fullscreen_ws or managers.gui_data:create_fullscreen_16_9_workspace()
	if not self._darken_bg then
		self._darken_bg = self._fullscreen_ws:panel():rect({
			color = Color.black:with_alpha(0.4),
			layer = 50
		})
	end
	self._darken_bg:set_alpha(1)

end

function Mods:HideModManagerMenu()

	if self._darken_bg then
		self._darken_bg:set_alpha(0)
	end

end

function Mods:ShowHelpMenu()

	local title = managers.localization:text("gm_mods_info_popup_title")
	local message = managers.localization:text("gm_mods_info_popup_message")
	local menu_options = {}
	menu_options[1] = {
		text = managers.localization:text("gm_mods_info_popup_accept"),
		is_cancel_button = true
	}
	local help_menu = QuickMenu:new( title, message, menu_options, true )

end

function Mods:RegisterMod( mod )
	Print("[Mods] Registering mod '" .. mod:ID() .. "'")
	Mods.LoadedMods[ mod:ID() ] = mod
end

function Mods:LoadMods()

	if GoonBase.SupportedVersion then

		GoonBase.ModFiles = {}
		for k, v in pairs( GoonBase.ModsFolders ) do
			local path = GoonBase.Path .. v
			for x, y in pairs( file.GetFiles(path) ) do
				table.insert( GoonBase.ModFiles, path .. y )
			end
		end

		for k, v in pairs( GoonBase.ModFiles ) do
			SafeDoFile( v )
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

	if not GoonBase.SupportedVersion then
		MenuHelper:AddButton({
			id = "goonbase_mods_menu_mods_disabled",
			title = "gm_mods_menu_disabled",
			desc = "gm_mods_menu_disabled_desc",
			disabled = true,
			menu_id = Mods.MenuID,
			priority = 1000,
		})
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
Hooks:Add("GoonBaseLoadMods", "GoonBaseLoadMods_ModLoader", function()

	Print("[Mods] Loading Mods")
	Mods:LoadEnabledMods()
	Mods:LoadMods()

	Hooks:Call("GoonBaseRegisterMods")

	Print("[Mods] Setting up mods")
	Mods:SetupMods()

end)

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ModLoader", function(loc)

	for k, v in pairs( Mods._cached_localization ) do
		for x, y in pairs( v ) do
			loc:add_localized_strings({
				[x] = y,
			})
		end
	end

	Mods._cached_localization = {}

end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_GoonMod", function( menu_manager, menu, position )

	if menu == "menu_main" then
		if not GoonBase.SupportedVersion then

			local id = "goonmod_mod_disabled_game_update"
			local title = managers.localization:text("gm_notify_disable_game_update")
			local message = managers.localization:text("gm_notify_disable_game_update_message")
			local priority = 901

			NotificationsManager:AddNotification( id, title, message, priority )

		end
	end

end)

-- Base Mod Definition
BaseMod = class()
BaseMod.id = "BaseMod"
BaseMod.Name = "Base Modification"
BaseMod.Desc = "The Base Modification"
BaseMod.MenuPrefix = "gm_mods_toggle_"
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
	self.DescOrig = self.Desc
	local tbl = {
		[ self:NameKey() ] = self:GetName(),
		[ self:DescKey() ] = self:GetDesc()
	}
	table.insert( Mods._cached_localization, tbl )
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
	MenuHelper:AddToggle({
		id = menu_name,
		title = self:NameKey(),
		desc = self:DescKey(),
		callback = menu_name,
		value = self:IsEnabled(),
		disabled_color = Color( 1.0, 0.3, 0.3, 0.3 ),
		menu_id = Mods.MenuID,
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
	if not enabled and self:IsEnabled() then
		Mods:EnableMod( self, false )
	end
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
	managers.localization:add_localized_strings({
		[ self:DescKey()  ] = self.DescOrig,
	})
end

function BaseMod:ModifyLocalizationDescWithRequirements(enabled)

	if enabled then
		return
	end

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

	managers.localization:add_localized_strings({
		[ self:DescKey()  ] = str
	})

end

function BaseMod:ModifyLocalizationDescWithIncompatibilities(enabled)

	if enabled then
		return
	end

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

	managers.localization:add_localized_strings({
		[ self:DescKey()  ] = str
	})

end

function BaseMod:SetEnabledModMenuItem(enabled)

	local menu = MenuHelper:GetMenu( Mods.MenuID )
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
