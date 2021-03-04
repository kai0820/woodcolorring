local UIHelper = {}

function UIHelper:createBg2(params)
    params.url = "uires/ui/common/common_bg_2.png"
    return self:createScaleBg(params)
end

function UIHelper:createBg7(params)
    params.url = "uires/ui/common/common_bg_7.png"
    return self:createScaleBg(params)
end

function UIHelper:createScaleBg(params)
    params.size = params.size or cc.size(50, 50)
    local bg = UIImage:create(params.url)
    bg:setScale9Enabled(true)
    bg:setContentSize(params.size)
    if params.anchor then
        bg:setAnchorPoint(params.anchor)
    end
    if params.pos then
        bg:setPosition(params.pos)
    end
    return bg
end

function UIHelper:createBg(params)
    params.size = params.size or cc.size(50, 50)
    local bg = UIImage:create(params.url)
    if params.anchor then
        bg:setAnchorPoint(params.anchor)
    end
    return bg
end

function UIHelper:createCloseBtn(params)
    params.size = params.size or cc.size(50, 50)
    local btn = UIButton:create("uires/ui/common/btn_close1.png")
    btn:setPosition(params.size.width - 23, params.size.height)
    return btn
end

function UIHelper:createYBtn2(params)
    params = params or {}
    params.nor = "uires/ui/common/common_btn_2.png"
    params.label_outline_color = params.label_outline_color or COLOROUTLINE_TYPE.WHITE1
    local btn = self:createBtn(params)
    return btn
end

function UIHelper:createYBtn3(params)
    params = params or {}
    params.nor = "uires/ui/common/common_btn_3.png"
    params.label_outline_color = params.label_outline_color or COLOROUTLINE_TYPE.WHITE1
    local btn = self:createBtn(params)
    return btn
end

function UIHelper:createYBtn5(params)
    params = params or {}
    params.nor = "uires/ui/common/common_btn_5.png"
    params.label_outline_color = params.label_outline_color or COLOROUTLINE_TYPE.WHITE1
    local btn = self:createBtn(params)
    return btn
end

function UIHelper:createBtn(params)
    params = params or {}
    local btn = UIButton:create(params)
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
        params_1.color = params.label_color or COLOR_TYPE.WHITE
        params_1.outline_color = params.label_outline_color or COLOROUTLINE_TYPE.WHITE2
        params_1.outline_size = params.label_outline_size or 2
        local info_tx = LabelHelper:createFontTTF(params_1)
        btn:addChild(info_tx)
    end

    return btn
end

function UIHelper:createAward(params)
    params = params or {}
    local cell = ClassItemCell:create(params.type, params.obj, params.parent_node)
    if params.pos then
        cell.awardBgImg:setPosition(params.pos)
    end
    if params.scale then
        cell.awardBgImg:setScale(params.scale)
    end
    if params.type == ITEM_CELL_TYPE.ITEM then
        cell.lvTx:setString('x'..params.obj:getNum())
    end
    local godId = params.obj:getGodId()
    params.obj:setLightEffect(cell.awardBgImg)

    return cell
end

function UIHelper:updateAwardName(params)
    params = params or {}
    if not params.label or not params.obj then
        return
    end
    params.label:setPosition(params.pos or cc.p(0, 0))
    params.label:setString(params.obj:getName())
    params.label:enableOutline(params.obj:getNameOutlineColor(), 1)
    params.label:setColor(params.obj:getNameColor())
    params.label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
end

return UIHelper