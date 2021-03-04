local UILabel = class("UILabel", function()
    local label = cc.Label:create()
    label._shader_type = "normal"
    return label
end)

UILabel._enableOutline = GApi.getSuperMethod(cc.Label, "enableOutline")
UILabel._setLineHeight = GApi.getSuperMethod(cc.Label, "setLineHeight")

local LABEL_TYPE = {
    TTF = "ttf",
    BMFONT = "bmf",
    CHARMAP = "charmap",
    SYSTEM = "sys"
}

function UILabel:createWithBMFont(bmfont_path, text)
    text = text or ""
    local label = UILabel:create()
    label:setBMFontFilePath(bmfont_path)
    label:setString(text)
    self._label_type = LABEL_TYPE.BMFONT
    return label
end

function UILabel:createWithSystemFont(text, font, fontSize)
    text = text or ""
    local label = UILabel:create()
    label:setSystemFontName(font)
    label:setSystemFontSize(fontSize)
    label:setString(text)
    self._label_type = LABEL_TYPE.SYSTEM
    return label
end

function UILabel:createWithTTF(text, font, fontSize)
    text = text or ""
    local ttf_config = {
        fontFilePath = font,
        fontSize = fontSize
    }
    local label = UILabel:create()
    label:initWithTTF(ttf_config, text)
    self._label_type = LABEL_TYPE.TTF
    return label
end

function UILabel:enableOutline(color, size)
    if self._label_type == LABEL_TYPE.TTF or self._label_type == LABEL_TYPE.SYSTEM then
        self:_enableOutline(color, size)
    end
end

function UILabel:setLineHeight(height)
    if self._label_type == LABEL_TYPE.TTF then
        self:_setLineHeight(height)
    end
end

function UILabel:setLabelShader(shader_type)
    if self._shader_type ~= "normal" then
        self:resetLabelShader()
    end
    local LabelHelper = require "app.tools.labelHelper"
    self._original_color = self:getColor()
    if shader_type == ShaderManager.SHADER_TYPE.GRAY then
        -- setShader 中的 label 不需要置灰，如领取奖励后的邮件奖励效果
        -- self:setColor(LabelHelper.LABEL_COLOR.LABEL_GRAY)
        self._shader_type = "gray"
    elseif shader_type == ShaderManager.SHADER_TYPE.DARK then
        self:setColor(cc.c3b(self._original_color.r*0.5, self._original_color.g*0.5,self._original_color.b*0.5))
        self._shader_type = "dark"
    elseif shader_type == ShaderManager.SHADER_TYPE.HIGHLIGHT then
        -- self:setColor(cc.c3b(self._original_color.r*1.5, self._original_color.g*1.5,self._original_color.b*1.5))
    elseif shader_type == ShaderManager.SHADER_TYPE.ICE then
        -- self:setColor(cc.c3b(self._original_color.r, self._original_color.g*1.5,self._original_color.b*2.5))
    elseif shader_type == ShaderManager.SHADER_TYPE.INJURED then
        -- self:setColor(cc.c3b(self._original_color.r*2.5, self._original_color.g,self._original_color.b))
    end
end

function UILabel:resetLabelShader()
    if self._original_color then
        self:setColor(self._original_color)
    end
    self._shader_type = "normal"
end

return UILabel