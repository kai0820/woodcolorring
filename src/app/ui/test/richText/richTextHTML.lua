
local TestrRchTextHTML = class("TestrRchTextHTML", BaseUI)

function TestrRchTextHTML:init()
    local close_btn = UIHelper:createBackBtn({})    
    self.root:addChild(close_btn)
    close_btn:addClickEventListener(function(sender)
        self:handleBackEvent()
    end)

    self:initRichText()
end

function TestrRchTextHTML:initRichText()
    local richText = fs.RichText:create()
    richText:setAnchorPoint(cc.p(0, 1))
    richText:setContentSize(cc.size(400, 100))
    richText:setPosition(GConst.win_size.width/2 - 300, GConst.win_size.height - 200)

    local str = '<font color=#ff0000ff size=24>Browse the latest developer documentation including API reference, articles, and sample code.</font> \
                <font color=#ffffffff index=1 size=24>啊实打实大法规和地方:</font> \
                <img name="common/common_btn_y1.png" /> \
                <font index=1 color=#ffffffff size=24>律框架阿c中文\n氨基酸法律框架阿夫林哈拉少</font> \
                <img name="common/common_btn_b1.png" scale=1.5/> \
                <br/> \
                <font color=#00ffffff size=24>With the power of Xcode,\nthe ease of Swift, and the revolutionary features of cutting-edge Apple technologies, you have the freedom to create your most innovative apps ever.</font>'

    richText:parseHTMLText(str)

    richText:formatText()

    self.root:addChild(richText)
end

return TestrRchTextHTML
