
local TestRichTextMain = class("TestRichTextMain", BaseUI)

TestRichTextMain.RES = {
    [ResMgr.RES_TYPE.PLIST] = {
        "images/common",
    },
    [ResMgr.RES_TYPE.SPINE_JSON] = {
    }
}

function TestRichTextMain:loadRes()
    ResMgr:loadResList(TestRichTextMain.RES)
end

function TestRichTextMain:onClose()
    ResMgr:unloadResList(TestRichTextMain.RES)
end

function TestRichTextMain:init()
    self:loadRes()
    local entries = {
        {
            name = "RichText",
            callback = function()
                UIMgr:showDefaultConfigUI("app.ui.test.richText.richTextNormal", true)
            end
        },
        {
            name = "RichText HTML",
            callback = function()
                UIMgr:showDefaultConfigUI("app.ui.test.richText.richTextHTML", true)
            end
        },
    }

    self:initMenu(entries)

    local close_btn = UIHelper:createBackBtn({})    
    self.root:addChild(close_btn)
    close_btn:addClickEventListener(function(sender)
        self:handleBackEvent()
    end)
end

function TestRichTextMain:initMenu(entries)
    local sv = fs.ScrollView:createWithAutoAlign()
    sv:setDirection(fs.ScrollView.DIRECTION.VERTICAL)
    sv:setContentSize(cc.size(GConst.win_size.width, GConst.win_size.height - 100))
    sv:setSpace(10)
    sv:setContainerSpace(20)
    sv:setScrollBarEnabled(false)
    self.root:addChild(sv)
    for k, v in ipairs(entries) do
        local item = fs.Text:create(v.name, "font/gamefont.ttf", 50)
        item:setTouchEnabled(true)
        item:addClickEventListener(function(sender)
            item:setScale(1)
            item:stopAllActions()
            item:runAction(cc.Sequence:create(
                cc.ScaleTo:create(3/60, 1.1),
                cc.DelayTime:create(1/60),
                cc.ScaleTo:create(3/60, 1),
                cc.DelayTime:create(1/60),
                cc.CallFunc:create(function()
                    if v.callback then
                        v.callback()
                    end
                end)
            ))
        end)
        sv:addItemWithAlign(item)
    end
    sv:setAnchorPoint(cc.p(0.5, 0.5))
    sv:setPosition(GConst.win_size.width/2, GConst.win_size.height/2)
end

return TestRichTextMain
