
CloneClass( LocalizationManager )

function LocalizationManager.text(this, str, ...)
	return _G.GoonHUD.Localization[str] or this.orig.text(this, str, ...)
end
