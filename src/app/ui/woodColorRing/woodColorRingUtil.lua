local WoodColorRingUtil = {}
local WoodColorRingCore = require "app.ui.test.woodColorRing.woodColorRingCore"

function WoodColorRingUtil:createCell(data)
	local size = cc.size(100, 100)
	local widget = fs.Widget:create()
	widget:setContentSize(size)

	local bigNum = math.floor(data/100)
	local midNum = math.floor((data%100)/10)
	local smallNum = data%10
	if bigNum > 0 then
		local cellImage = self:createCellColor(bigNum)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end
	if midNum > 0 then
		local cellImage = self:createCellColor(midNum)
		cellImage:setScale(0.7)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end
	if smallNum > 0 then
		local cellImage = self:createCellColor(smallNum)
		cellImage:setScale(0.4)
		cellImage:setPosition(cc.p(size.width*0.5, size.height*0.5))
		widget:addChild(cellImage)
	end

	return widget
end

function WoodColorRingUtil:createCellColor(color)
	local cellImage
	if color == WoodColorRingCore.COLOR.COLOR1 then
		cellImage = fs.Image:create("common/public_item_box_1_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR2 then
		cellImage = fs.Image:create("common/public_item_box_2_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR3 then
		cellImage = fs.Image:create("common/public_item_box_3_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR4 then
		cellImage = fs.Image:create("common/public_item_box_4_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR5 then
		cellImage = fs.Image:create("common/public_item_box_5_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR6 then
		cellImage = fs.Image:create("common/public_item_box_6_1.png")
	elseif color == WoodColorRingCore.COLOR.COLOR6 then
		cellImage = fs.Image:create("common/public_item_box_7_1.png")
	else
		cellImage = fs.Image:create("common/public_item_box_1_1.png")
	end
	return cellImage
end

return WoodColorRingUtil