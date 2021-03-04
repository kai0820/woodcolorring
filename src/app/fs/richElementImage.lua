local UIRichElementImage = class("UIRichElementImage")

function UIRichElementImage:ctor(info)
    self.type = fs.RichText.ELEMENT_TYPE.IMAGE
    self.name = info.name or ""
    self.scale = info.scale
    self.width = info.width
    self.height = info.height
    self.icon = info.icon
end

return UIRichElementImage