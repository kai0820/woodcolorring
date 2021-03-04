
local LoginMgr = {}

function LoginMgr:showLoginMain(ui_params)
	ui_params = ui_params or {}
	UIMgr:showDefaultConfigUI("app.ui.login.loginMain", true, ui_params)
end

return LoginMgr