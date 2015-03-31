
CloneClass( WalletGuiObject )

Hooks:RegisterHook("WalletGuiObjectOnSetWallet")
function WalletGuiObject.set_wallet(panel, layer)
	WalletGuiObject.orig.set_wallet(panel, layer)
	Hooks:Call( "WalletGuiObjectOnSetWallet", panel, layer )
end

Hooks:RegisterHook("WalletGuiObjectOnRefresh")
function WalletGuiObject.refresh()
	WalletGuiObject.orig.refresh()
	Hooks:Call( "WalletGuiObjectOnRefresh" )
end

Hooks:RegisterHook("WalletGuiObjectSetObjectVisible")
function WalletGuiObject.set_object_visible(object, visible)
	WalletGuiObject.orig.set_object_visible(object, visible)
	Hooks:Call( "WalletGuiObjectSetObjectVisible", object, visible )
end
