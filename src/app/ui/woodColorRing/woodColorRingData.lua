local WoodColorRingData = {}

local WoodColorRingCfg = require "app.ui.woodColorRing.woodColorRingCfg"
local WoodColorRingUtil = require "app.ui.woodColorRing.woodColorRingUtil"

function WoodColorRingData:init()
	self._socre = 0
	self._bestScore = 100
	self._refreshNum = 5
	self._doubleHitNum = 0
	self._cellData = {
		0,0,0,0,0,0,0,0,0
	}
end

function WoodColorRingData:getBestScore()
	return self._bestScore
end

function WoodColorRingData:getScore()
	return self._socre
end

function WoodColorRingData:addScore(score)
	self._socre = self._socre + score
	if self._socre > self._bestScore then
		self._bestScore = self._socre
	end
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
	local bigNum, midNum, smallNum = WoodColorRingUtil:getDataInfo(self._cellData[idx])
	return bigNum, midNum, smallNum
end

function WoodColorRingData:setCellDataByIdx(idx, data)
	self._cellData[idx] = data
end

function WoodColorRingData:mergeCellDataByIdx(idx, data)
	self._cellData[idx] = self._cellData[idx] + data
end

function WoodColorRingData:checkCellDataByIdx(idx, data)
	local bigNum, midNum, smallNum = self:getCellInfoByIdx(idx)
	local bigNum1, midNum1, smallNum1 = WoodColorRingUtil:getDataInfo(data)

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

		local newData = WoodColorRingUtil:composeData(bigNum, midNum, smallNum)
		self:setCellDataByIdx(k, newData)
	end
end

function WoodColorRingData:updateAllScore(data)
	local num = 0
	for k,v in pairs(data) do
		for ii, vv in ipairs(v) do
			num = num + vv
		end
	end
	local score = num*10
	self:addScore(score)
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
	-- return 1
end

return WoodColorRingData
