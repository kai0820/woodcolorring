local UIRichElementNewLine = class("UIRichElementNewLine")

function UIRichElementNewLine:ctor()
    self.type = fs.RichText.ELEMENT_TYPE.NEWLINE
end

return UIRichElementNewLine