
local Mutator = class(BaseMutator)
Mutator.Id = "RealismMode"
Mutator.OptionsName = "Realism Mode"
Mutator.OptionsDesc = "No waypoints, no outlines, no names"
Mutator.AllPlayersRequireMod = true
Mutator.HideInOptionsMenu = true
Mutator.MutatorDisabled = true

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator.Id, function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator._AddWaypointHook = "HUDManagerPreAddWaypoint_" .. Mutator.Id
Mutator._ContourInit = "ContourExtPreInitialize_" .. Mutator.Id
Mutator._ContourAdd = "ContourExtPreAdd_" .. Mutator.Id
Mutator._BaseInteractionSetContour = "BaseInteractionExtPreSetContour_" .. Mutator.Id
Mutator._AddNameLabel = "HUDManagerPreAddNameLabel_" .. Mutator.Id

function Mutator:OnEnabled()
	
	Hooks:Add("HUDManagerPreAddWaypoint", self._AddWaypointHook, function(hud, id, data)
		return true
	end)

	Hooks:Add("ContourExtPreInitialize", self._ContourInit, function(contour, unit)
		for k, v in pairs(ContourExt._types) do
			if v.color ~= nil then
				v.color = Color(0, 0, 0, 0)
			end
		end
	end)

	Hooks:Add("ContourExtPreAdd", self._ContourAdd, function(contour, type, sync, multiplier)
		contour._contour_list = contour._contour_list or {}
		return true
	end)

	Hooks:Add("BaseInteractionExtPreSetContour", self._BaseInteractionSetContour, function(int, color, opacity)
		return { color = color, opacity = 0 }
	end)

	Hooks:Add("HUDManagerPreAddNameLabel", self._AddNameLabel, function(hud, data)
		data.name = ""
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self._AddWaypointHook)
	Hooks:Remove(self._ContourInit)
	Hooks:Remove(self._BaseInteractionSetContour)
end
