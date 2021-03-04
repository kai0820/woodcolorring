local UIHelper = {}

UIHelper.commonUI = require "app.ui.uiHelper.conmonUI"
UIHelper.loginUI = require "app.ui.uiHelper.loginUI"

function UIHelper:createBackBtn(params)
    params.nor = UIHelper.commonUI.ResConf[4]
    params.sel = UIHelper.commonUI.ResConf[4]
    params.act_type = GConst.BUTTON_EFFECT_TYPE.ENLARGE
    params.pos = cc.p(50, GConst.win_size.height - 50)
    local btn = UIHelper.commonUI:createBtn(params)
    return btn
end

function UIHelper:createCloseBtn(params)
    params.nor = UIHelper.commonUI.ResConf[5]
    local btn = UIHelper.commonUI:createBtn(params)
    return btn 
end

return UIHelper