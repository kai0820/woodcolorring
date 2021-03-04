-- 启动logo界面
local LogoScene = {}

function LogoScene:create()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance:ctor()
    return instance
end

function LogoScene:ctor()
    self.scene = cc.Scene:create()
    Game:init()
    -- Game:start()

    local root_node = cc.Node:create()
    -- -- dark bg
    -- local dark_bg = cc.LayerColor:create({ r = 255, g = 255, b = 255, a = 255 })
    -- root_node:addChild(dark_bg)

    -- local win_size = cc.Director:getInstance():getWinSize()
    -- local logo = cc.Sprite:create('logo/logo.png')
    -- logo:setPosition(win_size.width/2, win_size.height/2)
    -- root_node:addChild(logo)
    -- logo:setCascadeOpacityEnabled(true)
    -- logo:setOpacity(0)
    
    -- logo:runAction(cc.Sequence:create(
    --     cc.FadeIn:create(0.5), 
    --     cc.DelayTime:create(1),
    --     cc.FadeOut:create(0.5), 
    --     cc.CallFunc:create(function()
    --         Game:start()
    --     end))
    -- )
    root_node:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            Game:start()
        end))
    )
    self.scene:addChild(root_node)
end

function LogoScene:enter()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end
end

return LogoScene