local Toast = {}

local toast_font_size = 24
local toast_icon_scale = 0.7

function Toast:showToast(text, cd_info)
    local root = cc.Node:create()

    local params = {}
    params.str = text
    params.size = 28
    params.color = GConst.COLOR_TYPE.C3
    params.outline_color = GConst.OUTLINE_TYPE.C3
    local label = LabHper:createFontTTF(params)

    local size = label:getContentSize()
    local width = size.width
    local height = size.height
    if size.width > GConst.logical_size.width then
        label:setWidth(GConst.logical_size.width)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        width = GConst.logical_size.width
        height = label:getContentSize().height
    end
    local show_cd = 2

    if cd_info then
        size.width = clone(size.width) + 100
        show_cd = 3
    end

    local h_edge = 120 -- 水平边距
    local bg_size = cc.size(width > (480 - h_edge * 2) and width + h_edge * 2 or 480, height+ 32 * 2)
    label:setPosition(bg_size.width/2, bg_size.height/2)

    local bg = fs.Image:create("common/public_tips_board.png")
    bg:setScale9Enabled(true)
    bg:setCascadeOpacityEnabled(true)
    bg:setContentSize(bg_size)
    bg:setPosition(GConst.win_size.width/2, GConst.win_size.height/2)
    bg:setScale(0.1)
    bg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)))
    bg:addChild(label)
    root:addChild(bg)
    -- GFunc.drawBoundingbox(bg, label)

    root:runAction(cc.Sequence:create(
        cc.DelayTime:create(show_cd),
        cc.TargetedAction:create(bg, cc.FadeOut:create(0.1)),
        cc.CallFunc:create(function ()
            root:unscheduleUpdate()
        end),
        cc.RemoveSelf:create()
    ))

    UIMgr:addToast(root)
end

return Toast
