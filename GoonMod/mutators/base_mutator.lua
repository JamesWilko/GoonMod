
if BaseMutator then return end
local Mutators = _G.GoonBase.Mutators

BaseMutator = class()
BaseMutator.Id = "BaseMutator"
BaseMutator.OptionsName = "Base Mutator"
BaseMutator.OptionsDesc = "The base mutator"
BaseMutator.MenuPrefix = "toggle_mutator_"
BaseMutator.MenuSuffix = ""
BaseMutator.HideInOptionsMenu = false
BaseMutator.AllPlayersRequireMod = false
BaseMutator.IsAllowedInRandomizer = true
BaseMutator.Incompatibilities = {}

BaseMutator._AllPlayersRequirementText = "\nWarning: All players must have GoonMod and Mutators installed for this mutator to work properly!"

function BaseMutator:ID()
	return self.Id
end

function BaseMutator:IncompatibleMutators()
	return self.Incompatibilities
end

function BaseMutator:DoAllPlayersRequireMod()
	return self.AllPlayersRequireMod
end

function BaseMutator:Setup()
	if self:IsEnabled() then
		self:_OnEnabled()
	end
end

function BaseMutator:SetupLocalization()

	self.OptionsDescOrig = self.OptionsDesc
	if self:DoAllPlayersRequireMod() then
		self.OptionsDesc = self.OptionsDesc .. self._AllPlayersRequirementText
	end

	Mutators:RegisterLocalization( self:GetName(), self.OptionsName )
	Mutators:RegisterLocalization( self:GetDesc(), self.OptionsDesc )
	Mutators:RegisterLocalization( self:GetOriginalDesc(), self.OptionsDescOrig )

end

function BaseMutator:SetupMenu()
	
	-- Setup callback for mutator
	local mutator_menu_name = self.MenuPrefix .. self:ID() .. self.MenuSuffix
	MenuCallbackHandler[mutator_menu_name] = function(this, item)

		-- Get mutator state
		local enabled = item:value() == "on" and true or false

		-- Check if we're trying to enable an incompatible mutator
		if enabled then
			local incompatibilities = Mutators:CheckIncompatibilities( self )
			if type(incompatibilities) == "table" then
				Mutators:ShowIncompatibilitiesWindow( self, incompatibilities )
				item:set_value("off")
				return
			end
		end

		-- Toggle mutator
		self:OnToggled(enabled)

		-- Verify mutators are compatible
		Mutators:VerifyAllIncompatibilities()

	end

	-- Add to menu
	MenuHelper:AddToggle({
		id = mutator_menu_name,
		title = self:GetName(),
		desc = self:GetDesc(),
		callback = mutator_menu_name,
		value = GoonBase.Options.Mutators[ self:ID() ],
		disabled_color = Color( 0.5, 1, 0.2, 0.2 ),
		menu_id = Mutators.MenuID
	})

end

function BaseMutator:GetName()
	return "mutator_" .. self.Id .. "_name"
end

function BaseMutator:GetDesc()
	return "mutator_" .. self.Id .. "_desc"
end

function BaseMutator:GetOriginalDesc()
	return "mutator_" .. self.Id .. "_desc_orig"
end

function BaseMutator:GetLocalizedName()
	return managers.localization:text( self:GetName() )
end

function BaseMutator:GetLocalizedDesc(ignore_requirement)
	local desc = managers.localization:text( self:GetOriginalDesc() )
	if not ignore_requirement and self:DoAllPlayersRequireMod() then
		desc = desc .. self._AllPlayersRequirementText
	end
	return desc
end

function BaseMutator:IncompatibilitiesLocalizedDesc(incompatibilities)

	local new_str = self:GetLocalizedDesc()

	if incompatibilities ~= nil then

		local str = ""
		for k, v in pairs( incompatibilities ) do
			local mutator_name = Mutators.LoadedMutators[v]:GetLocalizedName()
			if str ~= "" then
				str = str .. ", "
			end
			str = str .. mutator_name
		end
		new_str = new_str .. " (Incompatible with " .. str .. ")"	

	end

	self.OptionsDesc = new_str
	managers.localization:add_localized_strings({ [ self:GetDesc() ] = self.OptionsDesc })

end

function BaseMutator:VerifyIncompatibilities(skip_menu_verify)

	local should_disable = false
	local incompatible_mutators = {}

	for k, v in pairs( self:IncompatibleMutators() ) do
		if ( Mutators.LoadedMutators[v] ~= nil and Mutators.LoadedMutators[v]:ShouldBeEnabled() ) or Mutators.ActiveMutators[v] then
			should_disable = true
			table.insert( incompatible_mutators, v )
		end
	end

	if not skip_menu_verify then
		self:MenuSetEnabled( not should_disable )
		self:IncompatibilitiesLocalizedDesc( #incompatible_mutators > 0 and incompatible_mutators or nil )
	end

	return not should_disable

end

function BaseMutator:MenuSetEnabled(enabled)

	local menu = MenuHelper:GetMenu( Mutators.MenuID )
	for k, v in pairs( menu["_items"] ) do
		local menu_name = v["_parameters"]["name"]:gsub(self.MenuPrefix, "")
		if menu_name == self:ID() then
			v:set_enabled( enabled )
			v:dirty()
		end
	end

end

function BaseMutator:OnToggled(enabled)

	GoonBase.Options.Mutators = GoonBase.Options.Mutators or {}
	GoonBase.Options.Mutators[self.Id] = enabled
	GoonBase.Options:Save()

	if enabled then
		self:_OnEnabled()
	else
		self:_OnDisabled()
	end

end

function BaseMutator:IsEnabled()
	
	local Net = _G.LuaNetworking
	if Net:IsMultiplayer() and not Net:IsHost() then
		return false
	end

	if Global.game_settings ~= nil then
		if Net:IsMultiplayer() and Global.game_settings.permission == "public" then
			return false
		end
		if Global.game_settings.active_mutators then
			return Global.game_settings.active_mutators[self.Id] or false
		end
	end

	return false

end

function BaseMutator:ShouldBeEnabled()

	if GoonBase.Options.Mutators == nil then
		return false
	end

	return GoonBase.Options.Mutators[self.Id] or false

end

function BaseMutator:ForceEnable()
	return self:_OnEnabled()
end

function BaseMutator:_OnEnabled()
	Mutators.ActiveMutators[self:ID()] = true
	self:OnEnabled()
	self:_UpdateMatchmaking()
end

function BaseMutator:OnEnabled()
	Print("Base Mutator Enabled")
end

function BaseMutator:_OnDisabled()
	if not Mutators:IsInGame() then
		Mutators.ActiveMutators[self:ID()] = nil
	end
	self:OnDisabled()
	self:_UpdateMatchmaking()
end

function BaseMutator:OnDisabled()
	Print("Base Mutator Disabled")
end

function BaseMutator:_UpdateMatchmaking()
	local psuccess, perror = pcall(function()
		if MenuCallbackHandler then
			MenuCallbackHandler:update_matchmake_attributes()
		end
	end)
end
