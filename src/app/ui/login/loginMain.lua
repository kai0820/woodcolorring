local LoginMain = class("LoginMain", BaseUI)

LoginMain.RES = {
    [ResMgr.RES_TYPE.PLIST] = {
        "images/common",
        "images/login",
    },
    [ResMgr.RES_TYPE.SPINE_JSON] = {
    }
}

function LoginMain:ctor(ui_params)
    self.ui_params = ui_params
end

function LoginMain:init()
    self:loadRes()
    self:initUI()
end

function LoginMain:onClose()
    self:unloadRes()
end

function LoginMain:initUI()
    local win_size = cc.Director:getInstance():getWinSize()
    local logo = UIHelper.loginUI:createImgById({id = 1})
    logo:setPosition(win_size.width/2, win_size.height/2)
    self:scaleBGMgr(logo)
    self.root:addChild(logo)
    logo:setTouchEnabled(true)
    logo:addClickEventListener(function(sender)
        print("===================xxxx1")
        ShaderMgr:resetShader(logo)
    end)
    -- local tab = {
    --     ShaderMgr.SHADER_TYPE.DEFAULT,
    --     ShaderMgr.SHADER_TYPE.GRAY,
    --     ShaderMgr.SHADER_TYPE.GRAY2,
    --     ShaderMgr.SHADER_TYPE.HIGHLIGHT,
    --     ShaderMgr.SHADER_TYPE.ICE,
    --     ShaderMgr.SHADER_TYPE.INJURED,
    --     ShaderMgr.SHADER_TYPE.DARK,
    --     tab = {
    --         ShaderMgr.SHADER_TYPE.DEFAULT,
    --         ShaderMgr.SHADER_TYPE.GRAY,
    --         ShaderMgr.SHADER_TYPE.GRAY2,
    --         ShaderMgr.SHADER_TYPE.HIGHLIGHT,
    --         ShaderMgr.SHADER_TYPE.ICE,
    --         ShaderMgr.SHADER_TYPE.INJURED,
    --         ShaderMgr.SHADER_TYPE.DARK,
    --     }
    -- }

    -- local is_shader = true
    -- local params = {}
    -- params.nor = 'HelloWorld.png'
    -- local btn = fs.Button:create(params)
    -- btn:setPosition(win_size.width/2 + 300, win_size.height/2)
    -- self.root:addChild(btn)
    -- btn:addClickEventListener(function(sender)
    --     print("===================xxxx1")
    --     AudioMgr:play(AudioMgr.AUDIO_ID.BUTTON)
    --     Log.printAll(tab)
    -- end)
    -- AudioMgr:playBackgroundMusic(AudioMgr.AUDIO_ID.UI_BG)
    -- Log.printAll(tab)

    -- local params = {}
    -- params.str = "TEST"
    -- params.size = 28
    -- params.color = GConst.COLOR_TYPE.C1
    -- params.outline_color = GConst.OUTLINE_TYPE.C1
    -- params.ttf = self.ttf
    -- local test_label = LabHper:createFontTTF(params)
    -- test_label:setPosition(GConst.win_size.width/2, GConst.win_size.height/2)
    -- self.root:addChild(test_label)
    -- -- test_label:setTouchEnabled(true)
    -- -- test_label:addClickEventListener(function(sender)
    -- --     UIMgr:showDefaultConfigUI("app.ui.test.testMain", true)
    -- -- end)
    -- test_label:addTouchEventListener(function(sender, state)
    --     if state == TOUCH_EVENT_ENDED then
    --         UIMgr:showDefaultConfigUI("app.ui.test.testMain", true)
    --     end
    -- end)

    local test = fs.Text:create("TEST", "font/gamefont.ttf", 28)
    test:setColor(GConst.COLOR_TYPE.C2)
    test:setTouchEnabled(true)
    test:setPosition(GConst.win_size.width/2, GConst.win_size.height/2)
    self.root:addChild(test, GConst.Z_ORDER_TOP)
    test:addClickEventListener(function(sender)
        UIMgr:showDefaultConfigUI("app.ui.test.testMain", true)
    end)
end

function LoginMain:loadRes()
    ResMgr:loadResList(LoginMain.RES)
end

function LoginMain:onClose()
    ResMgr:unloadResList(LoginMain.RES)
end

function LoginMain:handleBackEvent()
    GApi.exitGame()
end

return LoginMain
