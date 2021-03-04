local SwallowTouchesNode = class("SwallowTouchesNode", function()
    return cc.Node:create()
end)

function SwallowTouchesNode:ctor()
end

function SwallowTouchesNode:setSwallowTouches(swallow)
    if self.touch_Listener and not tolua.isnull(self.touch_Listener) then
        self.touch_Listener:setSwallowTouches(swallow)
    end
end

function SwallowTouchesNode:isSwallowTouches()
    if self.touch_Listener and not tolua.isnull(self.touch_Listener) then
        return self.touch_Listener:isSwallowTouches()
    end
    return false
end

function SwallowTouchesNode:setTouchEnabled(enable)
    if self.touch_enabled == enable then
        return
    end
    self.touch_enabled = enable
    if self.touch_enabled then
        self.touch_Listener = cc.EventListenerTouchOneByOne:create()
        self.touch_Listener:setSwallowTouches(true)
        self.touch_Listener:registerScriptHandler(function(touch, event_touch)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.touch_Listener, self)
    else
        if self.touch_Listener then
            self:getEventDispatcher():removeEventListener(self.touch_Listener)
            self.touch_Listener = nil
        end
    end
end

function SwallowTouchesNode:isTouchEnabled()
    return self.touch_enabled
end

return SwallowTouchesNode