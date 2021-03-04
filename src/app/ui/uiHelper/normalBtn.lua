local NormalBtn = class("normalBtn", fs.Button)
local BTN_DEFAULT_WIDTH = 186 + 8
local BTN_DEFAULT_HEIGHT = 62 + 4

function NormalBtn:ctor(params)
    params = params or {}
    self.btn_type = params.btn_type or GConst.BTN_TYPE.Y1
    self.btn_type_normal = params.btn_type_normal or self.btn_type
    -- self.btn_type_disable = params.btn_type_disable or GConst.BTN_TYPE.GRAY
    self:setScale9Enabled(true)
    self:initBtn(params)

    self.label_outlines = {}
    self.label_colors = {}
end

function NormalBtn:getTextureByType(type)
    local texture = ""
    if type == GConst.BTN_TYPE.Y1 then
        texture = UIHelper.commonUI.ResConf[2]
    elseif type == GConst.BTN_TYPE.B1 then
        texture = UIHelper.commonUI.ResConf[3]
    else
    end
    return texture
end

function NormalBtn:loadTextureByType()
    local normal_image = self:getTextureByType(self.btn_type_normal)
    -- local disable_image = self:getTextureByType(self.btn_type_disable)
    self:loadTextureNormal(normal_image)
    -- self:loadTextureDisabled(disable_image)
end

function NormalBtn:initBtn(params)
    self:loadTextureByType()

    if params.btn_pos then
        self:setPosition(params.btn_pos)
    end

    if params.btn_anchar then
        self:setAnchorPoint(params.btn_anchar)
    end

    if params.btn_scale then
        self:setScale(params.btn_scale)
    end

    if params.btn_parent then
        params.btn_parent:addChild(self)
    end

    params.btn_size = params.btn_size or cc.size(BTN_DEFAULT_WIDTH, BTN_DEFAULT_HEIGHT)
    params.btn_name = params.btn_name or "normal_btn"
    self:setContentSize(params.btn_size)
    self:setName(params.btn_name)

    if params.child_image then
        local child_img = dh.Image:create(params.child_image)
        child_img:setPosition(cc.p(params.btn_size.width / 2, params.btn_size.height / 2))
        self:addChild(child_img)
    end

    if params.label_str then
        params.label_str = params.label_str or ""
        params.label_font_size = params.label_font_size or LabelHelper.BTN_FONT_LABEL[self.btn_type].FONT_SIZE
        params.label_color = params.label_color or LabelHelper.BTN_FONT_LABEL[self.btn_type].COLOR
        params.label_pos = params.label_pos or cc.p(params.btn_size.width / 2, params.btn_size.height / 2 + 2)
        params.label_kind = params.label_kind or "ttf"

        local btn_label
        if params.label_kind == "ttf" then
            btn_label = LabelHelper.createFont(params.label_font_size, params.label_str, params.label_color)
        elseif params.label_kind == "sys" then
            btn_label = LabelHelper.createFontSYS(params.label_font_size, params.label_str, params.label_color)
        end

        btn_label:setPosition(params.label_pos)
        btn_label:setName("btn_label")
        self:addChild(btn_label)
        self.btn_label = btn_label
        local UIHelper = require "app.tools.uiHelper"
        UIHelper.fixLabelOverflow(self, self.btn_label)
    end
end

-- 用于重设 button 的文字，会自动调整 label 的越界
function NormalBtn:setLabelStr(str)
    if self.btn_label then
        self.btn_label:setString(str)
        local UIHelper = require "app.tools.uiHelper"
        UIHelper.fixLabelOverflow(self, self.btn_label)
    end
end

-- 用于重设 label 的可见性
function NormalBtn:setLabelVisible(flag)
    if self.btn_label then
        self.btn_label:setVisible(flag)
    end
end

function NormalBtn:shaderGray()
    self:setBright(false)
    self:setTouchEnabled(false)

    local children = self:getChildren()
    for i, v in ipairs(children) do
        local lua_type = tolua.type(v)
        if lua_type == "ccui.ImageView" then
            ShaderMger:setShader(v, ShaderMger.SHADER_TYPE.GRAY, true)
        elseif lua_type == "cc.Label" then
            local btn_name = v:getName()
            if v:getOutlineSize() > 0 then
                self.label_colors[btn_name] = v:getTextColor()
                local effect_color = v:getEffectColor()
                self.label_outlines[btn_name] = cc.c3b(effect_color.r * 255, effect_color.g * 255, effect_color.b * 255)
                v:disableEffect()
            end
            v:setTextColor(LabHper.BTN_FONT_LABEL.GRAY.COLOR)
        end
    end
end

function NormalBtn:shaderRecovery()
    self:setBright(true)
    self:setTouchEnabled(true)

    local children = self:getChildren()
    for i, v in ipairs(children) do
        local lua_type = tolua.type(v)
        if lua_type == "ccui.ImageView" then
            ShaderMger:resetShader(v, true)
        elseif lua_type == "cc.Label" then
            local btn_name = v:getName()
            if btn_name == "btn_label" then
                v:setTextColor(LabelHelper.BTN_FONT_LABEL[self.btn_type].COLOR)
            else
                if self.label_colors[btn_name] then
                    v:setTextColor(self.label_colors[btn_name])
                end
                if self.label_outlines[btn_name] then
                    v:enableOutline(self.label_outlines[btn_name], 2)
                end
            end
        end
    end
end

return NormalBtn