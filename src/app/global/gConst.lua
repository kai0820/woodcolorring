local GConst = {}

GConst.Z_ORDER_TOP = 10001
GConst.Z_ORDER_BOTTOM = -10001

GConst.COLOR_TYPE = {}
GConst.COLOR_TYPE.C1 = cc.c4b(0xff, 0xff, 0xff, 0xff)
GConst.COLOR_TYPE.C2 = cc.c4b(0xff, 0x00, 0x00, 0xff)
GConst.COLOR_TYPE.C3 = cc.c4b(0x00, 0xff, 0x00, 0xff)

GConst.OUTLINE_TYPE = {}
GConst.OUTLINE_TYPE.C1 = cc.c4b(0x00, 0x00, 0x00, 0xff)
GConst.OUTLINE_TYPE.C2 = cc.c4b(0x00, 0x00, 0x00, 0xff)
GConst.OUTLINE_TYPE.C3 = cc.c4b(0x00, 0x00, 0x00, 0xff)

GConst.win_size = cc.Director:getInstance():getWinSize()
GConst.logical_size = View.logical

GConst.BUTTON_EFFECT_TYPE = {
    NORMAL = 1, --常用特效
    PRESSED = 2, -- 有选中效果
    ENLARGE = 3, -- 高亮放大
}

GConst.BTN_TYPE = {
    Y1 = "Y1",
    B1 = "B1",
}

return GConst