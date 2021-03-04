local UIButton = class("UIButton", function(params)
    local btn
    if params.nor then
        params.tex_type = params.tex_type or ccui.TextureResType.plistType
        btn = ccui.Button:create(params.nor, params.sel, params.dis, params.tex_type)
        btn.max_act_scale = params.max_act_scale or 1.1
        if params.effect_type then
            btn.effect_type = params.effect_type
        elseif params.sel then
            btn.effect_type = GConst.BUTTON_EFFECT_TYPE.PRESSED
        else
            btn.effect_type = GConst.BUTTON_EFFECT_TYPE.NORMAL
        end
        btn:setZoomScale(0)
    else
        btn = ccui.Button:create()
        btn.effect_type = GConst.BUTTON_EFFECT_TYPE.NORMAL
        btn:setZoomScale(0)
    end
    return btn
end)

UIButton._loadTextureNormal = GApi.getSuperMethod(ccui.Button, "loadTextureNormal")
UIButton._loadTexturePressed = GApi.getSuperMethod(ccui.Button, "loadTexturePressed")
UIButton._loadTextureDisabled = GApi.getSuperMethod(ccui.Button, "loadTextureDisabled")
UIButton._addClickEventListener = GApi.getSuperMethod(ccui.Button, "addClickEventListener")
UIButton._addTouchEventListener = GApi.getSuperMethod(ccui.Button, "addTouchEventListener")
UIButton._setScale = GApi.getSuperMethod(ccui.Button, "setScale")
UIButton._setScaleX = GApi.getSuperMethod(ccui.Button, "setScaleX")
UIButton._setScaleY = GApi.getSuperMethod(ccui.Button, "setScaleY")

function UIButton:loadTextureNormal(normal, tex_type)
    tex_type = tex_type or ccui.TextureResType.plistType
    self:_loadTextureNormal(normal, tex_type)
end

function UIButton:loadTexturePressed(selected, tex_type)
    self.effect_type = GConst.BUTTON_EFFECT_TYPE.PRESSED
    tex_type = tex_type or ccui.TextureResType.plistType
    self:_loadTexturePressed(selected, tex_type)
end

function UIButton:loadTextureDisabled(disabled, tex_type)
    tex_type = tex_type or ccui.TextureResType.plistType
    self:_loadTextureDisabled(disabled, tex_type)
end

function UIButton:setScale(scale)
    self:_setScale(scale)
    self.scale_x = scale or 1
    self.scale_y = scale or 1
end

function UIButton:setScaleX(scale_x)
    self:_setScaleX(scale_x)
    self.scale_x = scale_x or 1
end

function UIButton:setScaleY(scale_y)
    self:_setScaleY(scale_y)
    self.scale_y = scale_y or 1
end

-- 放宽点击判定范围
-- 避免小屏手机上，由于手指微小移动，导致的事件响应失败
UIButton.move_limit = 10
function UIButton:getRangeOnScreen()
    local pos_x, pos_y = self:getPosition()
    local anchor = self:getAnchorPoint()
    local ori_size = self:getContentSize()
    local size = cc.size(ori_size.width, ori_size.height)
    local min_pos = self:convertToWorldSpace(cc.p(0,0))
    local max_pos = self:convertToWorldSpace(cc.p(size.width,size.height))
    local tab = {
        min_x = min_pos.x - UIButton.move_limit, 
        max_x = max_pos.x + UIButton.move_limit, 
        min_y = min_pos.y - UIButton.move_limit, 
        max_y = max_pos.y + UIButton.move_limit}
    return tab
end

function UIButton:resetPositionAndAnchor()
    if self.old_anchor_point then
        self:updatePositionAndAnchor(self.old_anchor_point)
    end
end

function UIButton:clickEnd(callback, sender, state)
    if callback then
        callback(sender, state)
    end
end

function UIButton:updatePositionAndAnchor(new_anchor_point)
    local anchor_point = self:getAnchorPoint()
    if anchor_point.x ~= new_anchor_point.x or anchor_point.y ~= new_anchor_point.y then
        local ori_size = self:getContentSize()
        local size = cc.size(ori_size.width * self.scale_x, ori_size.height * self.scale_y)
        local pos_x, pos_y = self:getPosition()
        local pos_x_1 = pos_x + (new_anchor_point.x - anchor_point.x) * size.width
        local pos_y_1 = pos_y + (new_anchor_point.y - anchor_point.y) * size.height
        self:setPosition(cc.p(pos_x_1, pos_y_1))
        self:setAnchorPoint(cc.p(new_anchor_point.x,new_anchor_point.y))
    end
end

function UIButton:addEventListener(callback)
    local begin_pos
    local is_click = false
    local began_pos_in_node = cc.p(0, 0)
    self.scale_x = self.scale_x or 1
    self.scale_y = self.scale_y or 1
    self.old_anchor_point = self:getAnchorPoint()
    self:_addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
            if self.effect_type == GConst.BUTTON_EFFECT_TYPE.PRESSED then
            elseif self.effect_type == GConst.BUTTON_EFFECT_TYPE.ENLARGE then
                self:_setScaleX(self.max_act_scale * self.scale_x)
                self:_setScaleY(self.max_act_scale * self.scale_y)
                ShaderMgr:setShader(self, ShaderMgr.SHADER_TYPE.HIGHLIGHT, true)
            else
                self.old_anchor_point = self:getAnchorPoint()
                self:updatePositionAndAnchor(cc.p(0.5,0.5))
                begin_pos = sender:getTouchBeganPosition()
                is_click = true
                GApi.playAnimTouchBegin(self)
            end
        elseif state == ccui.TouchEventType.ended then
            if self.effect_type == GConst.BUTTON_EFFECT_TYPE.PRESSED then
            elseif self.effect_type == GConst.BUTTON_EFFECT_TYPE.ENLARGE then
                self:_setScaleX(1 * self.scale_x)
                self:_setScaleY(1 * self.scale_y)
                ShaderMgr:resetShader(self, true)
            else
                local end_pos = sender:getTouchEndPosition()
                if is_click then
                    is_click = false
                    GApi.playAnimTouchEnd(self, function()
                        self:clickEnd(callback, sender, state)
                    end, function ()
                        self:resetPositionAndAnchor()
                    end)
                    return
                end
            end
        elseif state == ccui.TouchEventType.canceled then
            if self.effect_type == GConst.BUTTON_EFFECT_TYPE.PRESSED then
            elseif self.effect_type == GConst.BUTTON_EFFECT_TYPE.ENLARGE then
                self:_setScaleX(1 * self.scale_x)
                self:_setScaleY(1 * self.scale_y)
                ShaderMgr:resetShader(self, true)
            else
                local end_pos = sender:getTouchEndPosition()
                local range = self:getRangeOnScreen()
                if is_click or (end_pos.x > range.min_x and end_pos.x < range.max_x and end_pos.y > range.min_y and end_pos.y < range.max_y) then
                    is_click = false
                    GApi.playAnimTouchEnd(self, function()
                        self:clickEnd(callback, sender, ccui.TouchEventType.ended)
                    end, function ()
                        self:resetPositionAndAnchor()
                    end)
                    return
                end
            end
        elseif state == ccui.TouchEventType.moved then
            if self.effect_type == GConst.BUTTON_EFFECT_TYPE.PRESSED then
            elseif self.effect_type == GConst.BUTTON_EFFECT_TYPE.ENLARGE then
                ShaderMgr:setShader(self, ShaderMgr.SHADER_TYPE.HIGHLIGHT, true)
            else
                local touch_pos = sender:getTouchMovePosition()
                local range = self:getRangeOnScreen()
                if (is_click and (touch_pos.x < range.min_x or touch_pos.x > range.max_x or touch_pos.y < range.min_y or touch_pos.y > range.max_y) ) then
                    is_click = false
                    GApi.playAnimTouchEnd(self, nil, function ()
                        self:resetPositionAndAnchor()
                    end)
                end
            end
        end
        self:clickEnd(callback, sender, state)
    end)
end

function UIButton:addTouchEventListener(callback)
    self:addEventListener(callback)
end

function UIButton:addClickEventListener(callback)
    self:addEventListener(function (sender, state)
        if state == ccui.TouchEventType.ended and callback then callback(sender) end
    end)
end

return UIButton