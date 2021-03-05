local WoodColorRingCore = {}

local WoodColorRingData = require "app.ui.woodColorRing.woodColorRingData"
local WoodColorRingUtil = require "app.ui.woodColorRing.woodColorRingUtil"

WoodColorRingCore.COLOR = {
	COLOR1 = 1,
	COLOR2 = 2,
	COLOR3 = 3,
	COLOR4 = 4,
	COLOR5 = 5,
	COLOR6 = 6,
	COLOR7 = 7,
}
WoodColorRingCore.MAX_COLOR = 7

WoodColorRingCore.COMPOSE = {
	BIG = 1,
	MID = 2,
	SMALL = 3,
	BIG_AND_MID = 4,
	BIG_AND_SMALL = 5,
	MID_AND_SMALL = 6,
}

WoodColorRingCore.CHECK_RANGE = {
	[1] = {
		{1, 2, 3},
		{1, 4, 7},
		{1, 5, 9},
	},
	[2] = {
		{1, 2, 3},
		{2, 5, 8},
	},
	[3] = {
		{1, 2, 3},
		{3, 6, 9},
		{3, 5, 7},
	},
	[4] = {
		{1, 4, 7},
		{4, 5, 6},
	},
	[5] = {
		{4, 5, 6},
		{2, 5, 8},
		{1, 5, 9},
		{3, 5, 7},
	},
	[6] = {
		{4, 5, 6},
		{3, 6, 9},
	},
	[7] = {
		{1, 4, 7},
		{7, 8, 9},
		{3, 5, 7},
	},
	[8] = {
		{2, 5, 8},
		{7, 8, 9},
	},
	[9] = {
		{7, 8, 9},
		{1, 5, 9},
		{3, 6, 9},
	},
}
function WoodColorRingCore:init()
	
end

function WoodColorRingCore:randomOne()
	local cellData = WoodColorRingData:getCellData()
	local bigCellNum, midCellNum, smallCellNum = 0, 0, 0
	local randomNum = {}
	for i,v in ipairs(cellData) do
		local bigNum, midNum, smallNum = WoodColorRingUtil:getDataInfo(v)
		if bigNum <= 0 then
			table.insert(randomNum, WoodColorRingCore.COMPOSE.BIG)
		end
		if midNum <= 0 then
			table.insert(randomNum, WoodColorRingCore.COMPOSE.MID)
		end
		if WoodColorRingData:isComposeOpen() then
			if bigNum <= 0 and midNum <= 0 then
				table.insert(randomNum, WoodColorRingCore.COMPOSE.BIG_AND_MID)
			end
		end
		if WoodColorRingData:isSmallOpen() then
			if smallNum <= 0 then
				table.insert(randomNum, WoodColorRingCore.COMPOSE.SMALL)
			end
			if WoodColorRingData:isComposeOpen() then
				if bigNum <= 0 and smallNum <= 0 then
					table.insert(randomNum, WoodColorRingCore.COMPOSE.BIG_AND_SMALL)
				end
				if midNum <= 0 and smallNum <= 0 then
					table.insert(randomNum, WoodColorRingCore.COMPOSE.MID_AND_SMALL)
				end
			end
		end
	end
	if #randomNum > 0 then
		local one = randomNum[math.random(1, #randomNum)]
		local color = self:randomOneColor()
		local color1 = self:randomOneColor()
		local data = 0
		if one == WoodColorRingCore.COMPOSE.BIG then
			data = color*10000
		elseif one == WoodColorRingCore.COMPOSE.MID then
			data = color*100
		elseif one == WoodColorRingCore.COMPOSE.SMALL then
			data = color
		elseif one == WoodColorRingCore.COMPOSE.BIG_AND_MID then
			data = color*10000 + color1*100
		elseif one == WoodColorRingCore.COMPOSE.BIG_AND_SMALL then
			data = color*10000 + color1
		elseif one == WoodColorRingCore.COMPOSE.MID_AND_SMALL then
			data = color*100 + color1
		end
		return data
	end
	return
end

function WoodColorRingCore:randomOneColor()
	local maxColorNum = WoodColorRingData:getMaxColorNum()
	return math.random(1, maxColorNum)
end

function WoodColorRingCore:isEnd()
	local one = self:randomOne()
	if not one then
		return true
	end
	return false
end

function WoodColorRingCore:checkEliminate(idx)
	local checkRange = WoodColorRingCore.CHECK_RANGE[idx]
	local bigNum, midNum, smallNum = WoodColorRingData:getCellInfoByIdx(idx)
	local eliminatePos = {}
	local isEliminate = false
	if bigNum ~= 0 and bigNum == midNum and bigNum == smallNum then
		eliminatePos[idx] = {1, 1, 1}
		isEliminate = true
	end
	local checkPos = self.CHECK_RANGE[idx]
	for i,v in ipairs(checkPos) do
		local data = {}
		local inNum = {}
		for ii,vv in ipairs(v) do
			data[ii] = {}
			local bigNum1, midNum1, smallNum1 = WoodColorRingData:getCellInfoByIdx(vv)
			inNum[bigNum1] = (inNum[bigNum1] or 0) + 1
			if bigNum1 ~= midNum1 then
				inNum[midNum1] = (inNum[midNum1] or 0) + 1
			end
			if bigNum1 ~= smallNum1 and midNum1 ~= smallNum1 then
				inNum[smallNum1] = (inNum[smallNum1] or 0) + 1
			end
		end

		local eliminateNum = {}
		local needEliminate = false
		for i = 1, WoodColorRingCore.MAX_COLOR do
			if inNum[i] and inNum[i] >= 3 then
				eliminateNum[i] = true
				needEliminate = true
			end
		end

		if needEliminate then
			isEliminate = true
			for ii,vv in ipairs(v) do
				eliminatePos[vv] = {0, 0, 0}
				local bigNum, midNum, smallNum = WoodColorRingData:getCellInfoByIdx(vv)
				if eliminateNum[bigNum] then
					eliminatePos[vv][1] = 1
				end
				if eliminateNum[midNum] then
					eliminatePos[vv][2] = 1
				end
				if eliminateNum[smallNum] then
					eliminatePos[vv][3] = 1
				end
			end
		end
	end
	return isEliminate, eliminatePos
end

return WoodColorRingCore