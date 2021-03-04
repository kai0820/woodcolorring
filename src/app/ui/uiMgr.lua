local UIMgr = {}

-- UIMgr.UI_INDEX = {
-- 	UI_LOGIN_MAIN = "app.ui.login.loginMain",
-- 	UI_LOGIN_UPDATE = "app.ui.login.loginUpdate",
-- 	UI_ARENA_MAIN = "app.ui.arena.arenaMain",
-- 	UI_TOWN_MAIN = "app.ui.town.townMain",
-- 	UI_TIPS_EQUIP = "app.ui.tips.tipsEquip",
-- 	UI_TIPS_ITEM = "app.ui.tips.tipsItem",
-- 	UI_TIPS_REWARDS = "app.ui.tips.tipsRewards",
-- 	UI_TIPS_DROPS = "app.ui.tips.tipsDrops",
-- }

UIMgr.UI_TYPE = {
	DEFAULT = 0,
	MULTI = 1, -- 非唯一界面，此类型界面同一时间可以打开多个
	MAIN_SCENE = 2, -- 主要的场景,打开此界面的时候会清空历史ui记录
    SINGLE_FULL_SCREEN = 3, -- 全屏界面,并且打开此界面的时候需要关闭其他所有界面
    FULL_SCREEN_NOT_EMTER_STACK = 4, -- 全屏界面,不进入ui_stack，不会因为handbackevent而被打开
}

-- 缩放方式
UIMgr.UI_ACTION = {
	SCALE_IN = 1,
}

-- 返回方式
UIMgr.UI_BACK = {
	BUILDINGS = 1, -- 建筑：返回主城
	NATURE = 2 -- 自然：返回来源界面
}

local NODE_TAG = {
	DIALOG = 1,
	DIALOG_TOP = 2,
	TOAST = 3,
	WAIT_NET = 4,
}

local NODE_Z_ORDER = {
	TOAST = 100,
	DIALOG = 200,
	WAIT_NET = 10000,
	DIALOG_TOP = 20000,
	LOADING = 1000,
}

function UIMgr:init(scene)
	self.scene = scene
	self.main_node = cc.Node:create()
	self.menu_node = cc.Node:create()
	self.popup_node = cc.Node:create()
	self.tutorial_node = cc.Node:create()

	self.swallow_touches_node = GApi.createSwallowTouchesNode()
	self.swallow_touches_node:setTouchEnabled(true)
	self:enableTouches()

	scene:addChild(self.main_node, 1)
	scene:addChild(self.menu_node, 2)
	scene:addChild(self.tutorial_node, 3)
	scene:addChild(self.popup_node, 4)
	scene:addChild(self.swallow_touches_node, 5)
	self.ui_array = {}
	self.ui_stack = {}
	self.dialog_array = {}
	self.top_zorder = 0
	self.loading_flag = 0
	self:addKeyboardEventListener()
end

function UIMgr:showUI(ui_obj, ui_data)
	ui_data = ui_data
	if not ui_data then
		print("can not find " .. ui_obj.ui_index .. " from config")
		return
	end
	if not ui_data.ui_params then
		ui_data.ui_params = ui_obj.ui_params
	end

	local ui_type = ui_data.ui_type
	if ui_type ~= UIMgr.UI_TYPE.MULTI and self:checkOpenState(ui_obj) then
		return
	end
	if ui_type then
		if ui_type == UIMgr.UI_TYPE.MAIN_SCENE then
			if #self.ui_array > 0 then
				self:closeAllUI()
			end
			self.ui_stack = {}
		elseif ui_type == UIMgr.UI_TYPE.SINGLE_FULL_SCREEN or 
			   ui_type == UIMgr.UI_TYPE.FULL_SCREEN_NOT_EMTER_STACK then
			for k, v in ipairs(self.ui_array) do
				if v.ui_data.ui_type ~= UIMgr.UI_TYPE.FULL_SCREEN_NOT_EMTER_STACK then
					table.insert(self.ui_stack, {ui_class = v.class, ui_data = v.ui_data})
				end
			end
			if #self.ui_array > 0 then
				self:closeAllUI()
			end
			print("=====================ui_stack num:" .. #self.ui_stack)
		end
	end

	local top_ui = self.ui_array[#self.ui_array]
	if top_ui then
		top_ui:onCover()
	end

	table.insert(self.ui_array, ui_obj)
	self.top_zorder = self.top_zorder + 1

	print("going to show:" .. ui_obj.ui_index)
	local root_node = cc.Node:create()
	self.main_node:addChild(root_node, self.top_zorder)

	local res_list = ui_obj:getNeedLoadListBeforeInit()
	if res_list then
		ui_obj:_setRoot(root_node, ui_data)
		self.loading_flag = self.loading_flag + 1
		ui_obj:_showLoadingBeforeCreate(res_list, function()
			self.loading_flag = self.loading_flag - 1
			ui_obj:_init()
		end)
	else
		ui_obj:_initWithNode(root_node, ui_data)
	end
end

function UIMgr:showDefaultConfigUI(ui_path, replace, params)
	-- 从这里进入的都是不能重复打开的界面，需要拦截，不拦截会因为二次create导致一些bug
	local ui_obj_tmp = {}
	ui_obj_tmp.ui_index = ui_path
	if self:checkOpenState(ui_obj_tmp) then
		print("WARN: adapt ui and skip create instance for opened: " .. ui_obj_tmp.ui_index)
		return
	end
	local ui_obj = require(ui_path):create(params)
	ui_obj:_setUIIndex(ui_path)
	local ui_data = {
		default_config = true,
		ui_index = ui_path,
		ui_params = params,
		ui_type = replace and UIMgr.UI_TYPE.SINGLE_FULL_SCREEN or UIMgr.UI_TYPE.DEFAULT,
	}
	self:showUI(ui_obj, ui_data)
end

-- 根据 ui_index 判断界面是否在打开
-- 如果已经打开，返回位置，否则返回 nil
function UIMgr:isOpen(ui_index)
	local ui_num = #self.ui_array
	if ui_num > 0 then
		for index = ui_num, 1, -1 do
			if self.ui_array[index].ui_index == ui_index then
				return index
			end
		end
	end
	return nil
end

-- 检查界面打开情况，可能调整界面
function UIMgr:checkOpenState(ui_obj)
	local open_index = self:isOpen(ui_obj.ui_index)
	-- 如果这个界面已经打开，并且不是最顶层
	if open_index and open_index < #self.ui_array then
		self:adaptOpenUI(open_index)
	end
	return open_index
end

-- 调整已经打开的界面，将 index 位置置顶
function UIMgr:adaptOpenUI(index)
	local ui_num = #self.ui_array
	local type = self.ui_array[index].ui_data.ui_type
	if type == UIMgr.UI_TYPE.MAIN_SCENE or type == UIMgr.UI_TYPE.SINGLE_FULL_SCREEN or
	type == UIMgr.UI_TYPE.FULL_SCREEN_NOT_EMTER_STACK then
		-- 关闭此界面之上的所有界面
		for j = ui_num, index + 1, -1 do
			local close_ui_obj = table.remove(self.ui_array)
			print("going to hide ui by adapt open:" .. close_ui_obj.ui_index)
			close_ui_obj:_onClose()
			close_ui_obj.root:removeFromParent()
		end
		local reshow_ui = self.ui_array[index]
		self.top_zorder = reshow_ui:_getUIZOrder()
		reshow_ui:onShow()
	else
		-- 将此界面放到所有界面的最顶层
		self.ui_array[ui_num]:onCover()
		local obj = table.remove(self.ui_array, index)
		table.insert(self.ui_array, obj)
		self.top_zorder = self.top_zorder + 1
		obj.root:setLocalZOrder(self.top_zorder)
		obj:onShow()
	end
end

function UIMgr:closeUI(ui_obj)
	local ui_num = #self.ui_array
	local remove_index = 0
	for i = ui_num, 1, -1 do
		if ui_obj == self.ui_array[i] then
			remove_index = i
			table.remove(self.ui_array, i)
			break
		end
	end
	if remove_index <= 0 then
		print(ui_obj.ui_index .. " is not open")
		return
	end
	print("going to hide:" .. ui_obj.ui_index)
	ui_obj:_onClose()
	ui_obj.root:removeFromParent()
	if remove_index == ui_num then -- 需要关闭的界面在最上层
		ui_num = ui_num - 1
		if ui_num > 0 then
			local top_ui = self.ui_array[ui_num]
			self.top_zorder = top_ui:_getUIZOrder()
			top_ui:onShow()
		end
	end
end

function UIMgr:closeAllUI()
	local ui_num = #self.ui_array
	for i = ui_num, 1, -1 do
		local obj = table.remove(self.ui_array)
		print("going to hide ui by closeall:" .. obj.ui_index)
		obj:_onClose()
	end
	self.main_node:removeAllChildren()

	-- local new_node = cc.Node:create()
	-- self.scene:addChild(new_node, 1)
	-- local next_frame_removed_node = self.main_node
	-- self.main_node = new_node
	-- next_frame_removed_node:setVisible(false)
	-- next_frame_removed_node:pause()
	-- local renderer_recreated_listener = nil
	-- renderer_recreated_listener = cc.EventListenerCustom:create("director_before_draw", function (eventCustom)
	--     next_frame_removed_node:getEventDispatcher():removeEventListener(renderer_recreated_listener)
	-- 	next_frame_removed_node:removeFromParent()
	-- 	next_frame_removed_node = nil
    -- end)
    -- next_frame_removed_node:getEventDispatcher():addEventListenerWithFixedPriority(renderer_recreated_listener, -1)
	for k, v in ipairs(self.dialog_array) do
		self.popup_node:removeChild(v)
	end
	self.dialog_array = {}
	self.top_zorder = 0
	self.ui_array = {}
	self:removeTutorial()
end

function UIMgr:getTopUIIndex()
	local top_ui = self.ui_array[#self.ui_array]
	return top_ui and top_ui.ui_index or ""
end

function UIMgr:getUIByIndex(index)
	for k, v in ipairs(self.ui_array) do
		if v.ui_index == index then
			return v
		end
	end
	return nil
end

function UIMgr:closeTopUI()
	local index = self:getTopUIIndex()
	local ui_obj = self:getUIByIndex(index)
	self:closeUI(ui_obj)
end

function UIMgr:enableTouches()
	self.swallow_touches_node:setSwallowTouches(false)
end

function UIMgr:disableTouches()
	self.swallow_touches_node:setSwallowTouches(true)
end

function UIMgr:isBlockTouch()
	return self.swallow_touches_node:isVisible()
end

function UIMgr:getMainScene()
	return self.scene
end

function UIMgr:removeAllEventListeners()
	self.scene:getEventDispatcher():removeAllEventListeners()
end

function UIMgr:addKeyboardEventListener()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
		local listener = cc.EventListenerKeyboard:create()
		listener:registerScriptHandler(function (keyCode, event)
			if keyCode == cc.KeyCode.KEY_BACK then
				self:onBackEvent()
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		self.scene:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.scene)
	elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
		local listener = cc.EventListenerKeyboard:create()
		listener:registerScriptHandler(function (keyCode, event)
			if keyCode == cc.KeyCode.KEY_BACKSPACE or keyCode == cc.KeyCode.KEY_BACK then
				self:onBackEvent()
			elseif keyCode == cc.KeyCode.KEY_F10 then
				local texture_info = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
				print("-------------------------texture_info------------------------------{")
				print(texture_info)
				print("}-------------------------texture_info------------------------------")
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		self.scene:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.scene)
	end
end

function UIMgr:onBackEvent()
	if self.popup_node:getChildByTag(NODE_TAG.DIALOG_TOP) ~= nil then
		return
	end
	if self.popup_node:getChildByTag(NODE_TAG.WAIT_NET) ~= nil then
		return
	end
	if #self.dialog_array > 0 then
		self:removeDialog(self.dialog_array[#self.dialog_array])
		return
	end
	if self.loading_flag > 0 then
		return
	end
	-- if require("app.data.tutorial").exists() then
	-- 	GApi.exitGame()
	-- 	return
	-- end
	local top_ui = self.ui_array[#self.ui_array]
	if top_ui and top_ui:isBackEventEnabled() then
		top_ui:handleBackEvent()
	end
end

-- 清除一层废弃的栈数据
function UIMgr:cleanUpWasteStack()
	local stack_ui_num = #self.ui_stack
	local tmp_ui_array = {}
	for i = stack_ui_num, 1, -1 do
		local stack_ui_obj = self.ui_stack[i]
		local stack_ui_data = stack_ui_obj.ui_data
		if stack_ui_data.ui_type == UIMgr.UI_TYPE.MAIN_SCENE then
			break
		elseif stack_ui_data.ui_type == UIMgr.UI_TYPE.SINGLE_FULL_SCREEN then
			table.remove(self.ui_stack)
			break
		else
			table.remove(self.ui_stack)
		end
	end
end

-- 关闭当前打开的所有非全屏界面
function UIMgr:closeArrayUI()
	if #self.ui_array <= 1 then
		return
	end
	for i = #self.ui_array, 1, -1 do
		local top_ui = self.ui_array[i]
		if top_ui then
			if top_ui.ui_data.ui_type ~= UIMgr.UI_TYPE.MAIN_SCENE and 
			   top_ui.ui_data.ui_type ~= UIMgr.UI_TYPE.SINGLE_FULL_SCREEN and 
			   top_ui.ui_data.ui_type ~= UIMgr.UI_TYPE.FULL_SCREEN_NOT_EMTER_STACK then
				self:closeUI(top_ui)
			else
				break
			end
		end
	end
end

function UIMgr:backToLastUI()
	if #self.ui_array <= 1 and #self.ui_stack <= 0 then
		return
	end
	local function showStackUI(stack_ui_obj)
		local stack_ui_data = stack_ui_obj.ui_data
		local stack_ui_class = stack_ui_obj.ui_class
		if stack_ui_class:isModuleOpen() then
			local stack_ui = stack_ui_class:create(stack_ui_data.ui_params)
			if stack_ui_data.default_config then
				stack_ui:_setUIIndex(stack_ui_data.ui_index)
				self:showUI(stack_ui, stack_ui_data)
			else
				stack_ui:showUI()
			end
			return true
		end
		return false
	end
	local top_ui = self.ui_array[#self.ui_array]
	if top_ui then
		self:closeUI(top_ui)
		if #self.ui_array <= 0 then
			local stack_ui_num = #self.ui_stack
			local tmp_ui_array = {}
			for i = stack_ui_num, 1, -1 do
				local stack_ui_obj = table.remove(self.ui_stack)
				local stack_ui_data = stack_ui_obj.ui_data
				if stack_ui_data then
					if stack_ui_data.ui_type == UIMgr.UI_TYPE.MAIN_SCENE or
						stack_ui_data.ui_type == UIMgr.UI_TYPE.SINGLE_FULL_SCREEN then
						if showStackUI(stack_ui_obj) then
							for i = #tmp_ui_array, 1, -1 do
								showStackUI(tmp_ui_array[i])
							end
							break
						end
					else
						table.insert(tmp_ui_array, stack_ui_obj)
					end
				end
			end
		end
	end
end

function UIMgr:showCommonLoading(res_list, callback)
	local loading_ui = require("app.ui.common.loading"):create()
	loading_ui:setFinishCallback(callback)
	self.menu_node:addChild(loading_ui:getRootNode(), NODE_Z_ORDER.LOADING)
	loading_ui:addLoadRes(res_list)
end

function UIMgr:addDialog(node, on_top)
	if on_top then
		self.popup_node:removeChildByTag(NODE_TAG.DIALOG_TOP)
		self.popup_node:addChild(node, NODE_Z_ORDER.DIALOG_TOP, NODE_TAG.DIALOG_TOP)
	else
		table.insert(self.dialog_array, node)
		self.popup_node:addChild(node, NODE_Z_ORDER.DIALOG, NODE_TAG.DIALOG)
	end
end

function UIMgr:removeDialog(node, on_top)
	if on_top then
		self.popup_node:removeChild(node)
	else
		for k, v in ipairs(self.dialog_array) do
			if v == node then
				if v.handleBackEvent then
					v.handleBackEvent()
				end
				table.remove(self.dialog_array, k)
			end
		end
		self.popup_node:removeChild(node)
	end
end

function UIMgr:addTutorial(node)
	self.tutorial_node:removeAllChildren()
	self.tutorial_node:addChild(node)
end

function UIMgr:removeTutorial()
	self.tutorial_node:removeAllChildren()
end

function UIMgr:addToast(node)
	self.popup_node:addChild(node, NODE_Z_ORDER.TOAST, NODE_TAG.TOAST)
end

function UIMgr:clearToast()
	local toast_node = self.popup_node:getChildByTag(NODE_TAG.TOAST)
	while toast_node ~= nil do
		toast_node:removeFromParent()
		toast_node = self.popup_node:getChildByTag(NODE_TAG.TOAST)
	end
end

function UIMgr:addWaitNet(node)
	self:delWaitNet()
	self.popup_node:addChild(node, NODE_Z_ORDER.WAIT_NET, NODE_TAG.WAIT_NET)
end

function UIMgr:delWaitNet()
	self.popup_node:removeChildByTag(NODE_TAG.WAIT_NET)
end

function UIMgr:closeAndRestart(version)
	self:closeAllUI()
    self:purge()
    Game:refreshAndRestart(version)
end

function UIMgr:purge()
	self.scene:removeAllChildren()
	self.ui_array = {}
	self.ui_stack = {}
	self.dialog_array = {}
	self.top_zorder = 0
	self.loading_flag = 0
	self:removeAllEventListeners()
end

function UIMgr:uiArrayString()
	local ui_string = ">"
	for i = 1, #self.ui_array do
		local item = self.ui_array[i]
		if item.ui_index then
			local parts = string.split(item.ui_index, ".")
			ui_string = ui_string .. parts[#parts] .. ">"
		end
	end
	return ui_string
end

function UIMgr:uiStackString()
	local ui_string = ">"
	for i = 1, #self.ui_stack do
		local item = self.ui_stack[i]
		if item.ui_data.ui_index then
			local parts = string.split(item.ui_data.ui_index, ".")
			ui_string = ui_string .. parts[#parts] .. ">"
		end
	end
	return ui_string
end

return UIMgr