local LabHper = {}

-- 按钮默认颜色、文字大小
LabHper.BTN_FONT = {
    Y1 = {
        COLOR = cc.c3b(0x73, 0x3b, 0x05),
        FONT_SIZE = 22,
    },
    B1 = {
        COLOR = cc.c3b(0x1e, 0x63, 0x05),
        FONT_SIZE = 22,
    },
}

function LabHper:createFontTTF(config)
    local label = cc.Label:createWithTTF(config.str or "", config.ttf or "font/gamefont.ttf", config.size or 24)
    if config.name then
        label:setName(config.name)
    end

	if config.pos then
		label:setPosition(config.pos)
	end
	if config.width then
		label:setMaxLineWidth(config.width)
    end
    
    label:setColor(config.color or GConst.COLOR_TYPE.C1)
    
    if config.outline_color then
		label:enableOutline(config.outline_color or GConst.OUTLINE_TYPE.C1, config.outline_size or 1)
    end
    if config.shadow then
		-- label:enableShadow(GlobalApi:getLabelCustomShadow(config.shadow or ENABLESHADOW_TYPE.NORMAL))
	end
	if config.anchor then
		label:setAnchorPoint(config.anchor)
    end
    
    return label
end

-- 系统字（不需要提供 TTF 文件，底层直接调用的系统接口）
-- 用于应对要创建的字，可能在 TTF 文件中不存在，比如语言设置界面
function LabHper.createFontSYS(size, text, color)
    return LabHper._create({kind = "sys", size = size, text = text, color = color})
end

-- BMFont字（用于特殊效果）
function LabHper.createFontBMF(size, text, color)
    return LabHper._create({font = 1, kind = "bmf", size, text, color})
end

-- 创建特殊效果的 Label
-- 如果只是创建普通效果的 Label，不需使用
-- 返回值类型是 cc.Sprite
-- 参数 config 参数同 _renderEffect 中 config
function LabHper.createEffectFont(size, text, config)
    local label = LabHper.createFont(size, text, LabHper.LABEL_COLOR.LABEL_WHITE)
    return LabHper._renderEffect(label, size, config)
end

-- 创建特殊效果的 Label
-- 返回值类型是 cc.Sprite
-- 如果只是创建普通效果的 Label，不需使用
-- 参数 config 参数同 _renderEffect 中 config
function LabHper.createEffectFont(size, text, config)
    local label = LabHper.createFont(size, text, LabHper.LABEL_COLOR.LABEL_WHITE)
    return LabHper._renderEffect(label, size, config)
end

-- config = { 
--     start_color = cc.c3b()/cc.c4b(), 渐变效果的起始色
--     end_color = cc.c3b()/cc.c4b(), 渐变效果的终止色
--     v_direct = cc.p(1.0, 0), 渐变效果的方向
--     mask_sprite = "*.png", 纹理效果的 png 路径
--     outline_color = cc.c3b()/cc.c4b() 描边的颜色
--     outline_size = 2 描边的宽度
--     shadow_color = cc.c3b()/cc.c4b() 阴影的颜色
--     shadow_size = cc.size() 阴影的偏移大小
-- }
function LabHper._renderEffect(label, font_size, config)
    -- 记录描边、位置信息
    local outline_size = 0
    local outline_kerning = 0
    local effect_node = nil
    local origin_anchor = label:getAnchorPoint()
    local origin_pos_x, origin_pos_y = label:getPosition()
    local mask_height = label:getContentSize().height
    local mask_width = label:getContentSize().width -- + font_size
    -- 防止描边被剪裁
    if config.outline_color ~= nil then
        outline_size = config.outline_size or 2
        outline_kerning = outline_size / 2
        mask_height = mask_height + outline_size * 2
        mask_width = mask_width + #label:getString() * outline_kerning -- 减少字符间的侵入
    end
    if config.shadow_color ~= nil then
        config.shadow_size = config.shadow_size or cc.size(0, -3)
        mask_height = mask_height + math.abs(config.shadow_size.height) * 2
    end
    -- node 到左下角
    local putToBL = function(node)
        node:setPosition(0, 0)
        node:setAnchorPoint(cc.p(0, 0))
    end
    -- node 到左中部
    local putToLC = function(node)
        node:setPosition(outline_size, mask_height/2)
        node:setAnchorPoint(cc.p(0, 0.5))
    end
    -- 外层描边
    if config.outline_color ~= nil then
        config.outline_color = cc.convertColor(config.outline_color, "4b")
        effect_node = LabHper.createFontTTF(font_size, label:getString(), cc.c4b(0, 0, 0, 0))
        effect_node:enableOutline(config.outline_color, outline_size)
        label:setAdditionalKerning(outline_kerning)
        effect_node:setAdditionalKerning(outline_kerning)
        putToLC(effect_node)
    end
    if config.shadow_color ~= nil then
        config.shadow_color = cc.convertColor(config.shadow_color, "4b")
        effect_node:enableShadow(config.shadow_color, config.shadow_size)
    end
    -- Label 作为外形
    local mask_shape = label
    putToLC(mask_shape)
    -- 纹理作为显示内容
    local mask_content = nil
    if config.start_color ~= nil then
        config.start_color = cc.convertColor(config.start_color, "4b")
        config.end_color = cc.convertColor(config.end_color, "4b")
        mask_content = cc.LayerGradient:create(config.start_color, config.end_color, config.v_direct)
        mask_content:changeWidthAndHeight(mask_width, mask_height)
    else
        assert(config.mask_sprite ~= nil)
        mask_content = cc.Sprite:create(config.mask_sprite)
        mask_content:setScaleX(mask_width/mask_content:getContentSize().width)
        mask_content:setScaleY(mask_height/mask_content:getContentSize().height)
    end
    putToBL(mask_content)
    -- 取 mask_shape 的外形，和 mask_content 的内容
    local target = cc.RenderTexture:create(mask_width, mask_height)
    putToBL(target)
    putToBL(target:getSprite())
    target:begin()
    mask_shape:setBlendFunc(cc.blendFunc(gl.ONE, gl.ZERO))
    mask_shape:visit()
    mask_content:setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ZERO))
    mask_content:visit()
    target:endToLua()
    -- 渐变是根据 alpha 值做判断的，所以边框和阴影只能二次混合
    if config.outline_color ~= nil or config.shadow_color ~= nil then
        local origin_target = target
        target = cc.RenderTexture:create(mask_width, mask_height)
        putToBL(target)
        putToBL(target:getSprite())
        target:begin()
        effect_node:visit()
        origin_target:getSprite():visit()
        target:endToLua()
    end
    -- 效果混合后的 texture
    local texture = target:getSprite():getTexture()
    texture:setPremultipliedAlpha(true) -- label 不需要再次预乘
    local sprite = cc.Sprite:createWithTexture(texture)
    sprite:setFlippedY(true)
    sprite:setAnchorPoint(origin_anchor)
    sprite:setPosition(origin_pos_x - outline_size, origin_pos_y)
    return sprite
end

return LabHper