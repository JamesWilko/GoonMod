----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

if BaseMutator then return end
local Mutators = _G.GoonBase.Mutators

BaseMutator = class()
BaseMutator.Id = "BaseMutator"
BaseMutator.OptionsName = "Base Mutator"
BaseMutator.OptionsDesc = "The base mutator"
BaseMutator.MenuPrefix = "toggle_mutator_"
BaseMutator.MenuSuffix = ""
BaseMutator.HideInOptionsMenu = false
BaseMutator.Incompatibilities = {}

function BaseMutator:ID()
	return self.Id
end

function BaseMutator:IncompatibleMutators()
	return self.Incompatibilities
end

function BaseMutator:Setup()
	self:SetupLocalization()
	if self:IsEnabled() then
		self:OnEnabled()
	end
end

function BaseMutator:SetupLocalization()
	local Localization = _G.GoonBase.Localization
	Localization[ self:GetName() ] = self.OptionsName
	self.OptionsDescOrig = self.OptionsDesc
	Localization[ self:GetDesc() ] = self.OptionsDesc
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
	GoonBase.MenuHelper:AddToggle({
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

function BaseMutator:GetLocalizedName()
	return managers.localization:text( self:GetName() )
end

function BaseMutator:GetLocalizedDesc()
	return managers.localization:text( self:GetDesc() )
end

function BaseMutator:IncompatibilitiesLocalizedDesc(incompatibilities)

	local new_str = self.OptionsDescOrig

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
	GoonBase.Localization[ self:GetDesc() ] = self.OptionsDesc

end

function BaseMutator:VerifyIncompatibilities()

	local should_disable = false
	local incompatible_mutators = {}

	for k, v in pairs( self:IncompatibleMutators() ) do
		if Mutators.LoadedMutators[v] ~= nil and Mutators.LoadedMutators[v]:ShouldBeEnabled() then
			should_disable = true
			table.insert( incompatible_mutators, v )
		end
	end

	self:MenuSetEnabled( not should_disable )
	self:IncompatibilitiesLocalizedDesc( #incompatible_mutators > 0 and incompatible_mutators or nil )

end

function BaseMutator:MenuSetEnabled(enabled)

	local menu = GoonBase.MenuHelper:GetMenu( Mutators.MenuID )
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
		self:OnEnabled()
	else
		self:OnDisabled()
	end

end

function BaseMutator:IsEnabled()
	
	if GoonBase.Options.Mutators == nil then
		return false
	end

	if GoonBase.Network:IsMultiplayer() and not GoonBase.Network:IsHost() then
		return false
	end

	if Global.game_settings ~= nil then
		if Global.game_settings.permission == "public" then
			return false
		end
	end

	return GoonBase.Options.Mutators[self.Id] or false

end

function BaseMutator:ShouldBeEnabled()

	if GoonBase.Options.Mutators == nil then
		return false
	end

	return GoonBase.Options.Mutators[self.Id] or false

end

function BaseMutator:OnEnabled()
	Print("Base Mutator Enabled")
end

function BaseMutator:OnDisabled()
	Print("Base Mutator Disabled")
end

-- END OF FILE
