core:module("CoreMissionManager")

local function PrintTable (tbl, cmp)
	cmp = cmp or {}
	if type(tbl) == "table" then
		for k, v in pairs (tbl) do
			if type(v) == "table" and not cmp[v] then
				cmp[v] = true
				Print( string.format("[\"%s\"] -> table", tostring(k)) );
				PrintTable (v, cmp)
			else
				Print( string.format("\"%s\" -> %s", tostring(k), tostring(v)) )
			end
		end
	else Print(tbl) end
end

local function DoSaveTable(tbl, cmp, fileName, fileIsOpen, preText)

	local file = nil
	if fileIsOpen == nil then
		file = io.open(fileName, "w")
	else
		file = fileIsOpen
	end

	cmp = cmp or {}
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			if type(v) == "table" and not cmp[v] then
				cmp[v] = true
				file:write( preText .. string.format("[\"%s\"] -> table", tostring (k)) .. "\n" )
				DoSaveTable(v, cmp, fileName, file, preText .. "\t")
			else
				file:write( preText .. string.format( "\"%s\" -> %s", tostring(k), tostring(v) ) .. "\n" )
			end
		end
	else
		file:write( preText .. tbl .. "\n")
	end

	if fileIsOpen == nil then
		file:close()
	end
end

local function SaveTable(tbl, file)
	DoSaveTable(tbl, {}, file, nil, "")
end

function MissionManager:parse(params, stage_name, offset, file_type)

	Print("MissionManager:parse")

	local file_path, activate_mission
	if CoreClass.type_name(params) == "table" then
		file_path = params.file_path
		file_type = params.file_type or "mission"
		activate_mission = params.activate_mission
		offset = params.offset
	else
		file_path = params
		file_type = file_type or "mission"
	end

	Print("-----")
	Print("file_path: ", file_path)
	Print("file_type: ", file_type)
	Print("activate_mission: ", activate_mission)
	Print("offset: ", offset)
	Print("-----")

	CoreDebug.cat_debug("gaspode", "MissionManager", file_path, file_type, activate_mission)
	if not DB:has(file_type, file_path) then
		Application:error("Couldn't find", file_path, "(", file_type, ")")
		return false
	end

	local reverse = string.reverse(file_path)
	local i = string.find(reverse, "/")
	local file_dir = string.reverse(string.sub(reverse, i))
	local continent_files = self:_serialize_to_script(file_type, file_path)
	continent_files._meta = nil

	for name, data in pairs(continent_files) do
		if not managers.worlddefinition:continent_excluded(name) then
			self:_load_mission_file(file_dir, data)
		end
	end

	self:_activate_mission(activate_mission)

	return true

end

function MissionManager:_load_mission_file(file_dir, data)

	local file_path = file_dir .. data.file
	local scripts = self:_serialize_to_script("mission", file_path)
	scripts._meta = nil

	for name, data in pairs(scripts) do
		data.name = name
		self:_add_script(data)
	end

end
