local BaseUI = {
	_is_already_closed = false
}

-- 构造函数，界面对象创建时调用
function BaseUI:ctor()
end

-- 初始化函数，界面初始化的时候调用
function BaseUI:_init()
	self:init()
	self:registerEvent()
end

-- 初始化函数，界面初始化的时候调用
function BaseUI:init()
end

-- 显示界面
function BaseUI:showUI()
	UIMgr:showUI(self)
end

-- 关闭界面
function BaseUI:closeUI()
	UIMgr:closeUI(self)
end

-- 当此界面之上的其他界面都关闭，导致此界面处于最顶层时调用，第一次创建此界面的时候不会调用
function BaseUI:onShow()
end

-- 当此界面处于最顶层的时候打开一个新的界面添加到此界面之上时调用
function BaseUI:onCover()
end

-- 当此界面关闭时调用
function BaseUI:onClose()
end

-- 此界面是否已经关闭了
function BaseUI:isClosed()
	return self._is_already_closed
end

-- 是否响应返回事件
function BaseUI:isBackEventEnabled()
	return true
end

-- 清除一层废弃的栈数据
function BaseUI:cleanUpWasteStack()
	UIMgr:cleanUpWasteStack()
end

-- 关闭当前打开的所有非全屏界面
function BaseUI:closeArrayUI()
	UIMgr:closeArrayUI()
end

-- 处理返回事件，默认是打开上一级的历史全屏界面和closeall关闭的非全屏界面
-- close_array_ui 关闭当前打开的所有非全屏界面，处理那种一个确定按钮就要关闭几个界面的情况
function BaseUI:handleBackEvent(close_array_ui)
	-- 对于主城类型，统一返回主城
	if self and self.ui_back == UIMgr.UI_BACK.BUILDINGS then
		require("app.ui.town.townMgr"):showTownMain()
	else
		-- 按自然方式返回（目前只有两种）
		if self and close_array_ui then
			self:closeArrayUI()
		end
		UIMgr:backToLastUI()
	end
end

-- 打开界面之前是否要先加载资源并显示loading界面
function BaseUI:getNeedLoadListBeforeInit()
	return nil
end

function BaseUI:registerEvent()
end

function BaseUI:unregisterEvent()
end

function BaseUI:onEventMsg(params)
	print("no onEventMsg enent = ", params.event_name)
end

-- 界面的自定义事件添加监听
function BaseUI:addCustomEventListener(key, func)
	CustomEventMgr:addEventListener(key, self, func)
	self._event_listeners = self._event_listeners or {}
	self._event_listeners[key] = 1
end

-- 界面的自定义事件移除监听
function BaseUI:removeCustomEventListener(key)
	CustomEventMgr:removeEventListener(key, self)
	if self._event_listeners then
		self._event_listeners[key] = nil
	end
end

-- 界面创建定时器
function BaseUI:addSchedule(func, interval, paused)
    local schedule_id = ScheduleMgr:create(func, interval, paused)
	self._schedule_ids = self._schedule_ids or {}
	self._schedule_ids[schedule_id] = schedule_id
	return schedule_id
end

-- 界面销毁定时器
function BaseUI:removeSchedule(schedule_id)
	ScheduleMgr:destroy(schedule_id)
	if self._schedule_ids then
		self._schedule_ids[schedule_id] = nil
	end
end

-- 界面动画
function BaseUI:runEnterAction(node, action_type, callback)
	if action_type == UIMgr.UI_ACTION.SCALE_IN then
		node:setScale(0.1)
		if callback then
			node:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))), cc.CallFunc:create(callback))
		else
			node:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)))
		end
	end
end

function BaseUI:isModuleOpen()
	return true
end

function BaseUI:checkTutorial(ui_index)
	-- local tuto_Mgr = require("app.ui.tutorial.tutorialMgr")
	-- tuto_Mgr:checkTutorial({ui_index = ui_index or self.ui_index})
end

function BaseUI:disableTouches(time, callback)
	self.swallow_touches_node:stopAllActions()
	self.swallow_touches_node:setLocalZOrder(GConst.Z_ORDER_SWALLOW_TOP)
	if time and tonumber(time) then
		self.swallow_touches_node:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function()
			self:enableTouches()
			if callback then
				callback()
			end
		end)))
	end
end

function BaseUI:enableTouches()
	self.swallow_touches_node:setLocalZOrder(GConst.Z_ORDER_BELOW_BOTTOM)
end

function BaseUI:scaleBGMgr(node, ntype, url)
	self:scaleBG(node)
end

function BaseUI:scaleBG(firstNode)
	local size = firstNode:getContentSize()
	local winSize = cc.Director:getInstance():getWinSize()
	local scale_1 = winSize.width/size.width
	local scale_2 = winSize.height/size.height
	print(size.width , size.height)
	print(scale_1 , scale_2)
	firstNode:setScale(math.max(1, math.max(scale_1, scale_2)))
end

-- ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓以下方法不要重写↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
function BaseUI:_setRoot(root_node, ui_data)
	self.root = root_node
	self.ui_data = ui_data

	local view = require("app.tools.view")
	local ui_root = fs.Widget:create()
	ui_root:setContentSize(view.logical.w, view.logical.h)
	ui_root:setPosition(view.physical.w / 2, view.physical.h / 2)
	ui_root:setName("_ui_root")
	self.root:addChild(ui_root, GConst.Z_ORDER_TOP)
	self.ui_root = ui_root
	-- GApi.drawBoundingbox(ui_root, ui_root, cc.c4f(1, 0, 0, 1))

	local swallow_touches_node = GApi.createSwallowTouchesNode()
	swallow_touches_node:setTouchEnabled(true)
	self.root:addChild(swallow_touches_node, GConst.Z_ORDER_BOTTOM)
	self.swallow_touches_node = swallow_touches_node
end

function BaseUI:_initWithNode(root_node, ui_data)
	self:_setRoot(root_node, ui_data)

	self:init()
	self:registerEvent()

	if not self.ui_params then
		self.ui_params = {}
	end

	if not self.ui_params.skip_tutorial then
		self:checkTutorial()
	end

	if self.ui_params.ui_action then
        self:runEnterAction(self.ui_root, self.ui_params.ui_action)
	end

	if self.ui_params.dark_bg then
		local dark_bg = cc.LayerColor:create(cc.c4b(0, 0, 0, GConst.POPUP_DARK_OPACITY))
		self.root:addChild(dark_bg, GConst.Z_ORDER_BOTTOM)
	end

	if self.ui_params.ui_back then
		self.ui_back = self.ui_params.ui_back
	else
		self.ui_back = UIMgr.UI_BACK.NATURE
	end
end

function BaseUI:_setUIIndex(index)
	self.ui_index = index
end

function BaseUI:_getUIZOrder()
	return self.root:getLocalZOrder()
end

function BaseUI:_onClose()
	self:onClose()
	self:unregisterEvent()
	self._is_already_closed = true
	if self._res_list then
		ResMgr:unloadResList(self._res_list)
	end
	if self._event_listeners then
		for k, v in pairs(self._event_listeners) do
			self:removeCustomEventListener(k)
		end
	end
	if self._schedule_ids then
		for k, v in pairs(self._schedule_ids) do
			self:removeSchedule(k)
		end
	end
end

function BaseUI:_showLoadingBeforeCreate(res_list, callback)
	self._res_list = res_list
	UIMgr:showCommonLoading(res_list, callback)
end

return BaseUI