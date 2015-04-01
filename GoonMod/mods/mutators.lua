
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GameplayMutators"
Mod.Name = "Mutators"
Mod.Desc = "Micro-gameplay mods that give you new gameplay modes and experiences"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mutators
_G.GoonBase.Mutators = _G.GoonBase.Mutators or {}
local Mutators = _G.GoonBase.Mutators
Mutators.MenuID = "goonbase_mutators_menu"
Mutators.MatchmakingData = "gb_mutators"
Mutators.LoadedMutators = Mutators.LoadedMutators or {}
Mutators.ActiveMutators = Mutators.ActiveMutators or {}
Mutators.ClientMutatorCheck = Mutators.ClientMutatorCheck or {}
Mutators.NetworkTimeoutTime = 3
Mutators.MutatorUnreportedStatus = "unreported"

-- Network
Mutators.Network = {}
Mutators.Network.ClearMutators = "ClearMutators"
Mutators.Network.EnableMutator = "EnableMutator"
Mutators.Network.DisableMutator = "DisableMutator"
Mutators.Network.MutatorCheck = "CheckMutator"
Mutators.Network.MutatorCheckSuccess = "CheckMutatorSuccess"
Mutators.Network.MutatorCheckFailure = "CheckMutatorFailure"

-- Paths
Mutators.MutatorsPath = GoonBase.Path .. "mutators/"
Mutators.MenuPrefix = "toggle_mutator_"

-- Options
if GoonBase.Options.Mutators == nil then
	GoonBase.Options.Mutators = {}
	GoonBase.Options.Mutators.RandomizerMode = 1
end

-- Add mutators menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_MutatorsMenu", function(menu_manager, menu_nodes)

	-- Create menu
	MenuHelper:NewMenu( Mutators.MenuID )

	-- Add help button
	MenuCallbackHandler.open_mutators_menu_help = function(this, item)
		Mutators:ShowHelpMenu()
	end

	MenuCallbackHandler.mutators_set_randomizer_mode = function(this, item)
		GoonBase.Options.Mutators.RandomizerMode = tonumber(item:value())
		GoonBase.Options:Save()
	end

	MenuHelper:AddButton({
		id = "goonbase_mutators_menu_help_button",
		title = "Mutators_HelpButton",
		desc = "Mutators_HelpButtonDesc",
		callback = "open_mutators_menu_help",
		menu_id = Mutators.MenuID,
		priority = 1003,
	})

	MenuHelper:AddDivider({
		id = "goonbase_mutators_menu_help_divider",
		menu_id = Mutators.MenuID,
		size = 8,
		priority = 1002,
	})

	MenuHelper:AddMultipleChoice({
		id = "goonbase_mutators_menu_randomizer",
		title = "Randomizer_Name",
		desc = "Randomizer_Desc",
		callback = "mutators_set_randomizer_mode",
		menu_id = Mutators.MenuID,
		priority = 1001,
		items = {
			[1] = "Randomizer_Off",
			[2] = "Randomizer_UpTo1",
			[3] = "Randomizer_UpTo2",
			[4] = "Randomizer_UpTo3",
			[5] = "Randomizer_UpTo4",
			[6] = "Randomizer_UpTo5",
		},
		value = GoonBase.Options.Mutators.RandomizerMode or 1,
	})

	MenuHelper:AddDivider({
		id = "goonbase_mutators_menu_help_divider2",
		menu_id = Mutators.MenuID,
		size = 8,
		priority = 1000,
	})

	-- Add mutators to menu
	Mutators:AddLoadedMutatorsToMenu()
	
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_MutatorsMenu", function(menu_manager, menu_nodes)

	MenuCallbackHandler.GoonModFocusMutatorsMenu = function( node, focus )
		if focus then
			Mutators:ShowMutatorsMenu()
		else
			Mutators:HideMutatorsMenu()
		end
	end

	-- Build menu
	local menu_id = Mutators.MenuID
	local menu_data = {
		focus_changed_callback = "GoonModFocusMutatorsMenu"
	}
	menu_nodes[menu_id] = MenuHelper:BuildMenu( menu_id, menu_data )

	-- Add to main menu and lobby only
	if menu_nodes.main ~= nil then
		MenuHelper:AddMenuItem( menu_nodes.main, menu_id, "Mutators_OptionsName", "Mutators_OptionsDesc", "safehouse", "after" )
	end
	if menu_nodes.lobby ~= nil then
		MenuHelper:AddMenuItem( menu_nodes.lobby, menu_id, "Mutators_OptionsName", "Mutators_OptionsDesc", "skilltree", "after" )
	end

	-- Add to ingame menu
	if menu_nodes.pause ~= nil then
		MenuHelper:AddMenuItem( menu_nodes.pause, menu_id, "Mutators_OptionsIngameName", "Mutators_OptionsIngameDesc", "options", "after" )
	end
	
	-- Verify incompatibilities
	Mutators:VerifyAllIncompatibilities()

end)

-- Mutators Functions
function Mutators:ShowMutatorsMenu()

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

function Mutators:HideMutatorsMenu()

	if self._darken_bg then
		self._darken_bg:set_alpha(0)
	end

end

function Mutators:ShowHelpMenu()

	local title = managers.localization:text("Mutators_HelpTitle")
	local message = managers.localization:text("Mutators_HelpMessage")
	local menu_options = {}
	menu_options[1] = { text = managers.localization:text("Mutators_HelpAccept"), is_cancel_button = true }
	local help_menu = QuickMenu:new(title, message, menu_options, true)

end

function Mutators:LoadMutators()
	
	local files = file.GetFiles( Mutators.MutatorsPath )
	if files then
		for k, v in pairs( files ) do
			SafeDoFile( Mutators.MutatorsPath .. v )
		end
	end

end

function Mutators:RegisterMutator(mutator)
	Print("[Mutators] Registering mutator '" .. mutator:ID() .. "'")
	self.LoadedMutators[ mutator:ID() ] = mutator
end

function Mutators:SetupMutatorsLocalization()
	for k, v in pairs( Mutators.LoadedMutators ) do
		v:SetupLocalization()
	end
end

function Mutators:RegisterLocalization( key, text )

	if not Mutators._cached_localization then
		Mutators._cached_localization = {}
	end
	Mutators._cached_localization[key] = text

end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_" .. Mod:ID(), function(loc)

	for k, v in pairs( Mutators._cached_localization ) do
		loc:add_localized_strings({
			[k] = v,
		})
	end

	Mutators._cached_localization = {}

end)

function Mutators:SetupMutators()

	if Global and Global.game_settings and Global.game_settings.active_mutators then

		for k, v in pairs( Global.game_settings.active_mutators ) do
			if v and Mutators.LoadedMutators[k] then
				Mutators.LoadedMutators[k]:Setup()
			end
		end

	else

		for k, v in pairs( Mutators.LoadedMutators ) do
			v:Setup()
		end

	end

end

function Mutators:AddLoadedMutatorsToMenu()

	for k, v in pairs( Mutators.LoadedMutators ) do
		if v.HideInOptionsMenu ~= true then
			v:SetupMenu()
		end
	end

end

function Mutators:VerifyAllIncompatibilities()

	for i, mutator in pairs( Mutators.LoadedMutators ) do
		mutator:VerifyIncompatibilities()
	end

end

function Mutators:CheckIncompatibilities( mutator )

	local incompatible_list = mutator:IncompatibleMutators()
	local incompatible = {}
	local num_incompatibilities = 0

	-- Find incompatible mutators
	for k, v in pairs( Mutators.LoadedMutators ) do
		if v:ShouldBeEnabled() and table.contains( incompatible_list, v:ID() ) then
			incompatible[k] = true
			num_incompatibilities = num_incompatibilities + 1
		end
	end

	-- Mutators are all compatible
	if num_incompatibilities < 1 then
		return true
	end

	-- Incompatible mutators
	return incompatible

end

function Mutators:ShowIncompatibilitiesWindow( mutator, incompatible )

	-- Display incompatible mutators
	local incompatible_str = ""
	for k, v in pairs( incompatible ) do

		if incompatible_str ~= "" then
			incompatible_str = incompatible_str .. ", "
		end
		incompatible_str = incompatible_str .. "'" .. Mutators.LoadedMutators[k]:GetLocalizedName() .. "'"

	end

	-- Display
	local title = managers.localization:text("Mutators_IncompatibleTitle")
	local message = managers.localization:text("Mutators_IncompatibleMessage")
	message = message:gsub("{1}", mutator:GetLocalizedName())
	message = message:gsub("{2}", incompatible_str)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Mutators_IncompatibleAccept"),
		is_cancel_button = true
	}
	local menu = QuickMenu:new(title, message, menuOptions, true)

	return false

end

function Mutators:IsRandomizerEnabled()
	return (GoonBase.Options.Mutators.RandomizerMode or 1) > 1
end

function Mutators:GetNumberOfRandomMutations()
	return (GoonBase.Options.Mutators.RandomizerMode or 1) - 1
end

function Mutators:AddRandomizedMutations()

	if Mutators:IsRandomizerEnabled() then

		Print("[Mutators] Randomizing mutators, up to ", Mutators:GetNumberOfRandomMutations())

		if Mutators.ILoadedMutators == nil then
			Mutators.ILoadedMutators = {}
			for k, v in pairs(Mutators.LoadedMutators) do
				table.insert(Mutators.ILoadedMutators, k)
			end
		end

		local random_mutations = {}

		for i = 1, Mutators:GetNumberOfRandomMutations(), 1 do

			local mutation_id = nil
			local attempts = 0
			while mutation_id == nil do

				mutation_id = Mutators.ILoadedMutators[ math.random(1, #Mutators.ILoadedMutators) ]
				if random_mutations[mutation_id] or Mutators.ActiveMutators[mutation_id] or not Mutators.LoadedMutators[mutation_id]:VerifyIncompatibilities(true) then
					mutation_id = nil
				end

				attempts = attempts + 1
				if attempts > 16 then
					mutation_id = nil
					break
				end

			end

			if mutation_id ~= nil then
				local mutation = Mutators.LoadedMutators[mutation_id]
				if mutation:VerifyIncompatibilities(true) then
					mutation:ForceEnable()
				end
			end

		end

	end

end

function Mutators:GetNumberOfActiveMutators()
	local i = 0
	for k, v in pairs( Mutators.ActiveMutators ) do
		i = i + 1
	end
	return i
end

function Mutators:GetNumberOfMutatorsToBeActive()

	local i = 0

	for k, v in pairs( Mutators.LoadedMutators ) do
		if v:ShouldBeEnabled() then
			i = i + 1
		end
	end

	if self:IsRandomizerEnabled() then
		i = i + self:GetNumberOfRandomMutations()
	end

	return i

end

function Mutators:PrintActiveMutators()
	Print("-----")
	Print("Active Mutators:")
	for k, v in pairs( Mutators.ActiveMutators ) do
		Print(k)
	end
	Print("-----")
end

-- Hooks
Hooks:Add("AchievementManagerCheckDisable", "AchievementManagerCheckDisable_Mutators", function(achievement_manager)

	if Utils:IsInGameState() then

		for k, v in pairs( Mutators.LoadedMutators ) do
			if v:ShouldBeEnabled() then
				achievement_manager:DisableAchievements("mutators")
			end
		end

		if Mutators:GetNumberOfActiveMutators() > 0 then
			achievement_manager:DisableAchievements("mutators")
		end

	end

end)

-- Load mutators
Hooks:RegisterHook("GoonBaseRegisterMutators")
Hooks:Add("GoonBasePostLoadedMods", "GoonBasePostLoadedMods_Mutators", function()

	Print("[Mutators] Loading Mutators")
	Mutators:LoadMutators()

	Hooks:Call("GoonBaseRegisterMutators")

	Print("[Mutators] Setting up mutators")
	Mutators:SetupMutatorsLocalization()
	Mutators:SetupMutators()

end)

-- Permission locking
Hooks:Add("PostCreateCrimenetContractGUI", "PostCreateCrimenetContractGUI_Mutators", function( menu, node, gui )

	if Mutators:GetNumberOfMutatorsToBeActive() < 1 then
		return
	end
	if not gui._node then
		return
	end
	if not gui._node._items then
		return
	end

	local items = gui._node._items
	for k, v in pairs( items ) do
		if v._parameters.name == "lobby_permission" then
			local permission = "friends_only"
			v:set_value( permission )
			Global.game_settings.permission = permission
		end
	end

end)

Hooks:Add("MenuCallbackHandlerPreChoseLobbyPermission", "MenuCallbackHandlerPreChoseLobbyPermission_Mutators", function( callback_handler, item )
	return Mutators:ForcePrivateGamesForMutators( item )
end)

Hooks:Add( "MenuCallbackHandlerPreCrimeNetChoseLobbyPermission", "MenuCallbackHandlerPreCrimeNetChoseLobbyPermission_Mutators", function( callback_handler, item )
	return Mutators:ForcePrivateGamesForMutators( item )
end )

function Mutators:ForcePrivateGamesForMutators( item )

	if item:value() == "public" and Mutators:GetNumberOfMutatorsToBeActive() > 0 then
		item:set_value( "friends_only" )
		if Mutators:IsInGame() then
			Mutators:ShowPublicGamesWarningIngame()
			return true
		end
		Mutators:ShowPublicGamesWarningLobby()
		return true
	end

end

function Mutators:ShowPublicGamesWarningLobby()

	local title = managers.localization:text("Mutators_PublicGamesWarning_Title")
	local message = managers.localization:text("Mutators_PublicGamesWarning_Message")
	local menu_options = {}
	menu_options[1] = { text = managers.localization:text("Mutators_PublicGamesWarning_Cancel"), is_cancel_button = true }
	local warning = QuickMenu:new(title, message, menu_options, true)

end

function Mutators:ShowPublicGamesWarningIngame()

	local title = managers.localization:text("Mutators_PublicGamesWarning_Title")
	local message = managers.localization:text("Mutators_PublicGamesWarning_MessageIngame")
	local menu_options = {}
	menu_options[1] = { text = managers.localization:text("Mutators_PublicGamesWarning_Cancel"), is_cancel_button = true }
	local warning = QuickMenu:new(title, message, menu_options, true)

end

function Mutators:IsInGame()
	if not game_state_machine then
		return false
	end
	return string.find( game_state_machine:current_state_name(), "ingame" )
end

-- Network Mutators
Hooks:Add( "MenuCallbackHandlerPreStartTheGame", "MenuCallbackHandlerPreStartTheGame_Mutators", function( callback_handler )

	Mutators.ActiveMutators = {}
	for k, v in pairs( Mutators.LoadedMutators ) do
		if v and v:ShouldBeEnabled() then
			Mutators.ActiveMutators[k] = true
		end
	end

	if not LuaNetworking:IsMultiplayer() or ( LuaNetworking:IsMultiplayer() and LuaNetworking:IsHost() ) then
		Mutators:AddRandomizedMutations()
	end

	if Global and Global.game_settings then

		Global.game_settings.active_mutators = {}
		for k, v in pairs( Mutators.ActiveMutators ) do
			Global.game_settings.active_mutators[k] = true
		end

	end

	if Mutators:CheckNetworkMutators(callback_handler) then

		callback_handler:delay_game_start( "MutatorNetworking" )

		Mutators._game_delay_time = Application:time()
		Mutators.ClientMutatorCheck = {}

		Mutators:ClearClientsNetworkedMutators()
		Mutators:ShowNetworkingMutatorsWindow()

		for k, v in pairs( Mutators.ActiveMutators ) do

			Mutators.ClientMutatorCheck[k] = {}
			for x, y in pairs( LuaNetworking:GetPeers() ) do
				local client_id = y:id()
				Mutators.ClientMutatorCheck[k][client_id] = Mutators.MutatorUnreportedStatus
			end

			Mutators:SendNetworkedMutatorToClients( k, true )
			Mutators:CheckIfClientsHaveMutator( k )
		end

		return true

	end

end )

function Mutators:CheckNetworkMutators( callback_handler )
	if Global.game_settings and not Global.game_settings.single_player then
		if LuaNetworking:IsMultiplayer() and LuaNetworking:IsHost() and LuaNetworking:GetNumberOfPeers() > 0 then
			return true
		end
	end
	return false
end

function Mutators:ShowNetworkingMutatorsWindow()

	local title = managers.localization:text("NetworkedMutators_SendingData_Title")
	local message = managers.localization:text("NetworkedMutators_SendingData_Message")
	local options = {}
	options[1] = {
		text = managers.localization:text("NetworkedMutators_SendingData_Cancel"),
		callback = Mutators.NetworkingMutatorsCancel,
		is_cancel_button = true
	}

	local menu = QuickMenu:new( title, message, options )
	menu.dialog_data.indicator = true
	menu:Show()

	self._open_window = menu

end

function Mutators:DebugForceStartGame()
	MenuCallbackHandler:_start_the_game()
end

function Mutators:DebugReleaseStartDelay()
	MenuCallbackHandler:release_game_start_delay( "MutatorNetworking" )
end

function Mutators:NetworkingMutatorsCancel()
	MenuCallbackHandler:release_game_start_delay( "MutatorNetworking" )
	MenuCallbackHandler._delayed_start_game = false
end

-- Matchmaking
Hooks:Add("NetworkMatchmakingSetAttributes", "NetworkMatchmakingSetAttributes_" .. Mod:ID(), function(matchmaking, settings)

	local mutator_data = ""
	for k, v in pairs( Mutators.ActiveMutators ) do
		mutator_data = mutator_data .. k .. "/"
	end
	if matchmaking and matchmaking._lobby_attributes then
		matchmaking._lobby_attributes[ Mutators.MatchmakingData ] = mutator_data
	end

end)

Hooks:Add("NetworkMatchmakingJoinOKServer", "NetworkMatchmakingJoinOKServer_" .. Mod:ID(), function(matchmaking, room_id, skip_showing_dialog)

	local lobby = Steam:lobby(room_id)
	local mutator_key = lobby:key_value( Mutators.MatchmakingData )
	if mutator_key == "value_missing" or mutator_key == "value_pending" then
		if Global.game_settings and Global.game_settings.active_mutators then
			Global.game_settings.active_mutators = {}
		end
		return
	end

	if Global.game_settings then
		Global.game_settings.active_mutators = {}
	end

	local mutators_data = string.split( mutator_key, "[/]" )
	for k, v in pairs( mutators_data ) do
		if not string.is_nil_or_empty(v) then
			Global.game_settings.active_mutators[v] = true
		end
	end

	Hooks:PreHook( ClientNetworkSession, "on_join_request_cancelled", "NetworkSessionOnJoinRequestCancelled_" .. Mod:ID(), function()
		if Global.game_settings then
			Global.game_settings.active_mutators = {}
		end
	end )

end)

-- Network Messages
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_" .. Mod:ID(), function(sender, messageType, data)

	if messageType == Mutators.Network.ClearMutators then
		Mutators:ClearNetworkedMutators()
	end

	if messageType == Mutators.Network.EnableMutator then
		Mutators:SetNetworkedMutator( data, true )
	end

	if messageType == Mutators.Network.DisableMutator then
		Mutators:SetNetworkedMutator( data, false )
	end

	if messageType == Mutators.Network.MutatorCheck then
		Mutators:CheckIfHasMutator( sender, data )
	end

	if messageType == Mutators.Network.MutatorCheckSuccess then
		Mutators:MarkClientHasMutator( sender, data, true )
	end

	if messageType == Mutators.Network.MutatorCheckFailure then
		Mutators:MarkClientHasMutator( sender, data, false )
	end

end)

function Mutators:ClearClientsNetworkedMutators()
	LuaNetworking:SendToPeers( Mutators.Network.ClearMutators, "" )
end

function Mutators:ClearNetworkedMutators()
	if Global and Global.game_settings then
		Global.game_settings.active_mutators = {}
	end
end

function Mutators:SendNetworkedMutatorToClients( mutator_id, enabled )
	if enabled then
		LuaNetworking:SendToPeers( Mutators.Network.EnableMutator, mutator_id )
	else
		LuaNetworking:SendToPeers( Mutators.Network.DisableMutator, mutator_id )
	end
end

function Mutators:SetNetworkedMutator( mutator_id, enable )
	if Global and Global.game_settings then
		if not Global.game_settings.active_mutators then
			Global.game_settings.active_mutators = {}
		end
		Global.game_settings.active_mutators[mutator_id] = enable
	end
end

function Mutators:CheckIfClientsHaveMutator( mutator_id )
	LuaNetworking:SendToPeers( Mutators.Network.MutatorCheck, mutator_id )
end

function Mutators:CheckIfHasMutator( sender, mutator_id )

	if Mutators.LoadedMutators[ mutator_id ] == nil then
		LuaNetworking:SendToPeer( sender, Mutators.Network.MutatorCheckFailure, mutator_id )
	else
		LuaNetworking:SendToPeer( sender, Mutators.Network.MutatorCheckSuccess, mutator_id )
	end

end

function Mutators:MarkClientHasMutator( client, mutator_id, has_mutator )

	if not Mutators.ClientMutatorCheck then
		Mutators.ClientMutatorCheck = {}
	end

	if not Mutators.ClientMutatorCheck[ mutator_id ] then
		Mutators.ClientMutatorCheck[ mutator_id ] = {}
	end

	Mutators.ClientMutatorCheck[ mutator_id ][ client ] = has_mutator

end

function Mutators:CheckAllClientsHaveReported()

	for mutator_id, mutator in pairs( self.ClientMutatorCheck ) do
		for k, v in pairs( LuaNetworking:GetPeers() ) do
			local client_id = v:id()
			if mutator[ client_id ] == Mutators.MutatorUnreportedStatus then
				return false
			end
		end
	end

	return true

end

Hooks:Add("MenuUpdate", "MenuUpdate_" .. Mod:ID(), function(t, dt)
	Mutators:CheckMutatorTimeout()
end)

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_" .. Mod:ID(), function(t, dt)
	Mutators:CheckMutatorTimeout()
end)

function Mutators:CheckMutatorTimeout()

	if self._game_delay_time then

		local t = Application:time() - self._game_delay_time

		if t > self.NetworkTimeoutTime or self:CheckAllClientsHaveReported() then
			self:CheckAllClientsHaveMutators()
			self._game_delay_time = nil
		end

	end

end

function Mutators:CheckAllClientsHaveMutators()

	if not self.ClientMutatorCheck then
		return
	end

	local missing_mutator = false
	local missing_mutator_text = ""
	local added_missing_mutator_text = ""
	for mutator_id, mutator in pairs( self.ClientMutatorCheck ) do

		if Mutators.LoadedMutators[mutator_id] then

			added_missing_mutator_text = Mutators.LoadedMutators[mutator_id]:GetLocalizedName()
			for client_id, has_mutator in pairs( mutator ) do

				if not has_mutator then

					missing_mutator = true

					if not string.is_nil_or_empty( added_missing_mutator_text ) then
						missing_mutator_text = missing_mutator_text .. "\n" .. added_missing_mutator_text .. ": "
						missing_mutator_text = missing_mutator_text .. LuaNetworking:GetNameFromPeerID(client_id)
						added_missing_mutator_text = ""
					else
						missing_mutator_text = missing_mutator_text .. ", " .. LuaNetworking:GetNameFromPeerID(client_id)
					end

				end

			end
			for k, v in pairs( LuaNetworking:GetPeers() ) do
				local client_id = v:id()
				if not mutator[ client_id ] or mutator[ client_id ] == Mutators.MutatorUnreportedStatus then

					missing_mutator = true

					if not string.is_nil_or_empty( added_missing_mutator_text ) then
						missing_mutator_text = missing_mutator_text .. "\n" .. added_missing_mutator_text .. ": "
						missing_mutator_text = missing_mutator_text .. LuaNetworking:GetNameFromPeerID(client_id)
						added_missing_mutator_text = ""
					else
						missing_mutator_text = missing_mutator_text .. ", " .. LuaNetworking:GetNameFromPeerID(client_id)
					end

				end
			end

		end

	end

	if missing_mutator then

		managers.system_menu:close( self._open_window.dialog_data.id )

		local title = managers.localization:text("MissingMutators_Title")
		local message = managers.localization:text("MissingMutators_Message")
		if not string.is_nil_or_empty( missing_mutator_text ) then
			message  = message .. missing_mutator_text
		end
		local menuOptions = {}
		menuOptions[1] = {
			text = managers.localization:text("MissingMutators_Continue"),
			callback = Mutators.ContinueStartGame,
		}
		menuOptions[2] = {
			text = managers.localization:text("MissingMutators_Cancel"),
			callback = Mutators.NetworkingMutatorsCancel,
			is_cancel_button = true
		}
		local menu = QuickMenu:new(title, message, menuOptions, true)
		self._open_window = menu

	else
		Mutators:ContinueStartGame()
	end

end

function Mutators.ContinueStartGame()
	managers.system_menu:close( Mutators._open_window.dialog_data.id )
	Mutators._open_window = nil
	MenuCallbackHandler:release_game_start_delay( "MutatorNetworking" )
	if Mutators:IsInGame() then
		MenuCallbackHandler:_start_the_game()
	end
end

-- Mission Briefing Screen
Hooks:Add("MissionBriefingGUIPostInit", "MissionBriefingGUIPostInit_" .. Mod:ID(), function(self, saferect_ws, fullrect_ws, node)

	if Mutators:GetNumberOfActiveMutators() > 0 then
		self._mutators_item = MutatorsItem:new(self._panel, utf8.to_upper(managers.localization:text("menu_mutators")), Global.game_settings.single_player and 5 or 6)
		table.insert(self._items, self._mutators_item)
	end

end)

MutatorsItem = {}
Hooks:Add("MissionBriefingGUIPreInit", "MissionBriefingGUIPreInit_" .. Mod:ID(), function(self, saferect_ws, fullrect_ws, node)

	MutatorsItem = class( DescriptionItem )
	MutatorsItem.init = function(self, panel, text, i, saved_descriptions)

		MutatorsItem.super.init(self, panel, text, i)
		if not managers.job:has_active_job() then
			return
		end

		local title_text = self._panel:child("title_text")
		if title_text then
			title_text:set_w( self._panel:w() )
			title_text:set_text( managers.localization:to_upper_text("BriefingMenu_ActiveMutators") )
		end

		local pro_text = self._panel:child("pro_text")
		if pro_text then
			pro_text:set_text("")
		end

		local description_text = self._scroll_panel:child("description_text")
		if description_text then

			local mutators_str = ""
			for k, v in pairs( Mutators.ActiveMutators ) do

				local mutation = Mutators.LoadedMutators[k]
				if mutation then
					mutators_str = mutators_str .. mutation:GetLocalizedName() .. ": " .. mutation:GetLocalizedDesc(true) .. "\n"
				end

			end
			self:set_description_text( mutators_str )

		end

	end

end)
