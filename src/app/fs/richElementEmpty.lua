local UIRichElementEmpty = class("UIRichElementEmpty")

function UIRichElementEmpty:ctor(info)
    self.type = fs.RichText.ELEMENT_TYPE.EMPTY
    self.width = info.width or 0
    self.height = info.height or 0
end

return UIRichElementEmpty