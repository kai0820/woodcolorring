local WoodColorRingData = {}

local WoodColorRingCfg = require "app.ui.test.woodColorRing.woodColorRingCfg"

function WoodColorRingData:init()
	self._socre = 0
	self._cellData = {
		0,0,0,0,0,0,0,0,0
	}
end

function WoodColorRingData:getScore()
	return self._socre
end

function WoodColorRingData:addScore(score)
	self._socre = self._socre + score
end

function WoodColorRingData:getCellData()
	return self._cellData
end

function WoodColorRingData:setCellData(cellsData)
	self._cellData = cellsData
end

function WoodColorRingData:getCellDataByIdx(idx)
	return self._cellData[idx]
end

function WoodColorRingData:getCellInfoByIdx(idx)
	local bigNum = math.floor(self._cellData[idx]/100)
	local midNum = math.floor((self._cellData[idx]%100)/10)
	local smallNum = self._cellData[idx]%10
	return bigNum, midNum, smallNum
end

function WoodColorRingData:setCellDataByIdx(idx, data)
	self._cellData[idx] = data
end

function WoodColorRingData:mergeCellDataByIdx(idx, data)
	self._cellData[idx] = self._cellData[idx] + data
end

function WoodColorRingData:checkCellDataByIdx(idx, data)
	local bigNum = math.floor(self._cellData[idx]/100)
	local midNum = math.floor((self._cellData[idx]%100)/10)
	local smallNum = self._cellData[idx]%10

	local bigNum1 = math.floor(data/100)
	local midNum1 = math.floor((data%100)/10)
	local smallNum1 = data%10
	if (bigNum > 0 and bigNum1 > 0) or
		(midNum > 0 and midNum1 > 0) or
		(smallNum > 0 and smallNum1 > 0) then
		return false
	end
	return true 
end

function WoodColorRingData:updateAllCellData(data)
	for k,v in pairs(data) do
		local bigNum, midNum, smallNum = self:getCellInfoByIdx(k)
		bigNum = v[1] == 1 and 0 or bigNum
		midNum = v[2] == 1 and 0 or midNum
		smallNum = v[3] == 1 and 0 or smallNum

		local newData = bigNum*10000 + midNum*100 + smallNum
		self:setCellDataByIdx(k, newData)
	end
end

function WoodColorRingData:isSmallOpen()
	if self._socre >= WoodColorRingCfg.SMALL_SCORE then
		return true
	end
	return false
end

function WoodColorRingData:isComposeOpen()
	if self._socre >= WoodColorRingCfg.COMPOSE_SCORE then
		return true
	end
	return false
end

function WoodColorRingData:getMaxColorNum()
	for i,v in ipairs(WoodColorRingCfg.MAX_COLOR_NUM) do
		if self._socre >= v[1] then
			return v[2]
		end
	end
end

return WoodColorRingData
