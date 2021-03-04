-- resolution adapt
-- local userdata = require "app.data.userData"
local view = {}

view.logical = {
    w = CC_DESIGN_RESOLUTION.width,
    h = CC_DESIGN_RESOLUTION.height
}

-- 出于兼容性的考虑，保留 view.physical
-- 指代设计分辨率坐标下的屏幕尺寸（长或宽有改变的设计分辨率）
view.physical = {
    w = display.size.width,
    h = display.size.height
}

-- 计算 max_scale 和 min_scale
view.x_scale = view.physical.w / view.logical.w
view.y_scale = view.physical.h / view.logical.h
if view.x_scale < view.y_scale then
    view.min_scale = view.x_scale
    view.max_scale = view.y_scale
else
    view.min_scale = view.y_scale
    view.max_scale = view.x_scale
end

-- 当屏幕尺寸比例，不等于设计尺寸比例时，min_x/min_y 不为 0
-- 指代尺寸差的一半，用于计算自动偏移的偏移值
view.min_x = (view.physical.w - view.logical.w) / 2
view.min_y = (view.physical.h - view.logical.h) / 2

-- 屏幕尺寸的中心点坐标
view.mid_x = display.cx
view.mid_y = display.cy
-- 设计分辨率的中心点
view.ui_mid_x = view.logical.w / 2
view.ui_mid_y = view.logical.h / 2

-- 从设备中获取的默认偏移
view.default_safe_offset = math.max(display.safe_rect.left, display.safe_rect.right)
print("view safe_offset default value: " .. view.default_safe_offset)

-- 用户设置偏移值小于 1.0 时，改为默认值，否则设置为新的偏移
view.refreshOffset = function()
    -- local user_offset = userdata.getInt(userdata.KEYS.FIX_BAR_OFFSET, 0)
    -- if math.floor(user_offset) == 0 then
    --     view.safe_offset = view.default_safe_offset
    -- else
    --     view.safe_offset = user_offset
    --     print("view safe_offset user value: " .. view.safe_offset)
    -- end
end

-- 更新偏移 view.safe_offset，考虑用户设置值
view.refreshOffset()

return view
