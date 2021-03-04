local UIText = class("UIText", function(text_content, font_name, font_size)
    if text_content then
        return ccui.Text:create(text_content, font_name, font_size)
    else
        return ccui.Text:create()
    end
end)

return UIText