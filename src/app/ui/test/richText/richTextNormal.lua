local RichTextTest = class("RichTextTest", BaseUI)

function RichTextTest:ctor(ui_params)
    self.ui_params = ui_params
end

function RichTextTest:init()
    self:loadRes()
    self:initUI()
end

function RichTextTest:onClose()
    self:unloadRes()
end

function RichTextTest:initUI()
    local close_btn = UIHelper:createBackBtn({})    
    self.root:addChild(close_btn)
    close_btn:addClickEventListener(function(sender)
        self:handleBackEvent()
    end)

    self:initRichText()
end

function RichTextTest:loadRes()

end

function RichTextTest:unloadRes()

end

function RichTextTest:initRichText()
    local richText = fs.RichText:create()
    richText:setAnchorPoint(cc.p(0, 1))
    richText:setContentSize(cc.size(400, 100))
    richText:setPosition(GConst.win_size.width/2 - 300, GConst.win_size.height - 200)
    richText:setVerticalAlignment(fs.RichText.VERTICAL_ALIGNMENT.CENTER)

    local label_info = { -- 系统字
        size = 24,
        text = "Browse the\nlatest developer documentation including API reference, articles, and sample code.",
        color = cc.c3b(255, 0, 255),
    }
    local label_element = fs.RichElementText:create(label_info)
    richText:pushBackElement(label_element)

    local image_info = {
        name = UIHelper.commonUI.ResConf[1]
    }
    local image_element = fs.RichElementImage:create(image_info)
    richText:pushBackElement(image_element)

    local newline_element = fs.RichElementNewLine:create()
    richText:pushBackElement(newline_element)

    local label_info_2 = { -- bmfont
        size = 24,
        font_index = 1,
        text = "show some test, thie is bmfont text",
        color = cc.c3b(255, 255, 0),
    }
    local label_element_2 = fs.RichElementText:create(label_info_2)
    richText:pushBackElement(label_element_2)

    local image_info_2 = {
        name = UIHelper.commonUI.ResConf[2],
        scale = 2
    }
    local image_element_2 = fs.RichElementImage:create(image_info_2)
    richText:pushBackElement(image_element_2)

    local label_info_3 = {
        size = 24,
        font_index = 1,
        text = "show some test, thie is mix text",
        color = cc.c3b(255, 0, 0),
    }
    local label_element_3 = fs.RichElementText:create(label_info_3)
    richText:pushBackElement(label_element_3)

    richText:formatText()

    self.root:addChild(richText)
end

return RichTextTest
