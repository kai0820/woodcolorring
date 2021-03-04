local ResHelper = {}

-- 白名单资源。主要 公共资源，一级UI资源
local white_list_table = {
    memory_low = {
    },
    memory_mid = {
    }
    -- 内存高时，不需要设置
}

-- 低内存设备：内存低于 low_limit，只加载一级白名单
-- 高内存设备：内存高于 low_limit，加载全部白名单，不在白名单中的资源会卸载
local memory_limits = {
    ["ios"] = {
        low_limit = 1.5 * 1000
    },
    ["android"] = {
        low_limit = 3.5 * 1000
    },
    -- mac & windows 是测试平台
    -- device.memory 固定返回 4 * 1024
    ["mac"] = {
        low_limit = 3 * 1000
    },
    ["windows"] = {
        low_limit = 3 * 1000
    }
}

-- 记录白名单
ResHelper.white_list = {}

local list_low = white_list_table.memory_low
for ii = 1, #list_low do
    ResHelper.white_list[list_low[ii]] = true
end
-- if device.memory > memory_limits[device.platform].low_limit then
--     local list_mid = white_list_table.memory_mid
--     for ii = 1, #list_mid do
--         ResHelper.white_list[list_mid[ii]] = true
--     end
-- end

-- 记录当前资源
ResHelper.current_res = {}
-- 加载时记录一次
function ResHelper:record(path, tag)
    local item = {total = 0, current = 0}
    if self.current_res[path] then
        item = self.current_res[path]
    end
    item.total = item.total + 1
    item.current = item.current + 1
    item.tag = tag -- 辅助识别标签
    self.current_res[path] = item
    -- self:dump(path, "record")
end

-- 卸载时移除一次记录
function ResHelper:unRecord(path)
    local item = self.current_res[path]
    assert(item ~= nil, "try removed must record it before for path: " .. path)
    item.current = item.current - 1
    self.current_res[path] = item
    assert(item.current >= 0, "times (load & unload) must be equal")
    -- self:dump(path, "unRecord")
end

-- 资源是否仍在被使用
function ResHelper:isUsed(path)
    return self.current_res[path].current > 0
end

-- 资源是否在白名单
function ResHelper:isWhite(path)
    return self.white_list[path]
end

-- 资源是否应该加载
function ResHelper:shouldLoad(path)
    local should = true
    -- 已经加载过一次，并且是在白名单的
    if self.current_res[path].total > 1 and self:isWhite(path) then
        should = false
    end
    if GConst.TEST_RES_RECORD then
        if should then
            Logger.printInfo("should load res: " .. path)
        else
            Logger.printInfo("skip to load res: " .. path)
        end
    end
    return should
end

-- 资源是否应该卸载
function ResHelper:shouldUnload(path)
    local should = false
    should = (not self:isUsed(path)) and (not self:isWhite(path))
    if GConst.TEST_RES_RECORD then
        if should then
            Logger.printInfo("should unload res: " .. path)
        else
            Logger.printInfo("shouldn't unload res: " .. path)
        end
    end
    return should
end

-- 获取当前内存下的白名单列表
function ResHelper:getWhiteList()
    local all_white = {}
    for item, _ in pairs(ResHelper.white_list) do
        all_white[#all_white + 1] = item
    end
    return all_white
end

function ResHelper:dump(path, when)
    Logger.printInfo(when .. " <-----")
    local record = self.current_res[path]
    local print_item = function(item, pt)
        Logger.printInfo("count: current %s, total %s, %s for path: %s", item.current, item.total, item.tag, pt)
    end
    if record then
        print_item(record, path)
        return
    end
    for pt, item in pairs(self.current_res) do
        if item.current ~= 0 then
            print_item(item, pt)
        end
    end
end

-- 每 90 秒，输出一次当前内存中的资源
local dump_scheduler = nil

if GConst.TEST_RES_RECORD then
    local scheduler = require "cocosExtend.framework.scheduler"
    dump_scheduler =
        scheduler.scheduleGlobal(
        function(dt)
            Logger.printInfo("--- Below current all resource")
            ResHelper:dump("all res", "print all")
            Logger.printInfo("Above current all resource ---")
        end,
        90
    )
end

-- 考虑热重载时，数据的重置
function ResHelper:purge()
    if dump_scheduler then
        local scheduler = require "cocosExtend.framework.scheduler"
        scheduler.unscheduleGlobal(dump_scheduler)
    end
    ResHelper.white_list = {}
    ResHelper.current_res = {}
end

-- 输出当前使用到的，但不在白名单中的资源
function ResHelper:printWhiteDiff(tag)
    print("\n")
    local existed = false
    for path, item in pairs(self.current_res) do
        if item.current ~= 0 and string.endwith(path, "plist") then
            if not GApi.arrayContains(white_list_table["memory_low"], path) and not GApi.arrayContains(white_list_table["memory_mid"], path) then
                print(string.format('"%s",', path))
                existed = true
            end
        end
    end
    if existed then
        print("<--- white list diff end for " .. tag .. "\n")
    end
end

return ResHelper
