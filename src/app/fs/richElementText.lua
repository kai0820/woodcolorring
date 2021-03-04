local UIRichElementText = class("UIRichElementText")

function UIRichElementText:ctor(info)
    self:initTTF(info)
end

function UIRichElementText:initTTF(info)
    self.type = fs.RichText.ELEMENT_TYPE.LABELTTF
    self.color = info.color or GConst.COLOR_TYPE.C1
    self.opacity = info.opacity or 255
    self.scale = info.scale
    self.name = info.name or ""
    self.size = info.size or 24
    self.text = info.text or ""
    self.outline_color = info.outline_color
    self.ttf = info.ttf
    self.font_kind = info.font_kind -- 字体类型 “sys”
end

function UIRichElementText:setString(text)
    self.text = text or ""
end

function UIRichElementText:getContentSize()
    local params = {}
    params.str = self.text
    params.size = self.size
    params.color = self.color
    params.outline_color = self.outline_color
    params.ttf = self.ttf
    local label = LabHper:createFontTTF(params)
    local size = label:getContentSize()
    return size
end

return UIRichElementText