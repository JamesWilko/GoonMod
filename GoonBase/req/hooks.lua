----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/18/2014 10:52:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.Hooks = _G.GoonBase.Hooks or {}
_G.Hooks = GoonBase.Hooks
Hooks.registered_hooks = {}

function Hooks:RegisterHook( key )
	self.registered_hooks[key] = self.registered_hooks[key] or {}
end

function Hooks:Register( key )
	self:registered_hooks( key )
end

function Hooks:AddHook( key, id, func )
	self:Add( key, id, func )
end

function Hooks:Add( key, id, func )
	self.registered_hooks[key] = self.registered_hooks[key] or {}
	self.registered_hooks[key][id] = func
end

function Hooks:Unregister( id )

	for k, v in pairs(self.registered_hooks) do
		if k[id] ~= nil then
			k[id] = nil
		end
	end

end

function Hooks:Remove( id )

	for k, v in pairs(self.registered_hooks) do
		if type(v) == "table" and v[id] ~= nil then
			v[id] = nil
		end
	end
	
end

function Hooks:Call( key, ... )

	if self.registered_hooks[key] ~= nil then
		for k, v in pairs(self.registered_hooks[key]) do
			if v ~= nil and type(v) == "function" then
				v( ... )
			end
		end
	end

end

function Hooks:ReturnCall( key, ... )

	if self.registered_hooks[key] ~= nil then
		for k, v in pairs(self.registered_hooks[key]) do
			if v ~= nil and type(v) == "function" then

				local r = v( ... )
				if r ~= nil then
					return r
				end

			end
		end
	end

end

function Hooks:PCall( key, ... )

	if self.registered_hooks[key] ~= nil then
		for k, v in pairs(self.registered_hooks[key]) do
			if v ~= nil and type(v) == "function" then
				local args = ...
				local success, err = pcall( function() v( args ) end )
				if not success then
					Print("[Error]\nHook: " .. k .. "\n" .. err)
				end
			end
		end
	end

end

-- END OF FILE
