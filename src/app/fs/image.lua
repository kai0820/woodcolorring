local UIImage = class("UIImage", function(name, tex_type)
    local image = nil
    if name then
        tex_type = tex_type or ccui.TextureResType.plistType
        image = ccui.ImageView:create(name, tex_type)
    else
        image = ccui.ImageView:create()
    end
    image.o_size = image:getVirtualRenderer():getOriginalSize()
    return image
end)

UIImage._loadTexture = GApi.getSuperMethod(ccui.ImageView, "loadTexture")
UIImage._setCapInsets = GApi.getSuperMethod(ccui.ImageView, "setCapInsets")

function UIImage:loadTexture(name, tex_type)
    tex_type = tex_type or ccui.TextureResType.plistType
    self:_loadTexture(name, tex_type)
end

-- 设置 9 宫格的分割方式
-- 参数：rect 确定 9 宫格中心格
function UIImage:setCapInsets(rect)
    rect = rect or self:_scaleCap(0.33)
    self:_setCapInsets(rect)
end

-- 设置 9 宫格的分割方式（中心格固定位于中心）
-- 参数：scale 确定中心格占全尺寸的比例
-- 参数：scale 越小，四角的纹理保存越完整，默认 0.33
function UIImage:setCapScale(scale)
    local scale = scale or 0.33
    local rect = self:_scaleCap(scale)
    self:_setCapInsets(rect)
end

-- 根据 scale 计算中心格的 rect
function UIImage:_scaleCap(scale)
    local rect = cc.rect()
    rect.width = self.o_size.width * scale
    rect.height = self.o_size.height * scale
    rect.x = (1 - scale) / 2 * self.o_size.width
    rect.y = (1 - scale) / 2 * self.o_size.height
    return rect
end

-- 设置缩放 rect 的 4 个值，相对于原始尺寸的 scale
function UIImage:setCapScale4(scale_x, scale_y, scale_w, scale_h)
    local rect = cc.rect()
    rect.x = self.o_size.width * scale_x
    rect.y = self.o_size.height * scale_y
    rect.width = self.o_size.width * scale_w
    rect.height = self.o_size.height * scale_h
    self:_setCapInsets(rect)
end

return UIImage