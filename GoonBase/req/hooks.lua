----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/4/2015 2:00:55 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.Hooks = _G.GoonBase.Hooks or {}
_G.Hooks = GoonBase.Hooks
Hooks.registered_hooks = {}

function Hooks:RegisterHook( key )
	self.registered_hooks[key] = self.registered_hooks[key] or {}
end

function Hooks:Register( key )
	self:RegisterHook( key )
end

function Hooks:AddHook( key, id, func )
	self:Add( key, id, func )
end

function Hooks:Add( key, id, func )
	self.registered_hooks[key] = self.registered_hooks[key] or {}
	self.registered_hooks[key][id] = func
end

function Hooks:UnregisterHook( id )
	self:Unregister( key )
end

function Hooks:Unregister( id )
	self.registered_hooks[id] = nil
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

Hooks._prehooks = {}
function Hooks:PreHook(object, func, id, replacement)

	if not object then
		self:_PrePostHookError(func)
		return
	end

	if object and self._prehooks[object] == nil then
		self._prehooks[object] = {}
	end

	if object and self._prehooks[object][func] == nil then

		self._prehooks[object][func] = {
			original = object[func],
			overrides = {}
		}

		object[func] = function(...)

			local hooked_func = self._prehooks[object][func]
			local r, _r

			for k, v in ipairs(hooked_func.overrides) do
				if v.func then
					_r = v.func(...)
				end
				if _r then
					r = _r
				end
			end

			_r = hooked_func.original(...)
			if _r then
				r = _r
			end

			return r

		end

	end

	for k, v in pairs( self._prehooks[object][func].overrides ) do
		if v.id == id then
			return
		end
	end

	local func_tbl = {
		id = id,
		func = replacement,
	}
	table.insert( self._prehooks[object][func].overrides, func_tbl )

end

function Hooks:RemovePreHook(id)

	for object_i, object in pairs( self._prehooks ) do
		for func_i, func in pairs( object ) do
			for override_i, override in ipairs( func.overrides ) do
				if override and override.id == id then
					table.remove( func.overrides, override_i )
				end
			end
		end
	end

end

Hooks._posthooks = {}
function Hooks:PostHook(object, func, id, replacement)

	if not object then
		self:_PrePostHookError(func)
		return
	end

	if object and self._posthooks[object] == nil then
		self._posthooks[object] = {}
	end

	if object and self._posthooks[object][func] == nil then

		self._posthooks[object][func] = {
			original = object[func],
			overrides = {}
		}

		object[func] = function(...)

			local hooked_func = self._posthooks[object][func]
			local r, _r

			_r = hooked_func.original(...)
			if _r then
				r = _r
			end

			for k, v in ipairs(hooked_func.overrides) do
				if v.func then
					_r = v.func(...)
				end
				if _r then
					r = _r
				end
			end

			return r

		end

	end

	for k, v in pairs( self._posthooks[object][func].overrides ) do
		if v.id == id then
			return
		end
	end

	local func_tbl = {
		id = id,
		func = replacement,
	}
	table.insert( self._posthooks[object][func].overrides, func_tbl )

end

function Hooks:RemovePostHook(id)

	for object_i, object in pairs( self._posthooks ) do
		for func_i, func in pairs( object ) do
			for override_i, override in ipairs( func.overrides ) do
				if override and override.id == id then
					table.remove( func.overrides, override_i )
				end
			end
		end
	end

end

function Hooks:_PrePostHookError(func)
	Print("[Hooks] Error: Could not hook function '", tostring(func), "'!")
end
-- END OF FILE
