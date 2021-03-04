-- 分帧异步辅助
local AsyncHelper = {}

-- 帧内的耗时限制
AsyncHelper.time_limit = 1 -- ms

-- 执行任务间隔（默认为 0，每帧执行）
AsyncHelper.do_internal = 0 -- s

-- 待添加的任务
AsyncHelper.tasks = {}

-- 添加完，但未执行结束回调的任务
AsyncHelper.dead_tasks = {}

local enable_debug_log = false

local task_id = 0

-- 添加任务到队列（先添加的任务，先处理）
-- task_body: 任务、finish_cb: 结束回调、task_info: 任务描述信息
-- type：任务类型，用于保证 plist 总是在加载 json 之前加载
function AsyncHelper.pushTask(task_body, finish_cb, task_info, type)
    task_id = task_id + 1
    local task = {
        id = task_id,
        info = task_info,
        body = task_body,
        callback = finish_cb,
        type = type
    }
    table.insert(AsyncHelper.tasks, task)
end

-- 每帧执行的内容
function AsyncHelper.doTasks(ticks)
    if #AsyncHelper.tasks == 0 then
        return
    end
    if enable_debug_log and DEBUG > 0 then
        print("AsyncHelper.doTasks Ticks: ", ticks)
    end
    local start_time = GApi.getMilliSecond()
    local cur_time = start_time
    local add_list = {}
    local pri_tasks = AsyncHelper.getPriorityTasks()
    for _, task in pairs(pri_tasks) do
        task.time = 0
        table.insert(add_list, task)
        -- print("insert dead task: " .. task.info)
        table.insert(AsyncHelper.dead_tasks, task)
        if task.body then
            -- print("add: " .. task.id .. " info: " .. task.info)
            if task.callback then
                task.body(function()
                    -- print("cb: " .. task.id .. " info: " .. task.info)
                    AsyncHelper.clearDeadTask(task)
                    task.callback(task.info)
                end)
            else
                task.body()
            end
        end
        local f_time = GApi.getMilliSecond()
        task.time = f_time - cur_time
        cur_time = f_time
        local total = cur_time - start_time
        if total > AsyncHelper.time_limit then
            break
        end
    end
    AsyncHelper.clearAddTasks(add_list)
end

-- 将已添加任务，从待添加列表移除
function AsyncHelper.clearAddTasks(task_list)
    for i, task in ipairs(task_list) do
        -- 有回调的，在回调中移除记录
        if not task.callback then
            AsyncHelper.clearDeadTask(task)
        end
        GApi.arrayFilter(AsyncHelper.tasks, function(t)
            return t.id ~= task.id
        end)
    end
end

-- 回调完成，更新已执行任务表
function AsyncHelper.clearDeadTask(task)
    AsyncHelper.printLog(task)
    GApi.arrayFilter(AsyncHelper.dead_tasks, function(t)
        return t.id ~= task.id
    end)
end

-- 获得当前应该执行的任务列表
function AsyncHelper.getPriorityTasks()
    local priority_tasks = {}
    -- 优先执行 plist（纹理）的加载
    for ii, task in ipairs(AsyncHelper.tasks) do
        if task.type == ResMgr.RES_TYPE.IMAGE
            or task.type == ResMgr.RES_TYPE.PLIST then
            table.insert(priority_tasks, task)
        end
    end
    if #priority_tasks ~= 0 then
        return priority_tasks
    end
    -- 等待所有的高优先级任务执行完
    if #AsyncHelper.dead_tasks ~= 0 then
        return {}
    end
    -- 然后执行 json（依赖纹理）的加载
    for ii, task in ipairs(AsyncHelper.tasks) do
        if task.type == ResMgr.RES_TYPE.SPINE_JSON then
            table.insert(priority_tasks, task)
        end
    end
    if #priority_tasks ~= 0 then
        return priority_tasks
    end
    -- 最后是其它任务，比如 unload
    for ii, task in ipairs(AsyncHelper.tasks) do
        table.insert(priority_tasks, task)
    end
    return priority_tasks
end

function AsyncHelper.printLog(task)
    if enable_debug_log and DEBUG > 0 then
        local log = string.format("task: %d spend time: %d, info: %s", task.id, task.time, task.info)
        Log.print("AsyncHelper " .. log)
    end
end

local task_scheduler = nil
-- 启动，分帧任务
task_scheduler = ScheduleMgr:create(AsyncHelper.doTasks, AsyncHelper.do_internal)

-- 销毁，销毁时把任务做完
function AsyncHelper.purge()
    AsyncHelper.time_limit = 60 * 1000 -- ms
    AsyncHelper.doTasks()
    ScheduleMgr:destroy(task_scheduler)
end

return AsyncHelper
