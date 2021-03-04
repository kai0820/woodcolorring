local HelperBase = {}

function HelperBase:createImgById(params)
    if not params.id then
        return
    end
    params.url = self.ResConf[params.id]
    return self:_createImg(params)
end

function HelperBase:createImg(params)
    return self:_createImg(params)
end

function HelperBase:createBtnById(params)
    if not params.id then
        return
    end
    params.nor = self.ResConf[params.id]
    return self:_createBtn(params)
end

function HelperBase:createBtn(params)
    return self:_createBtn(params)
end

function HelperBase:_createBtn(params)
    params = params or {}
    local btn = fs.Button:create(params)
    if params.parent_node then
        params.parent_node:addChild(btn)
    end
    if params.size then
        btn:setScale9Enabled(true)
        btn:setContentSize(params.size)
    end
    if params.pos then
        btn:setPosition(params.pos)
    end
    if params.label_str then
        local size = btn:getContentSize()
        local params_1 = {}
        params_1.str = params.label_str
        params_1.size = params.label_size
        params_1.pos = params.label_pos or cc.p(size.width/2, size.height/2)
        params_1.name = params.label_name or "info_tx"
        params_1.color = params.label_color or GConst.COLOR_TYPE.C1
        params_1.outline_color = params.label_outline_color or GConst.OUTLINE_TYPE.C1
        params_1.outline_size = params.label_outline_size or 2
        local info_tx = LabHper:createFontTTF(params_1)
        btn:addChild(info_tx)
    end

    return btn
end

function HelperBase:_createImg(params)
    local img = fs.Image:create(params.url)
    if params.size then
        img:setTouchEnabled(true)
        img:setContentSize(params.size)
    end
    if params.scale then
        img:setScale(params.scale)
    end
    if params.pos then
        img:setPosition(params.pos)
    end
    if params.parent then
        params.parent:addChild(img)
    end
    if params.name then
        img:setName(params.name)
    end
    return img
end

return HelperBase