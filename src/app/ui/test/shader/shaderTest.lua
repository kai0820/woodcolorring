local ShaderTest = class("ShaderTest", BaseUI)

ShaderTest.RES = {
    [ResMgr.RES_TYPE.PLIST] = {
        "images/common",
    },
    [ResMgr.RES_TYPE.SPINE_JSON] = {
    }
}

function ShaderTest:ctor(ui_params)
    self.ui_params = ui_params
end

function ShaderTest:init()
    self:loadRes()
    self:initUI()
end

function ShaderTest:onClose()
    self:unloadRes()
end

function ShaderTest:initUI()
    local tab = {
        -- ShaderMgr.SHADER_TYPE.DEFAULT,
        ShaderMgr.SHADER_TYPE.GRAY,
        ShaderMgr.SHADER_TYPE.GRAY2,
        ShaderMgr.SHADER_TYPE.HIGHLIGHT,
        ShaderMgr.SHADER_TYPE.ICE,
        ShaderMgr.SHADER_TYPE.INJURED,
        ShaderMgr.SHADER_TYPE.DARK,
    }

    for i = 1, 6 do
        local params = {}
        params.nor = UIHelper.commonUI.ResConf[3]
        local btn = UIHelper.commonUI:createBtn(params)
        btn:setPosition(GConst.win_size.width/2, GConst.win_size.height - i*80)
        self.root:addChild(btn)
        local is_click = false
        btn:addClickEventListener(function(sender)
            is_click = not is_click
            if is_click then
                ShaderMgr:setShader(btn, tab[i])
            else
                ShaderMgr:resetShader(btn)
            end
        end)
    end

    local close_btn = UIHelper:createBackBtn({})    
    self.root:addChild(close_btn)
    close_btn:addClickEventListener(function(sender)
        self:handleBackEvent()
    end)
end

function ShaderTest:loadRes()
    ResMgr:loadResList(ShaderTest.RES)
end

function ShaderTest:onClose()
    ResMgr:unloadResList(ShaderTest.RES)
end

return ShaderTest
