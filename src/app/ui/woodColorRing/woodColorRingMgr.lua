local WoodColorRingMgr = {}

function WoodColorRingMgr:showWoodColorRingMain(ui_params)
	ui_params = ui_params or {}
	UIMgr:showDefaultConfigUI("app.ui.woodColorRing.woodColorRingMain", true, ui_params)
end

return WoodColorRingMgr