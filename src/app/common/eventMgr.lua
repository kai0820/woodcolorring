local EventMgr = {
    listeners = {}
}

EventMgr.EVENT = {
    -- TEST
    UI_EVENT_TEST = "UI_EVENT_TEST",

    -- 切换前后台
    GAME_ENTER_BACKGROUND = "GAME_ENTER_BACKGROUND",
    GAME_ENTER_FOREGROUND = "GAME_ENTER_FOREGROUND",

    UI_WOOD_COLOR_RING_UPDATE = "UI_WOOD_COLOR_RING_UPDATE",
}

function EventMgr:addEventListener(name, obj)
    if self.listeners[name] == nil then
        self.listeners[name] = {}
        setmetatable(self.listeners[name], {__mode = "k"})
    end
    self.listeners[name][obj] = obj
end

function EventMgr:removeEventListener(name, obj)
    if self.listeners[name] then
        self.listeners[name][obj] = nil
        if next(self.listeners[name]) == nil then
            self.listeners[name] = nil
        end
    end
end

function EventMgr:dispatchEvent(name, customobj)
    if self.listeners[name] then
        for k, v in pairs(self.listeners[name]) do
            v:onEventMsg(name, customobj)
        end
    end
end

function EventMgr:removeEventListenersForTarget(target)
    for k, v in pairs(self.listeners) do
        for k2, v2 in pairs(v) do
            if k2 == target then
                v[k2] = nil
                break
            end
        end
    end
end

function EventMgr:purge()
    self.listeners = {}
end

return EventMgr