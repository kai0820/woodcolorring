local WoodColorRingMain = class("WoodColorRingMain", BaseUI)

local WoodColorRingCore = require "app.ui.test.woodColorRing.woodColorRingCore"
local WoodColorRingData = require "app.ui.test.woodColorRing.woodColorRingData"
local WoodColorRingUtil = require "app.ui.test.woodColorRing.woodColorRingUtil"
local WoodColorRingCfg = require "app.ui.test.woodColorRing.woodColorRingCfg"

WoodColorRingMain.RES = {
	[ResMgr.RES_TYPE.PLIST] = {
		"images/common",
	},
	[ResMgr.RES_TYPE.SPINE_JSON] = {
	}
}

-- function WoodColorRingMain:registerEvent()
--     self:addCustomEventListener(EventMgr.EVENT.UI_WOOD_COLOR_RING_UPDATE)
-- end

-- function WoodColorRingMain:unregisterEvent()
-- end

-- function WoodColorRingMain:onEventMsg(event_name, params)
--     if event_name == EventMgr.EVENT.UI_WOOD_COLOR_RING_UPDATE then
-- 		self:updateCell(params.idx)
--     end
-- end

function WoodColorRingMain:loadRes()
	ResMgr:loadResList(WoodColorRingMain.RES)
end

function WoodColorRingMain:onClose()
	ResMgr:unloadResList(WoodColorRingMain.RES)
end

function WoodColorRingMain:ctor(uiParams)
	self.uiParams = uiParams
	self.allPos = {
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + 100),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + 100),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + 100),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - 100),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - 100),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + 100, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - 100),
	}
end

function WoodColorRingMain:init()
	self:loadRes()
	self:initData()
	self:initUI()
	self:initBG()
	self:gameControl()
end

function WoodColorRingMain:initData()
	WoodColorRingData:init()
	WoodColorRingCore:init()
end

function WoodColorRingMain:initUI()
	-- local closeBtn = UIHelper:createBackBtn({})
	-- self.root:addChild(closeBtn)
	-- closeBtn:addClickEventListener(function(sender)
	-- 	self:handleBackEvent()
	-- end)

	local boardBg = fs.Image:create("common/common_bg_2.png")
	self.root:addChild(boardBg)
	self:scaleBGMgr(boardBg)

	local params = {}
    params.str = 0
    params.size = 22
    params.color = GConst.COLOR_TYPE.C3
    -- params.outline_color = self.outline_color
	local label = LabHper:createFontTTF(params)
	label:setPosition(cc.p(GConst.win_size.width*0.5, GConst.win_size.height - 60))
	self.ui_root:addChild(label)
	self.scoreLab = label

    local params = {}
    params.str = "开始"
    params.size = 22
    params.color = GConst.COLOR_TYPE.C2
    -- params.outline_color = self.outline_color
	local label = LabHper:createFontTTF(params)
	label:setPosition(cc.p(GConst.win_size.width*0.5, GConst.win_size.height - 100))
	self.ui_root:addChild(label)
	self.errorLab = label
end

function WoodColorRingMain:initBG()
	local boardTop = fs.Image:create("common/public_item_box_2.png")
	boardTop:setScale9Enabled(true)
	boardTop:setContentSize(WoodColorRingCfg.TOP_BG_SIZE)
	boardTop:setPosition(cc.p(GConst.logical_size.width*0.5, GConst.logical_size.height*0.5 + 100))
	self.ui_root:addChild(boardTop)
	self.boardTop = boardTop

	local boardBottom = fs.Image:create("common/public_item_box_2.png")
	boardBottom:setScale9Enabled(true)
	boardBottom:setContentSize(WoodColorRingCfg.BOTTOM_BG_SIZE)
	boardBottom:setPosition(cc.p(GConst.logical_size.width*0.5, GConst.logical_size.height*0.5 - 200))
	self.ui_root:addChild(boardBottom)
	self.boardBottom = boardBottom

	for i,v in ipairs(self.allPos) do
		local widget = fs.Widget:create()
		widget:setContentSize(WoodColorRingCfg.CELL_SIZE)
		widget:setPosition(self.allPos[i])
		widget:setName("widget" .. i)
		self.boardTop:addChild(widget)
		GApi.drawBoundingbox(widget, widget)
	end

	local gameNode = cc.Node:create()
	boardTop:addChild(gameNode)
	self.gameNode = gameNode
end

function WoodColorRingMain:updateCell(idx)
	local widget = self.boardTop:getChildByName("widget" .. idx)
	local cell = widget:getChildByName("cell")
	if cell and not tolua.isnull(cell) then
		cell:removeFromParent()
	end
	local data = WoodColorRingData:getCellDataByIdx(idx)
	local cell = self:createNewCell(data)
	cell:setName("cell")
	cell:setPosition(cc.p(WoodColorRingCfg.CELL_SIZE.width*0.5, WoodColorRingCfg.CELL_SIZE.height*0.5))
	widget:addChild(cell)
end

function WoodColorRingMain:removeNewCell(newCell)
	if newCell and not tolua.isnull(newCell) then
		newCell:removeFromParent()
		newCell = nil
	end
end

function WoodColorRingMain:createNewCell(data)
	local newCell = WoodColorRingUtil:createCell(data)
	return newCell
end

function WoodColorRingMain:checkChangePos(pos)
    local newIdx
    for i,v in ipairs(self.allPos) do
        local node_pos = self.boardTop:convertToNodeSpace(pos)
        local item_pos_x, item_pos_y = v.x, v.y
        local min_x = item_pos_x - WoodColorRingCfg.CELL_SIZE.width/2
        local max_x = item_pos_x + WoodColorRingCfg.CELL_SIZE.width/2
        local min_y = item_pos_y - WoodColorRingCfg.CELL_SIZE.height/2
        local max_y = item_pos_y + WoodColorRingCfg.CELL_SIZE.height/2
        if node_pos.x >= min_x and node_pos.x <= max_x and node_pos.y >= min_y and node_pos.y <= max_y then
            newIdx = i
            break
        end
    end
	if newIdx then
		self.newIdx = newIdx
		self:gameCheck()
	else
		self.newCell:setVisible(true)
    end
end

function WoodColorRingMain:registerNewCellHandle()
	self.newCell:setTouchEnabled(true)
	self.newCell:addTouchEventListener(function(sender, state)
		if state == ccui.TouchEventType.began then
			-- AudioMgr:play(AudioMgr.AUDIO_ID.BUTTON)
			local beginPos = sender:getTouchBeganPosition()
			local moveCell = self:createNewCell(self.newCellData)
			moveCell:setPosition(beginPos)
			self.root:addChild(moveCell, GConst.Z_ORDER_TOP + 1)
			self.moveCell = moveCell
			self.newCell:setVisible(false)
		elseif state == ccui.TouchEventType.canceled then
			local end_pos = sender:getTouchEndPosition()
			self:removeNewCell(self.moveCell)
			self.moveCell = nil
			self:checkChangePos(end_pos)
		elseif state == ccui.TouchEventType.moved then
			local touch_pos = sender:getTouchMovePosition()
			if self.moveCell then
				self.moveCell:setPosition(touch_pos)
			end
		elseif state == ccui.TouchEventType.ended then
			local end_pos = sender:getTouchEndPosition()
			self:removeNewCell(self.moveCell)
			self.moveCell = nil
			self:checkChangePos(end_pos)
		end
	end)
end

function WoodColorRingMain:gameControl()
	if WoodColorRingCore:isEnd() then
		self:gameEnd()
		return
	end
	local data = WoodColorRingCore:randomOne()
	if not data then
		self:gameEnd()
		return
	end

	self:removeNewCell(self.newCell)
	self.newCellData = nil

	self.newCellData = data
	local newCell = self:createNewCell(data)
	newCell:setPosition(WoodColorRingCfg.BOTTOM_BG_SIZE.width*0.5, WoodColorRingCfg.BOTTOM_BG_SIZE.height*0.5)
	self.boardBottom:addChild(newCell)

	self.newCell = newCell
	self:registerNewCellHandle()
end

function WoodColorRingMain:gameStart()
end

function WoodColorRingMain:gameEnd()
	print("播放结束动画")
	self.errorLab:setString("game over")
	-- CustomEventManager:dispatchEvent(CustomEventManager.CUSTOM_EVENT.UI_EVENT_TEST, {num = self.num})
end

function WoodColorRingMain:gameRestart()
	self.gameNode:removeAllChildren()
	WoodColorRingData:init()

	self:gameControl()
end

function WoodColorRingMain:gameCheck()
	if WoodColorRingData:checkCellDataByIdx(self.newIdx, self.newCellData) then
		WoodColorRingData:addScore(1)
		WoodColorRingData:mergeCellDataByIdx(self.newIdx, self.newCellData)
		self:updateCell(self.newIdx)

		local check, data = WoodColorRingCore:checkEliminate(self.newIdx)
		if check then
			WoodColorRingData:updateAllCellData(data)
			for k,v in pairs(data) do
				self:updateCell(k)
			end
		end

		self.newIdx = nil
		self:gameControl()
	else
		print("有问题")
		self.errorLab:setString("有问题")
		self.newCell:setVisible(true)
	end
	local socre = WoodColorRingData:getScore()
	self.scoreLab:setString(socre)
end

return WoodColorRingMain
