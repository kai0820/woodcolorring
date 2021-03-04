-- utf8
-- https://en.wikipedia.org/wiki/UTF-8

local utf8 = {}

local FIRST_BYTE_MARK = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc } -- utf8分界编码

-- 返回一个lua字符串，它代表一个utf8字符
-- 参数str为一个lua字符串
-- 参数index表示str的第index字节为该utf8字符的起始字节, 默认为1
-- 如果不是合法的utf8字符，返回nil
function utf8.char(str, index)
    index = index or 1
    local byte = string.byte(str, index)
    for i = #FIRST_BYTE_MARK, 1, -1 do
        if byte >= FIRST_BYTE_MARK[i] then
            return string.sub(str, index, index + i - 1)
        end
    end
    return nil
end

-- 返回一个数组，每项是一个lua字符串，代表一个utf8字符
-- 参数str为一个lua字符串
-- 若不是合法的utf8串，返回nil
function utf8.chars(str)
    local chars = {}
    local i = 1
    while i <= #str do
        local char = utf8.char(str, i)
        -- 非法字符
        if char == nil then
            return nil
        end
        -- 保存字符
        table.insert(chars, char)
        -- 已是最后一个字符
        if i + #char - 1 == #str then
            return chars
        end
        -- 增加下标
        i = i + #char
    end
    return nil
end

-- 返回utf8字符串的字符数
-- 参数str为一个lua字符串
-- 若不是合法的utf8串，返回nil
function utf8.len(str)
    local chars = utf8.chars(str)
    if chars ~= nil then
        return #chars
    end
    return nil
end

-- 返回utf8字符的codepoint
-- 参数char是一个lua字符串，它代表一个utf8字符
-- 若char不是合法的utf8字符，返回nil
function utf8.char2codepoint(char)
    if char == nil then
        return nil
    end
    local b1 = string.byte(char, 1)
    if b1 <= 0x7f then -- [U+0000, U+007F] (1 byte)
        return b1
    elseif b1 >= 0xc0 and b1 <= 0xdf then -- [U+0080, U+07FF] (2 bytes)
        local b2 = string.byte(char, 2)
        assert(b2 >= 0x80)
        return (b1-0xc0)*(2^6) + b2
    elseif b1 >= 0xe0 and b1 <= 0xef then -- [U+0800, U+FFFF] (3 bytes)
        local b2, b3 = string.byte(char, 2, 3)
        assert(b2 >= 0x80 and b3 >= 0x80)
        return (b1-0xe0)*(2^12) + b2%(2^6)*(2^6) + b3%(2^6)
    elseif b1 >= 0xf0 and b1 <= 0xf7 then -- [U+10000, U+1FFFFF] (4 bytes)
        local b2, b3, b4 = string.byte(char, 2, 4)
        assert(b2 >= 0x80 and b3 >= 0x80 and b4 >= 0x80)
        return (b1-0xf0)*(2^18) + b2%(2^6)*(2^12) + b3%(2^6)*(2^6) + b4%(2^6)
    end
    return nil
end

-- 返回一个lua字符串，它代表一个utf8字符
-- 若codepoint不合法，返回nil
function utf8.codepoint2char(codepoint)
    if codepoint <= 0x7f then -- [U+0000, U+007F] (1 byte)
        return string.char(codepoint)
    elseif codepoint <= 0x07ff then -- [U+0080, U+07FF] (2 bytes)
        return string.char(0xc0 + math.floor(codepoint/(2^6)), 
                           0x80 + codepoint%(2^6))
    elseif codepoint <= 0xffff then -- [U+0800, U+FFFF] (3 bytes)
        return string.char(0xe0 + math.floor(codepoint/(2^12)), 
                           0x80 + math.floor(codepoint/(2^6)) % (2^6), 
                           0x80 + codepoint%(2^6))
    elseif codepoint <= 0x1fffff then -- [U+10000, U+1FFFFF] (4 bytes)
        return string.char(0xf0 + math.floor(codepoint/(2^18)), 
                           0x80 + math.floor(codepoint/(2^12)) % (2^6), 
                           0x80 + math.floor(codepoint/(2^6)) % (2^6), 
                           0x80 + codepoint%(2^6))
    end

    return nil
end

-- 是不是emoji字符
-- 参数是一个lua字符串，它代表一个utf8字符
-- reference:
--     http://en.wikipedia.org/wiki/Emoji#Regional_Indicator_Symbols
--     https://www.drupal.org/node/2043439
function utf8.isEmoji(char)
    local code = utf8.char2codepoint(char)
    if code ~= nil
        and ((code >= 0x1f300 and code <= 0x1f5ff) -- Miscellaneous Symbols and Pictographs
        or (code >= 0x1f600 and code <= 0x1f64f) -- Emoticons
        or (code >= 0x1f680 and code <= 0x1f6ff) -- Transport and Map Symbols
        or (code >= 0x1f1e0 and code <= 0x1f1ff)) then -- flags from Apple iOS
        return true
    end

    return false
end

function utf8.prefix(input, plen)
    local len  = string.len(input)
    if len < plen then return input end
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if cnt >= plen then
            return string.sub(input, 1, -left-1)
        end
    end
    return ""
end

-- 以下参考：ccUTF8.cpp 文件中的方法
--  Reference: http://en.wikipedia.org/wiki/Whitespace_character#Unicode
function utf8.isSpace(char)
    local code = utf8.char2codepoint(char)
    if code ~= nil
        and ((code >= 0x0009 and code <= 0x000d)
        or (code == 0x0020)
        or (code == 0x0085)
        or (code == 0x00a0)
        or (code == 0x1680)
        or (code >= 0x2000 and code <= 0x200a)
        or (code == 0x2028)
        or (code == 0x2029)
        or (code == 0x202f)
        or (code == 0x205f)
        or (code == 0x3000))
    then
        return true
    end
    return false
end

-- 是否是中日字符（移除韩文）。是，则可以换行
-- x3130-x318F (韩文) xAC00-xD7A3 (韩文)
function utf8.isCJChars(char)
    local code = utf8.char2codepoint(char)
    if code ~= nil
        and ((code >= 0x4e00 and code <= 0x9fbf)
        or (code >= 0x2e80 and code <= 0x2fdf)
        or (code >= 0x2ff0 and code <= 0x30ff) 
        or (code >= 0x3100 and code < 0x3130) 
        or (code > 0x318f and code <= 0x31bf) 
        or (code > 0xd7a3 and code <= 0xd7af) 
        or (code >= 0xf900 and code <= 0xfaff) 
        or (code >= 0xfe30 and code <= 0xfe4f) 
        or (code >= 0x31c0 and code <= 0x4dff) 
        or (code >= 0x1f004 and code <= 0x1f004)) 
    then
        return true
    end
    return false
end

-- 不换行的空格字符，richText 不应该在此处换行
function utf8.isNoBreakSpace(char)
    local code = utf8.char2codepoint(char)
    if code ~= nil
        and ((code == 0x00a0) -- Non-Breaking Space
        or (code == 0x202f) -- Narrow Non-Breaking Space
        or (code == 0x2007) -- Figure Space
        or (code == 0x2060)) -- Word Joiner
    then
        return true
    end
    return false
end

-- 自定义的不换行字符
function utf8.isCustomNoBreakChar(char)
    -- 不在前导性质的字符处换行
    if utf8.isPreChar(char) then
        return true
    end
    return false
end

-- 成对符号的右半部分，不放在行首
--（如果在行首，移动到上一行结尾）
function utf8.isTailChar(char)
    if char ~= nil
        and ((char == "）")
        or (char == "】")
        or (char == "、")
        or (char == "，")
        or (char == "？")
        or (char == "。")
        or (char == "：")
        or (char == "；")
        or (char == "！")
        or (char == "~")
        or (char == ".") -- kr
        or (char == ",") -- kr
        or (char == ":") -- kr
        or (char == "!") -- kr
        or (char == "」"))
    then
        return true
    end
    return false
end

-- 成对符号的左半部分，不放在行尾（即不换行）
function utf8.isPreChar(char)
    if char ~= nil
        and ((char == "（")
        or (char == "【")
        or (char == "「"))
    then
        return true
    end
    return false
end

return utf8
