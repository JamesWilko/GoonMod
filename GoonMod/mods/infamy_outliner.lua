
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "InfamyOutliner"
Mod.Name = "Infamy Outliner"
Mod.Desc = "Provides an outline of your skill trees prior to going infamous for you to rebuild on."
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.EnabledByDefault = true

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Infamy Outliner
_G.GoonBase.InfamyOutliner = _G.GoonBase.InfamyOutliner or {}
local InfamyOutliner = _G.GoonBase.InfamyOutliner
InfamyOutliner.SaveFile = "goonmod_infamy_outline.txt"
InfamyOutliner.MenuFile = "infamy_outliner_menu.txt"
InfamyOutliner.Outline = {}

-- Options
GoonBase.Options.InfamyOutliner 				= GoonBase.Options.InfamyOutliner or {}
GoonBase.Options.InfamyOutliner.Enabled 		= GoonBase.Options.InfamyOutliner.Enabled or true
GoonBase.Options.InfamyOutliner.RH 				= GoonBase.Options.InfamyOutliner.RH or 0.8
GoonBase.Options.InfamyOutliner.GS 				= GoonBase.Options.InfamyOutliner.GS or 1.0
GoonBase.Options.InfamyOutliner.BV 				= GoonBase.Options.InfamyOutliner.BV or 0.4
GoonBase.Options.InfamyOutliner.UseHSV 			= GoonBase.Options.InfamyOutliner.UseHSV or true

-- Color
InfamyOutliner.Color = ColorHSVRGB:new( GoonBase.Options.InfamyOutliner, Color.purple:with_alpha(0) )

function InfamyOutliner:IsEnabled()
	return GoonBase.Options.InfamyOutliner.Enabled or false
end

function InfamyOutliner:LoadInfamySkillData()

	local path = SavePath .. InfamyOutliner.SaveFile
	local file = io.open( path, "r" )
	if file then
		local data = file:read("*all")
		file:close()
		if not string.is_nil_or_empty( data ) then
			InfamyOutliner.Outline = json.decode( data )
		end
	end

end

function InfamyOutliner:SaveInfamySkillData()
	
	local tree_data = managers.skilltree._global.skill_switches
	InfamyOutliner.Outline = tree_data
	tree_data = json.encode( InfamyOutliner.Outline )

	local path = SavePath .. InfamyOutliner.SaveFile
	local file = io.open( path, "w+" )
	if file then
		file:write( tostring(tree_data) )
		file:close()
	else
		Print("[Error] Could not save infamy skill tree data!")
	end

end

function InfamyOutliner:ClearInfamySkillData()

	local path = SavePath .. InfamyOutliner.SaveFile
	local success, remove_error = os.remove( path )
	if success then
		InfamyOutliner.Outline = {}
	else
		Print("Could not clear infamy outliner skill data: " .. tostring(remove_error))
	end

end

function InfamyOutliner:UpdateSkillItem( item, skill_id, infamy_outline, infamy_ace )

	if not InfamyOutliner:IsEnabled() then
		return
	end

	if not infamy_outline then
		infamy_outline = item._infamy_outline
		if not infamy_outline then
			return
		end
	end
	if not infamy_ace then
		infamy_ace = item._infamy_ace
		if not infamy_ace then
			return
		end
	end

	local skill_set = managers.skilltree:get_selected_skill_switch()
	local tree = managers.skilltree._global.skill_switches[ skill_set ]
	local outline = InfamyOutliner.Outline[ skill_set ]

	if not outline then
		return
	end

	local tree_unlocked = tree.skills[skill_id].unlocked
	local outline_unlocked = outline.skills[skill_id].unlocked

	if self:IsSkillIDSkillTree( skill_id ) and tree_unlocked > 0 then
		infamy_outline:set_alpha( 0 )
		infamy_ace:set_alpha( 0 )
		return
	end

	if tree_unlocked and tree_unlocked >= outline_unlocked then
		infamy_outline:set_alpha( 0 )
		infamy_ace:set_alpha( 0 )
		return
	end

	if outline_unlocked then
		infamy_outline:set_alpha( outline_unlocked > 0 and 1 or 0 )
		infamy_ace:set_alpha( outline_unlocked > 1 and 1 or 0 )
	end

end

function InfamyOutliner:IsSkillIDSkillTree( id )
	for k, v in pairs( tweak_data.skilltree.trees ) do
		if v.skill == id then
			return true
		end
	end
	return false
end

function InfamyOutliner:GetColor(alpha)
	return InfamyOutliner.Color:GetColor( alpha )
end

function InfamyOutliner:ShowPreviewMenuItem()

	if not managers.menu_component then
		return
	end

	local ws = managers.menu_component._ws
	self._panel = ws:panel():panel()

	local w, h = self._panel:w() * 0.35, 48
	self._color_rect = self._panel:rect({
		w = w,
		h = h,
		color = Color.red,
		blend_mode = "add",
		layer = tweak_data.gui.MOUSE_LAYER - 50,
	})
	self._color_rect:set_right( self._panel:right() )
	self._color_rect:set_top( self._panel:h() * 0.265 )

	self:UpdatePreview()

end

function InfamyOutliner:DestroyPreviewMenuItem()

	if alive(self._panel) then

		self._panel:remove( self._color_rect )
		self._panel:remove( self._panel )

		self._color_rect = nil
		self._panel = nil

	end

end

function InfamyOutliner:UpdatePreview( t )
	if not alive(self._panel) or not alive(self._color_rect) or not InfamyOutliner.Color then
		return
	end
	self._color_rect:set_color( InfamyOutliner.Color:GetColor() )
end

-- Menu
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	InfamyOutliner:LoadInfamySkillData()

	InfamyOutliner._increase_infamous_orig = MenuCallbackHandler._increase_infamous
	MenuCallbackHandler._increase_infamous = function(self)
		InfamyOutliner:SaveInfamySkillData()
		InfamyOutliner._increase_infamous_orig(self)
	end

	-- Callbacks
	MenuCallbackHandler.InfamyOutlinerChangedFocus = function( node, focus )
		if focus then
			InfamyOutliner:ShowPreviewMenuItem()
		else
			InfamyOutliner:DestroyPreviewMenuItem()
		end
	end

	MenuCallbackHandler.InfamyOutlinerToggleEnabled = function( this, item )
		GoonBase.Options.InfamyOutliner.Enabled = item:value() == "on" and true or false
		InfamyOutliner:UpdatePreview()
	end

	MenuCallbackHandler.InfamyOutlinerSetUseHSV = function( this, item )
		GoonBase.Options.InfamyOutliner.UseHSV = item:value() == "on" and true or false
		InfamyOutliner:UpdatePreview()
	end

	MenuCallbackHandler.InfamyOutlinerSetRedHue = function( this, item )
		GoonBase.Options.InfamyOutliner.RH = tonumber( item:value() )
		InfamyOutliner:UpdatePreview()
	end

	MenuCallbackHandler.InfamyOutlinerSetGreenSaturation = function( this, item )
		GoonBase.Options.InfamyOutliner.GS = tonumber( item:value() )
		InfamyOutliner:UpdatePreview()
	end

	MenuCallbackHandler.InfamyOutlinerSetBlueValue = function( this, item )
		GoonBase.Options.InfamyOutliner.BV = tonumber( item:value() )
		InfamyOutliner:UpdatePreview()
	end

	MenuCallbackHandler.InfamyOutlinerClearInfamyData = function( this, item )
		InfamyOutliner:ClearInfamySkillData()
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. InfamyOutliner.MenuFile, GoonBase.InfamyOutliner, GoonBase.Options.InfamyOutliner )

end)

Hooks:Add("SkillTreeSkillItemPostInit", "SkillTreeSkillItemPostInit_" .. Mod:ID(), function(gui, skill_id, tier_panel, num_skills, i, tree, tier, w, h, skill_refresh_skills)

	if not InfamyOutliner:IsEnabled() then
		return
	end

	local state_image = gui._skill_panel:child("state_image")
	local infamy_outline = gui._skill_panel:bitmap({
		name = "infamy_outline",
		texture = "guis/textures/pd2/hot_cold_glow",
		alpha = 0,
		color = InfamyOutliner.Color:GetColor(),
		layer = -1
	})
	infamy_outline:set_size(state_image:w(), state_image:h())
	infamy_outline:set_blend_mode("add")
	infamy_outline:set_rotation(360)
	infamy_outline:set_center(state_image:center())
	gui._infamy_outline = infamy_outline

	local infamy_ace = gui._skill_panel:bitmap({
		name = "infamy_outline_ace",
		texture = "guis/textures/pd2/skilltree/ace",
		alpha = 0,
		color = InfamyOutliner.Color:GetColor(),
		layer = -1
	})
	infamy_ace:set_size(state_image:w() * 2, state_image:h() * 2)
	infamy_ace:set_blend_mode("add")
	infamy_ace:set_rotation(360)
	infamy_ace:set_center(state_image:center())
	gui._infamy_ace = infamy_ace

	if not managers.skilltree or not InfamyOutliner.Outline then
		return
	end

	InfamyOutliner:UpdateSkillItem( gui, skill_id, infamy_outline, infamy_ace )

end)

Hooks:Add("SkillTreeSkillItemPostRefresh", "SkillTreeSkillItemPostRefresh_" .. Mod:ID(), function(gui, locked)

	if not InfamyOutliner:IsEnabled() then
		return
	end

	local skill_id = gui._skill_panel:name()
	InfamyOutliner:UpdateSkillItem( gui, skill_id )

end)
