
CloneClass( LocalizationManager )

function LocalizationManager.text(this, str, ...)
	return _G.GoonBase.Localization[str] or this.orig.text(this, str, ...)
end
