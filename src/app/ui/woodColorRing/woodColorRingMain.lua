local WoodColorRingMain = class("WoodColorRingMain", BaseUI)

local WoodColorRingCore = require "app.ui.woodColorRing.woodColorRingCore"
local WoodColorRingData = require "app.ui.woodColorRing.woodColorRingData"
local WoodColorRingUtil = require "app.ui.woodColorRing.woodColorRingUtil"
local WoodColorRingCfg = require "app.ui.woodColorRing.woodColorRingCfg"

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
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + WoodColorRingCfg.CELL_SIZE.height),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + WoodColorRingCfg.CELL_SIZE.height),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 + WoodColorRingCfg.CELL_SIZE.height),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - WoodColorRingCfg.CELL_SIZE.height),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - WoodColorRingCfg.CELL_SIZE.height),
		cc.p(WoodColorRingCfg.TOP_BG_SIZE.width*0.5 + WoodColorRingCfg.CELL_SIZE.width, WoodColorRingCfg.TOP_BG_SIZE.height*0.5 - WoodColorRingCfg.CELL_SIZE.height),
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
	boardBg:setPosition(GConst.win_size.width*0.5, GConst.win_size.height*0.5)
	self.root:addChild(boardBg)
	self:scaleBGMgr(boardBg)

	local params = {}
    params.str = "积分：" .. 0
    params.size = 50
    params.color = GConst.COLOR_TYPE.C3
    -- params.outline_color = self.outline_color
	local label = LabHper:createFontTTF(params)
	label:setAnchorPoint(cc.p(0, 0.5))
	local width = GConst.logical_size.width*0.5 - WoodColorRingCfg.TOP_BG_SIZE.width*0.5
	local height = GConst.logical_size.height*0.5 + 250 + WoodColorRingCfg.TOP_BG_SIZE.height*0.5
	label:setPosition(cc.p(width, height))
	self.ui_root:addChild(label)
	self.scoreLab = label

	local params = {}
	params.nor = "common/public_btn_refresh.png"
	local refreshBtn = fs.Button:create(params)
	refreshBtn:addClickEventListener(function(sender)
		self:gameControl()
	end)
	refreshBtn:setAnchorPoint(cc.p(1, 0.5))
	local width = GConst.logical_size.width*0.5 + WoodColorRingCfg.TOP_BG_SIZE.width*0.5
	refreshBtn:setPosition(width, height)
	self.ui_root:addChild(refreshBtn)

	local params = {}
	params.nor = "common/public_btn_refresh.png"
	local restartBtn = fs.Button:create(params)
	restartBtn:addClickEventListener(function(sender)
		GApi.showToast("重新开始")
		self:gameRestart()
	end)
	restartBtn:setColor(cc.c3b(255, 0, 0))
	restartBtn:setAnchorPoint(cc.p(1, 0.5))
	local width = GConst.logical_size.width*0.5 + WoodColorRingCfg.TOP_BG_SIZE.width*0.5 - 66
	restartBtn:setPosition(width, height)
	self.ui_root:addChild(restartBtn)
end

function WoodColorRingMain:initBG()
	local boardTop = fs.Image:create("common/public_item_box_2.png")
	boardTop:setScale9Enabled(true)
	boardTop:setContentSize(WoodColorRingCfg.TOP_BG_SIZE)
	boardTop:setPosition(cc.p(GConst.logical_size.width*0.5, GConst.logical_size.height*0.5 + 150))
	self.ui_root:addChild(boardTop)
	self.boardTop = boardTop

	local boardBottom = fs.Image:create("common/public_item_box_2.png")
	boardBottom:setScale9Enabled(true)
	boardBottom:setContentSize(WoodColorRingCfg.BOTTOM_BG_SIZE)
	boardBottom:setPosition(cc.p(GConst.logical_size.width*0.5, GConst.logical_size.height*0.5 - 250))
	self.ui_root:addChild(boardBottom)
	self.boardBottom = boardBottom

	for i,v in ipairs(self.allPos) do
		local widget = fs.Widget:create()
		widget:setContentSize(WoodColorRingCfg.CELL_SIZE)
		widget:setPosition(self.allPos[i])
		widget:setName("widget" .. i)
		self.boardTop:addChild(widget)
		GApi.drawBoundingbox(widget, widget, cc.c4f(0, 0, 0, 1))
	end

	local gameNode = cc.Node:create()
	boardTop:addChild(gameNode)
	self.gameNode = gameNode
end

function WoodColorRingMain:updateCell(idx)
	local cell = self.gameNode:getChildByName("cell" .. idx)
	if cell and not tolua.isnull(cell) then
		cell:removeFromParent()
	end
	local data = WoodColorRingData:getCellDataByIdx(idx)
	local cell = self:createNewCell(data)
	cell:setName("cell" .. idx)
	cell:setPosition(self.allPos[idx])
	self.gameNode:addChild(cell)
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
        local node_pos = self.gameNode:convertToNodeSpace(pos)
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
	GApi.showToast("game over")
	-- CustomEventManager:dispatchEvent(CustomEventManager.CUSTOM_EVENT.UI_EVENT_TEST, {num = self.num})
end

function WoodColorRingMain:gameRestart()
	self.gameNode:removeAllChildren()
	self:initData()

	self.newIdx = nil
	self.newCellData = nil
	self:updateScore()
	self:gameControl()
end

function WoodColorRingMain:gameCheck()
	if WoodColorRingData:checkCellDataByIdx(self.newIdx, self.newCellData) then
		-- WoodColorRingData:addScore(1)
		WoodColorRingData:mergeCellDataByIdx(self.newIdx, self.newCellData)
		self:updateCell(self.newIdx)

		local check, eliminatePos, eliminateLine = WoodColorRingCore:checkEliminate(self.newIdx)
		if check then
			-- GApi.showToast("播放动画")
			self:playAction(eliminateLine)
			GApi.schedule(self.ui_root, 0.5, function ()
				self:getPoints(eliminatePos)
			end)
		end

		self.newIdx = nil
		self:gameControl()
	else
		self.newCell:setVisible(true)
	end

	self:updateScore()
end

function WoodColorRingMain:playAction(eliminateLine)
	for i,v in ipairs(eliminateLine) do
		local cellId = 0
		for ii,vv in ipairs(v) do
			cellId = cellId + vv
		end
		local cellId = cellId/3
		local lineImg = fs.Image:create("common/progress_line.png")
		lineImg:setScale9Enabled(true)
		lineImg:setContentSize(cc.size(WoodColorRingCfg.TOP_BG_SIZE.width, 22))
		lineImg:setPosition(self.allPos[cellId])
		self.gameNode:addChild(lineImg)

		lineImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.RemoveSelf:create()))

		local angle = WoodColorRingUtil:getRotation(self.allPos[v[1]], self.allPos[v[3]])
		lineImg:setPosition(self.allPos[v[2]])
		lineImg:setRotation(angle)
	end
end

function WoodColorRingMain:getPoints(data)
	-- 更新每个格子的数据
	WoodColorRingData:updateAllCellData(data)
	-- 更新这次消除的积分
	WoodColorRingData:updateAllScore(data)
	-- 更新格子
	for k,v in pairs(data) do
		self:updateCell(k)
	end

	self:updateScore()
end

function WoodColorRingMain:updateScore()
	local socre = WoodColorRingData:getScore()
	self.scoreLab:setString("积分：" .. socre)
end

return WoodColorRingMain
