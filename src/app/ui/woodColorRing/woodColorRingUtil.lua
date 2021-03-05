local WoodColorRingUtil = {}

local WoodColorRingCfg = require "app.ui.woodColorRing.woodColorRingCfg"

function WoodColorRingUtil:getDataInfo(data)
	local bigNum = math.floor(data/10000)
	local midNum = math.floor((data%10000)/100)
	local smallNum = data%100
	return bigNum, midNum, smallNum
end

function WoodColorRingUtil:composeData(bigNum, midNum, smallNum)
	local newData = bigNum*10000 + midNum*100 + smallNum
	return newData
end

function WoodColorRingUtil:createCell(data)
	local size = WoodColorRingCfg.CELL_SIZE
	local widget = fs.Widget:create()
	widget:setContentSize(size)

	local bigNum, midNum, smallNum = self:getDataInfo(data)
	if bigNum > 0 then
		local cellImage = self:createCellColor(bigNum, 2)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end
	if midNum > 0 then
		local cellImage = self:createCellColor(midNum, 1)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end
	if smallNum > 0 then
		local cellImage = self:createCellColor(smallNum, 0)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end

	return widget
end

function WoodColorRingUtil:createCellColor(color, ntype)
	local url = "common/color_" .. color .. "_" .. ntype .. ".png"
	local cellImage = fs.Image:create(url)
	-- if color == WoodColorRingCore.COLOR.COLOR1 then
	-- 	cellImage = fs.Image:create("common/public_item_box_1_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR2 then
	-- 	cellImage = fs.Image:create("common/public_item_box_2_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR3 then
	-- 	cellImage = fs.Image:create("common/public_item_box_3_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR4 then
	-- 	cellImage = fs.Image:create("common/public_item_box_4_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR5 then
	-- 	cellImage = fs.Image:create("common/public_item_box_5_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR6 then
	-- 	cellImage = fs.Image:create("common/public_item_box_6_1.png")
	-- elseif color == WoodColorRingCore.COLOR.COLOR6 then
	-- 	cellImage = fs.Image:create("common/public_item_box_7_1.png")
	-- else
	-- 	cellImage = fs.Image:create("common/public_item_box_1_1.png")
	-- end
	return cellImage
end

return WoodColorRingUtil