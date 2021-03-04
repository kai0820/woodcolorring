local ScheduleMgr = {
	data = {}
}

-- 初始化
function ScheduleMgr:init()

end

function ScheduleMgr:purge()
    for k,v in pairs(self.data) do
        self:destroy(k)
    end
end

-- 创建一个定时器
function ScheduleMgr:create(callback, interval, paused)
	local director 			= cc.Director:getInstance()
	if not director or not callback or not interval then
		return
	end

	paused = paused or false
	local schdule_id = director:getScheduler():scheduleScriptFunc(callback, interval, paused)
	self.data[schdule_id] = schdule_id
	return schdule_id
end

-- 销毁一个定时器
function ScheduleMgr:destroy(schdule_id)
	local director 			= cc.Director:getInstance()
	if not director or not schdule_id then
		return
	end
	director:getScheduler():unscheduleScriptEntry(schdule_id)
	self.data[schdule_id] 	= nil
end

return ScheduleMgr