
CloneClass( MaskExt )

function MaskExt.clbk_texture_loaded(self, async_clbk, tex_name)
	if not alive(self._unit) then
		return
	end
	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.ready and tex_name == texture_data.name then
			texture_data.ready = true
			local new_texture = TextureCache:retrieve(tex_name, "normal")
			for _, material in ipairs(self._materials) do
				material:set_texture(tex_id == "pattern" and "material_texture" or "reflection_texture", new_texture)
			end
			TextureCache:unretrieve(tex_name)
			TextureCache:unretrieve(tex_name)
		end
	end
	self:_chk_load_complete(async_clbk)
end
