local utf8 = require "app.utils.utf8"

local UIRichText = class("UIRichText", function()
    return cc.Node:create()
end)

UIRichText.ELEMENT_TYPE = {
    LABELTTF = "LabelTTF",
    LABELBMF = "LabelBMF",
    NEWLINE = "NewLine",
    IMAGE = "Image",
    EMPTY = "Empty"
}

UIRichText.HORIZONTAL_ALIGNMENT = {
    LEFT = 1,
    CENTER = 2,
    RIGHT = 3
}

UIRichText.VERTICAL_ALIGNMENT = {
    TOP = 1,
    CENTER = 2,
    BOTTOM = 3
}

UIRichText.WRAP_MODE = {
    WRAP_PER_WORD = 1,
    WRAP_PER_CHAR = 2
}

local ASCII_DOUBLE_QUOTATION_MARK = 34 -- "
local ASCII_NUMBER_SIGN = 35 -- #
local DEFAULT_FONT_SIZE = 24
local DEFAULT_SIZE_ZERO = cc.size(0, 0)

local function getAttribute(str, name)
    local value = nil
    local start_index = string.find(str, name)
    if start_index then
        local end_index = string.find(str, " ", start_index + 1)
        if end_index then
            value = string.sub(str, start_index + #name + 1, end_index - 1)
        else
            value = string.sub(str, start_index + #name + 1)
        end
        if string.byte(value, 1) == ASCII_DOUBLE_QUOTATION_MARK then
            if string.byte(value, -1) == ASCII_DOUBLE_QUOTATION_MARK then
                value = string.sub(value, 2, #value - 1)
            else
                value = string.sub(value, 2, #value)
            end
        elseif string.byte(value, -1) == ASCII_DOUBLE_QUOTATION_MARK then
            value = string.sub(value, 1, #value - 1)
        end
    end
    return value
end

local function colorCodeToRGBA(color_code)
    local r, g, b, a
    if color_code and color_code ~= "" then
        local start_index = 1
        if string.byte(color_code, 1) == ASCII_NUMBER_SIGN then
            start_index = start_index + 1
        end
        r = tonumber(string.sub(color_code, start_index, start_index + 1), 16) or 255
        g = tonumber(string.sub(color_code, start_index + 2, start_index + 3), 16) or 255
        b = tonumber(string.sub(color_code, start_index + 4, start_index + 5), 16) or 255
        a = tonumber(string.sub(color_code, start_index + 6, start_index + 7), 16) or 255
    else
        r = 255
        g = 255
        b = 255
        a = 255
    end
    return r, g, b, a
end

local function stringToSize(str)
    local width, height = string.match(str, "(%-*%d+%.*%d*),(%-*%d+%.*%d*)")
    if width and height then
        return cc.size(tonumber(width), tonumber(height))
    else
        return DEFAULT_SIZE_ZERO
    end
end

local function getByteCount(str)
    local curByte = string.byte(str)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 240 then
        byteCount = 4
    elseif curByte > 224 then
        byteCount = 3
    elseif curByte > 192 then
        byteCount = 2
    end
    return byteCount
end

local function isNumberOrLetter(char)
    if string.find(string.sub(char, 1, 1), "%w") then
        return true
    else
        return false
    end
end

local function isUTF8CharWrappable(char)
    -- 有遗漏：比如法语 [Pourquoi j'ai] 中的 ['] 会被判断为可换行
    -- local wrapable = (getByteCount(char) > 1) or (not isNumberOrLetter(char))
    local wrapable = utf8.isSpace(char) or utf8.isCJChars(char)
    wrapable = wrapable and (not utf8.isNoBreakSpace(char))
    wrapable = wrapable and (not utf8.isCustomNoBreakChar(char))
    -- release_print(string.format("wrapable: [%s](%d) -> %s\n", char, utf8.char2codepoint(char), tostring(wrapable)))
    return wrapable
end

local function getNextWordPos(text, idx)
    if idx + 1 >= #text then
        return #text
    end
    for i = idx + 1, #text do
        if isUTF8CharWrappable(text[i]) then
            return i
        end
    end
    return #text
end

local function getPrevWordPos(text, idx)
    if idx <= 0 then
        return -1
    end
    for i = idx - 1, 1, -1 do
        if isUTF8CharWrappable(text[i]) then
            return i
        end
    end
    return -1
end

local function isWrappable(text)
    local success = false
    for k, v in ipairs(text) do
        if isUTF8CharWrappable(v) then
            success = true
            break
        end
    end
    return success
end

local function findSplitPositionForChar(label, text, estimated_index, original_left_space_width, new_line_width)
    if new_line_width <= 0 then
        return #text
    end
    local starting_new_line = (new_line_width == original_left_space_width)

    local string_length = #text
    local left_length = estimated_index

    local left_str = table.concat(text, "", 1, left_length)
    label:setString(left_str)
    local scale = label:getScale()
    local text_renderer_width = label:getContentSize().width*scale
    if original_left_space_width < text_renderer_width then
        while left_length > 0 do
            left_length = left_length - 1
            left_str = table.concat(text, "", 1, left_length)
            label:setString(left_str)
            text_renderer_width = label:getContentSize().width*scale
            if text_renderer_width <= original_left_space_width then
                break
            end
        end
    elseif text_renderer_width < original_left_space_width then
        while left_length < string_length do
            left_length = left_length + 1
            left_str = table.concat(text, "", 1, left_length)
            label:setString(left_str)
            text_renderer_width = label:getContentSize().width*scale
            if original_left_space_width < text_renderer_width then
                left_length = left_length - 1
                break
            elseif original_left_space_width == text_renderer_width then
                break
            end
        end
    end
    if left_length <= 0 then
        return starting_new_line and 1 or 0
    end
    return left_length
end

-- 参数：estimated_long_word 需要检查是否为长单词的字符串
-- 为长单词找到分割点，在按单词换行的情形内，如果一个单词超过行的长度，将这个单词改为按字符分割
local function findSplitPositionForLongWord(label, text, estimated_long_word, estimated_index, original_left_space_width, new_line_width)
    label:setString(estimated_long_word)
    local scale = label:getScale()
    local next_renderer_width = label:getContentSize().width*scale
    local is_long_word = false
    local long_idx = nil
    if next_renderer_width > new_line_width then
        is_long_word = true
        long_idx = findSplitPositionForChar(label, text, estimated_index, original_left_space_width, new_line_width)
    end
    return is_long_word, long_idx
end

local function findSplitPositionForWord(label, text, estimated_index, original_left_space_width, new_line_width)
    if new_line_width <= 0 then
        return #text
    end
    local starting_new_line = (new_line_width == original_left_space_width)
    if not isWrappable(text) then
        -- 检查长单词：整个单词（单词情形：a-long-long-word）
        local all_str = table.concat(text, "", 1, #text)
        local is_long, long_idx = findSplitPositionForLongWord(label, text, all_str, estimated_index, original_left_space_width, new_line_width)
        if is_long then
            return long_idx
        end
        return starting_new_line and #text or 0
    end
    local idx = getNextWordPos(text, estimated_index)
    local left_str = table.concat(text, "", 1, idx)
    label:setString(left_str)
    local scale = label:getScale()
    local text_renderer_width = label:getContentSize().width*scale
    if original_left_space_width < text_renderer_width then  -- Have protruding
        while true do
            local new_index = getPrevWordPos(text, idx)
            if new_index >= 0 then
                left_str = table.concat(text, "", 1, new_index)
                label:setString(left_str)
                text_renderer_width = label:getContentSize().width*scale
                if text_renderer_width <= original_left_space_width then  -- is fitted
                    idx = new_index
                    break
                end
                idx = new_index
            else
                -- 检查长单词：中部长单词（单词情形：Hello World a-long-long-word Hello World）
                local is_long, long_idx = findSplitPositionForLongWord(label, text, left_str, estimated_index, original_left_space_width, new_line_width)
                if is_long then
                    return long_idx
                end
                idx = starting_new_line and idx or 0
                break
            end
        end
    elseif text_renderer_width < original_left_space_width then -- A wide margin
        while true do
            local new_index = getNextWordPos(text, idx)
            left_str = table.concat(text, "", 1, new_index)
            label:setString(left_str)
            text_renderer_width = label:getContentSize().width*scale
            if text_renderer_width < original_left_space_width then
                if new_index == #text then
                    idx = new_index
                    break
                end
                idx = new_index
            else
                idx = text_renderer_width > original_left_space_width and idx or new_index
                break
            end
        end
    end
    -- 检查长单词：下一个单词（单词情形：Hello World a-long-long-word）
    if idx >= 1 and idx < #text then
        local next_index = getNextWordPos(text, idx)
        local next_str = table.concat(text, "", idx, next_index)
        local is_long, long_idx = findSplitPositionForLongWord(label, text, next_str, estimated_index, original_left_space_width, new_line_width)
        if is_long then
            return long_idx
        end
    end
    -- 找到合适长度的字符串后，如果下一个字符是右半符号，直接添加过去
    while true do
        if text[idx + 1] and utf8.isTailChar(text[idx + 1]) then
            idx = idx + 1
        else
            break
        end
    end
    return idx
end

function UIRichText:ctor()
    self.rich_elements = {}
    self.element_renders = {}
    self.line_heights = {}
    self.format_text_dirty = false
    self.left_space_width = 0
    self.wrap_mode = UIRichText.WRAP_MODE.WRAP_PER_WORD
    self.vertical_space = 0
    self.font_size = DEFAULT_FONT_SIZE
    self.horizontal_alignment = UIRichText.HORIZONTAL_ALIGNMENT.LEFT
    self.vertical_alignment = UIRichText.VERTICAL_ALIGNMENT.BOTTOM
end

function UIRichText:setWrapMode(wrap_mode)
    self.wrap_mode = wrap_mode
end

function UIRichText:getWrapMode()
    return self.wrap_mode
end

function UIRichText:setVerticalSpace(space)
    self.vertical_space = space
end

function UIRichText:getVerticalSpace()
    return self.vertical_space
end

function UIRichText:pushBackElement(element)
    table.insert(self.rich_elements, element)
    self.format_text_dirty = true
end

function UIRichText:insertElement(element, index)
    table.insert(self.rich_elements, index, element)
    self.format_text_dirty = true
end

function UIRichText:removeElement(index)
    table.remove(self.rich_elements, index)
end

function UIRichText:removeAllElement()
    self.rich_elements = {}
end

function UIRichText:addNewLine()
    self.left_space_width = self:getContentSize().width
    table.insert(self.element_renders, {})
    table.insert(self.line_heights, 0)
end

function UIRichText:markDirty()
    self.format_text_dirty = true
end

function UIRichText:formatText(force_format)
    if force_format or self.format_text_dirty then
        self:removeAllChildren()
        self.element_renders = {}
        self.line_heights = {}
        self:addNewLine()
        for i = 1, #self.rich_elements do
            local element = self.rich_elements[i]
            if element.type == UIRichText.ELEMENT_TYPE.LABELTTF then
                self:handleTextRenderer(element)
            elseif element.type == UIRichText.ELEMENT_TYPE.LABELBMF then
                self:handleTextRenderer(element)
            elseif element.type == UIRichText.ELEMENT_TYPE.IMAGE then
                local texture_type = element.texture_type or ccui.TextureResType.plistType
                local image_renderer
                if element.icon then
                    image_renderer = element.icon
                elseif element.name then
                    image_renderer = fs.Image:create(element.name, texture_type)
                else
                    image_renderer =  fs.Image:create()
                end
                if element.scale then
                    image_renderer:setScale(element.scale)
                end
                self:handleImageRenderer(element, image_renderer)
            elseif element.type == UIRichText.ELEMENT_TYPE.NEWLINE then
                self:addNewLine()
            elseif element.type == UIRichText.ELEMENT_TYPE.EMPTY then
                self:handleEmptyRenderer(element)
            end
        end
        self:formatRenderers()
        self.format_text_dirty = false
    end
end

function UIRichText:pushToContainer(renderer)
    if #self.element_renders <= 0 then
        return
    end
    table.insert(self.element_renders[#self.element_renders], renderer)
end

function UIRichText:formatRenderers()
    local vertical_space = self.vertical_space
    local font_size = self.font_size
    local custom_size = self:getContentSize()

    local new_content_size_height = 0
    local max_heights = {}
    for i = 1, #self.element_renders do
        local row = self.element_renders[i]
        local max_height = 0
        for j = 1, #row do
            if row[j]:getContentSize().height*row[j]:getScale() > max_height then
                max_height = row[j]:getContentSize().height*row[j]:getScale()
            end
        end
        if #row <= 0 then
            max_height = (self.line_heights[i] ~= 0 and self.line_heights[i] or font_size)
        end
        max_heights[i] = max_height
        new_content_size_height = new_content_size_height + (i > 1 and (max_height + vertical_space) or max_height)
    end
    custom_size.height = new_content_size_height

    local next_pos_y = custom_size.height
    for i = 1, #self.element_renders do
        local row = self.element_renders[i]
        local next_pos_x = 0
        next_pos_y = next_pos_y - (i > 1 and (max_heights[i] + vertical_space) or max_heights[i])
        for j = 1, #row do
            row[j]:setAnchorPoint(cc.p(0, 0))
            row[j]:setPosition(next_pos_x, next_pos_y)
            self:addChild(row[j])
            next_pos_x = next_pos_x + row[j]:getContentSize().width*row[j]:getScale()
        end
        self:doHorizontalAlignment(row, next_pos_x)
        self:doVerticalAlignment(row, max_heights[i])
    end

    self.element_renders = {}
    self.line_heights = {}
    self:setContentSize(custom_size)
end

function UIRichText:stripTrailingWhitespace(row)
    if #row > 0 then
        local node = row[#row]
        if tolua.type(node) == "cc.Label" then
            local scale = node:getScale()
            local width = node:getContentSize().width*scale
            local text = node:getString()
            local trimmed_string = string.rtrim(text)
            if text ~= trimmed_string then
                node:setString(trimmed_string)
                return node:getContentSize().width*scale - width
            end
        end
    end
    return 0
end

function UIRichText:getPaddingAmount(alignment, left_over)
    if alignment == UIRichText.HORIZONTAL_ALIGNMENT.CENTER then
        return left_over/2
    elseif alignment == UIRichText.HORIZONTAL_ALIGNMENT.RIGHT then
        return left_over
    else
        return 0
    end
end

function UIRichText:setHorizontalAlignment(alignment)
    self.horizontal_alignment = alignment
end

function UIRichText:getHorizontalAlignment()
    return self.horizontal_alignment
end

function UIRichText:doHorizontalAlignment(row, row_width)
    if self.horizontal_alignment ~= UIRichText.HORIZONTAL_ALIGNMENT.LEFT then
        local diff = self:stripTrailingWhitespace(row)
        local left_over = self:getContentSize().width - (row_width + diff)
        local left_padding = self:getPaddingAmount(self.horizontal_alignment, left_over)
        for i = 1, #row do
            row[i]:setPositionX(row[i]:getPositionX() + left_padding)
        end
    end
end

function UIRichText:setVerticalAlignment(alignment)
    self.vertical_alignment = alignment
end

function UIRichText:getVerticalAlignment()
    return self.vertical_alignment
end

function UIRichText:doVerticalAlignment(row, row_height)
    if self.vertical_alignment == UIRichText.VERTICAL_ALIGNMENT.TOP then
        for i = 1, #row do
            row[i]:setAnchorPoint(cc.p(0, 1))
            row[i]:setPositionY(row[i]:getPositionY() + row_height)
        end
    elseif self.vertical_alignment == UIRichText.VERTICAL_ALIGNMENT.CENTER then
        for i = 1, #row do
            row[i]:setAnchorPoint(cc.p(0, 0.5))
            row[i]:setPositionY(row[i]:getPositionY() + row_height/2)
        end
    end
end

function UIRichText:handleTextRenderer(element)
    local real_lines = 0
    local current_text = nil
    local start_index = 1
    local find_new_line = true
    local custom_width = self:getContentSize().width
    while find_new_line do
        local new_Line_Index = string.find(element.text, '\n', start_index)
        if new_Line_Index then
            current_text = string.sub(element.text, start_index, new_Line_Index - 1)
            start_index = new_Line_Index + 1
        else
            if start_index <= 1 then
                current_text = element.text
            else
                current_text = string.sub(element.text, start_index)
            end
            find_new_line = false
        end
        if real_lines > 0 then
            self:addNewLine()
            self.line_heights[#self.line_heights] = element.size
        end

        real_lines = real_lines + 1

        local split_parts = 0
        local utf8 = require "app.utils.utf8"
        local utf8_text = utf8.chars(current_text) or {}
        while current_text ~= "" do
            if split_parts > 0 then
                self:addNewLine()
                self.line_heights[#self.line_heights] = element.size
            end
            split_parts = split_parts + 1
            local text_renderer = nil
            if element.font_kind and element.font_kind == "sys" then
                -- text_renderer = LabelHelper.createFontSYS(element.size, current_text, element.color)
            else
                local params = {}
                params.str = current_text
                params.size = element.size
                params.color = element.color
                params.outline_color =element.outline_color
                params.ttf =element.ttf
                text_renderer = LabHper:createFontTTF(params)
            end
            -- text_renderer:setColor(element.color)
            text_renderer:setOpacity(element.opacity)
            local scale = text_renderer:getScale()
            if element.scale then
                scale = element.scale*scale
                text_renderer:setScale(scale)
            end

            local text_renderer_width = text_renderer:getContentSize().width*scale
            if text_renderer_width > 0 and self.left_space_width >= text_renderer_width then
                self.left_space_width = self.left_space_width - text_renderer_width
                self:pushToContainer(text_renderer)
                break
            end

            local estimated_index = 0
            if text_renderer_width > 0 then
                estimated_index = math.floor(self.left_space_width / text_renderer_width * #utf8_text)
            else
                estimated_index = math.floor(self.left_space_width / element.size)
            end
            local left_length = 0
            if self.wrap_mode == UIRichText.WRAP_MODE.WRAP_PER_WORD then
                left_length = findSplitPositionForWord(text_renderer, utf8_text, estimated_index, self.left_space_width, custom_width)
            else
                left_length = findSplitPositionForChar(text_renderer, utf8_text, estimated_index, self.left_space_width, custom_width)
            end
            if left_length > 0 then
                text_renderer:setString(table.concat(utf8_text, "", 1, left_length))
                self:pushToContainer(text_renderer)
            end

            local new_text = {}
            if left_length < #utf8_text then
                for i = left_length + 1, #utf8_text do
                    table.insert(new_text, utf8_text[i])
                end
            end
            utf8_text = new_text
            current_text = table.concat(utf8_text, "")
        end
    end
end

function UIRichText:handleImageRenderer(element, image_renderer)
    if image_renderer then
        if element.width or element.height then
            local size = image_renderer:getContentSize()
            local width = element.width or 0
            local height = element.height or 0
            image_renderer:setScale9Enabled(true)
            image_renderer:setContentSize(cc.size(size.width + width, size.height + height))
        end
        self:handleCustomRenderer(image_renderer)
    end
end

function UIRichText:handleEmptyRenderer(element)
    local empty = ccui.Widget:create()
    empty:setContentSize(cc.size(element.width, element.height))
    self:handleCustomRenderer(empty)
end

function UIRichText:handleCustomRenderer(renderer)
    local size = renderer:getContentSize()
    local scale = renderer:getScale()
    self.left_space_width = self.left_space_width - size.width*scale
    if self.left_space_width < 0 then
        self:addNewLine()
        self:pushToContainer(renderer)
        -- 剩余宽不够，添加新行时，left_space_width 已经在 addNewLine 中置为行宽
        -- self.left_space_width = self.left_space_width - size.width*scale
    else
        self:pushToContainer(renderer)
    end
end

function UIRichText:parseHTMLText(text)
    local start_index = 0
    local length = #text
    while start_index < length do
        start_index = string.find(text, '<', start_index + 1)
        if start_index == nil then
            print('parse text error:can not find "<"')
            break
        end
        if string.sub(text, start_index + 1, start_index + 4) == "font" then
            local paramend_index = string.find(text, '>', start_index + 4)
            if paramend_index == nil then
                print('parse font error:can not find ">"')
                break
            end
            local fontend_index = string.find(text, "</font>", paramend_index + 1)
            if fontend_index == nil then
                print('parse font error:can not find "</font>"')
                break
            end
            local content = string.sub(text, paramend_index + 1, fontend_index - 1)
            local font_param_str = string.sub(text, start_index + 5, paramend_index - 1)
            start_index = fontend_index + 6
            local font_color = getAttribute(font_param_str, "color")
            local font_size = getAttribute(font_param_str, "size")
            local font_index = getAttribute(font_param_str, "index")
            local mix = getAttribute(font_param_str, "mix")
            if font_size then
                font_size = tonumber(font_size)
            else
                font_size = DEFAULT_FONT_SIZE
            end
            local scale = getAttribute(font_param_str, "scale")
            local info = {
                size = font_size,
                text = content,
                name = getAttribute(font_param_str, "name")
            }
            if font_color then
                local r, g, b, a = colorCodeToRGBA(font_color)
                info.color = cc.c3b(r, g, b)
                info.opacity = a
            end
            if scale then
                info.scale = tonumber(scale)
            end
            if font_index then
                info.font_index = tonumber(font_index)
            end
            if mix and mix == "1" then
                info.is_mix = true
            end
            local element = fs.RichElementText:create(info)
            self:pushBackElement(element)
        elseif string.sub(text, start_index + 1, start_index + 3) == "img" then
            local paramend_index = string.find(text, '/>', start_index + 3)
            if paramend_index == nil then
                print('parse img error:can not find "/>"')
                break
            end
            local img_param_str = string.sub(text, start_index + 4, paramend_index - 1)
            start_index = paramend_index + 1
            local name = getAttribute(img_param_str, "name") or ""
            local info = {
                name = name
            }
            local scale = getAttribute(img_param_str, "scale")
            if scale then
                info.scale = tonumber(scale)
            end
            local element = fs.RichElementImage:create(info)
            self:pushBackElement(element)
        elseif string.sub(text, start_index + 1, start_index + 2) == "br" then
            local paramend_index = string.find(text, '>', start_index + 2)
            if paramend_index == nil then
                print('parse br error:can not find ">"')
                break
            end
            start_index = paramend_index
            local element = fs.RichElementNewLine:create()
            self:pushBackElement(element)
        else
            local paramend_index = string.find(text, '>', start_index + 1)
            if paramend_index == nil then
                print('parse other error:can not find ">"')
                break
            end
            start_index = paramend_index
        end
    end
end

return UIRichText