local Game = {
    loaded_list = {}
}

function Game:init()
    Game:enableGlobalVariable()
    Game:initBeforeCocos()
    Game:initCocos()
    Game:initModule()
    Game:addEventListener()
end

function Game:recordloadedList()
    self.loaded_list = {}
    for name, v in pairs(package.loaded) do
        self.loaded_list[name] = 1
    end
end

function Game:initBeforeCocos()
    socket = require "socket"
    -- cjson = require "cjson"
    -- zlib = require "zlib"
end

function Game:disableGlobalVariable()
    if self.g_meta_table then
        setmetatable(_G, self.g_meta_table)
    elseif cc and cc.disable_global then
        cc.disable_global()
    else
        setmetatable(_G, {
            __newindex = function(_, name, value)
                error(string.format("USE \" cc.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
            end
        })
    end
end

function Game:enableGlobalVariable()
    self.g_meta_table = getmetatable(_G)
    setmetatable(_G, nil)
end

function Game:initCocos()
    require "config"
    require "cocos.init"
end

function Game:initModule()
    Game:loadScript()
    ShaderMgr:init()
    -- NetMgr:init()
    AudioMgr:init()
end

function Game:loadScript()
    cc.exports.UserData = require "app.data.userData"
    
    cc.exports.Log = require "app.tools.log"
    cc.exports.View = require "app.tools.view"
    -- cc.exports.Logger = require "app.tools.logger"
    cc.exports.GConst = require "app.global.gConst"
    cc.exports.GApi = require "app.global.gApi"
    -- cc.exports.GVar = require "app.global.gVar"
    cc.exports.fs = require "app.fs.init"
    cc.exports.HelperBase = require "app.ui.uiHelper.helperBase"
    cc.exports.UIHelper = require "app.ui.uiHelper.uiHelper"
    cc.exports.AudioMgr = require "app.common.audioMgr"
    cc.exports.EventMgr = require "app.common.eventMgr"
    cc.exports.ScheduleMgr = require "app.common.scheduleMgr"
    cc.exports.ShaderMgr = require "app.common.shaderMgr"
    cc.exports.ResMgr = require "app.common.resMgr"
    cc.exports.UIMgr = require "app.ui.uiMgr"
    cc.exports.BaseUI = require "app.ui.baseUI"
    -- cc.exports.NetMgr = require "app.net.netMgr"

    cc.exports.LabHper = require "app.tools.labHper"
end

function Game:addEventListener()
    Game:addReloadListener()
    Game:addEnterBackgroundListener()
    Game:addEnterForegroundListener()
    Game:addRestartListener()
end

function Game:addReloadListener()
    local target_platform = cc.Application:getInstance():getTargetPlatform()
    if target_platform == cc.PLATFORM_OS_ANDROID then
        if self.renderer_recreated_listener then
            cc.Director:getInstance():getEventDispatcher():removeEventListener(self.renderer_recreated_listener)
        end
        self.renderer_recreated_listener = cc.EventListenerCustom:create("event_renderer_recreated", function (eventCustom)
            if ShaderMgr then
				ShaderMgr:reloadCustomGLProgram()
			end
        end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.renderer_recreated_listener, -1)
    end
end

function Game:addEnterBackgroundListener()
    if self.enter_background_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.enter_background_listener)
    end
    self.enter_background_listener = cc.EventListenerCustom:create("application_enter_background", function (eventCustom)
        print("===========application_enter_background===========")
        EventMgr:dispatchEvent(EventMgr.EVENT.GAME_ENTER_BACKGROUND)
    end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.enter_background_listener, -1)
end

function Game:addEnterForegroundListener()
    if self.enter_foreground_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.enter_foreground_listener)
    end
    self.enter_foreground_listener = cc.EventListenerCustom:create("application_enter_foreground", function (eventCustom)
        print("===========application_enter_foreground===========")
        EventMgr:dispatchEvent(EventMgr.EVENT.GAME_ENTER_FOREGROUND)
        if NetMgr then
            NetMgr:registForegroundListener(function()
                NetMgr:unregistForegroundListener()
                if not NetMgr:isConnected() then
                    UIMgr:closeAllUI()
                    local LoginMgr = require "app.ui.login.loginMgr"
                    LoginMgr:showLoginUpdate()
                end
            end)
            cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    NetMgr:unregistForegroundListener()
                end)
            ))
        end
    end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.enter_foreground_listener, -1)
end

function Game:addRestartListener()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        local press_f = 0
        if self.restart_listener_pressed then
            cc.Director:getInstance():getEventDispatcher():removeEventListener(self.restart_listener_pressed)
        end
        self.restart_listener_pressed = cc.EventListenerKeyboard:create()
        self.restart_listener_pressed:registerScriptHandler(function (keyCode, event)
            if keyCode == cc.KeyCode.KEY_Q then
                UIMgr:closeAndRestart()
                local LoginMgr = require "app.ui.login.loginMgr"
                LoginMgr:showLoginMain()
            else
                press_f = 0
            end
        end, cc.Handler.EVENT_KEYBOARD_PRESSED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.restart_listener_pressed, -1)
    end
end

function Game:removeAllListeners()
    local target_platform = cc.Application:getInstance():getTargetPlatform()
    if target_platform == cc.PLATFORM_OS_ANDROID then
        if self.renderer_recreated_listener then
            cc.Director:getInstance():getEventDispatcher():removeEventListener(self.renderer_recreated_listener)
            self.renderer_recreated_listener = nil
        end
    end
    if self.enter_background_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.enter_background_listener)
        self.enter_background_listener = nil
    end
    if self.enter_foreground_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.enter_foreground_listener)
        self.enter_foreground_listener = nil
    end
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        if self.restart_listener_pressed then
            cc.Director:getInstance():getEventDispatcher():removeEventListener(self.restart_listener_pressed)
            self.restart_listener_pressed = nil
        end
    end
end

function Game:start()
    ResMgr:loadPlist("images/common")
    local main_scene = require("app.scene.main"):create()
	main_scene:enter()
end

function Game:restart()
    Game:recordloadedList()
    Game:init()
    local current_scene = cc.Director:getInstance():getRunningScene()
    if current_scene then
        UIMgr:init(current_scene)
    else
        local scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(scene)
        UIMgr:init(scene)
    end
end

function Game:purge()
	EventMgr:purge()
	ScheduleMgr:purge()
    AudioMgr:stopAll()
    -- NetMgr:close()
    Game:removeAllListeners()
    ResMgr:purge()
    cc.Director:getInstance():purgeCachedData()
    local DataHper = require "app.tools.dataHper"
    DataHper.purge()
    for name, v in pairs(package.loaded) do
        if self.loaded_list[name] == nil then
            package.loaded[name] = nil
        end
    end
    -- package.loaded["app.tools.fileOpt"] = nil
end

function Game:showLaunchScreen()
    local logo_path = "app.scene.logo"
    local logo_scene = require(logo_path):create()
	package.loaded[logo_path] = nil
    logo_scene:enter()
end

function Game:refreshAndRestart(version)
    Game:purge()
    -- local FileOpt = require "app.tools.fileOpt"
    local file_utils = cc.FileUtils:getInstance()
    file_utils:setSearchPaths({})
    local suffix = ""
    -- local suffix = fs.Utils:isCryptoEnabled() and "/" or "_raw/"
    -- if version then
    --     local up_dir = file_utils:getWritablePath() .. version
    --     if FileOpt.isDir(up_dir) then
    --         file_utils:addSearchPath(up_dir .. "/src" .. suffix)
    --         file_utils:addSearchPath(up_dir .. "/res" .. suffix)
    --     end
    -- end
    file_utils:addSearchPath("src" .. suffix)
    file_utils:addSearchPath("res" .. suffix)
    -- if fs.Utils.initCN then
    --     fs.Utils:initCN("spinejson", "spinejson/zh")
    -- end
    package.loaded["app.game"] = nil
    Game = require "app.game"
    Game:restart()
end

return Game
