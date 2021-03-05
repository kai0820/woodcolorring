local GApi = {}

function GApi.getSuperMethod(t, methodName)
	local method = t[methodName]
	if method then
		return method
	end
	local mt = t
	while not method do
		mt = getmetatable(mt)
		if mt == nil then
			break
		end
		method = mt[methodName]
		if method == nil then
			local index = mt.__index
			if index then
				if type(index) == "function" then
					method = index(mt, methodName)
				elseif type(index) == "table" then
					method = index[methodName]
				end
			end
		end
	end
	return method
end

function GApi.createSwallowTouchesNode()
	return fs.SwallowTouchesNode:create()
end

function GApi.getMilliSecond()
	return math.floor(socket.gettime() * 1000)
end

function GApi.arrayFilter(t, func)
	local len = #t
	local i = 1
	while i <= len do
		if not func(t[i]) then
			table.remove(t, i)
			len = len - 1
		else
			i = i + 1
		end
	end
end

-- 模拟按钮按下的动画， obj--按钮
function  GApi.playAnimTouchBegin(obj, callback)
	local ani_scale_factor_x = obj.scale_x or 1.0
	local ani_scale_factor_y = obj.scale_y or 1.0
	local arr = {}
	table.insert(arr, cc.ScaleTo:create(4/60, 0.8*ani_scale_factor_x, 0.8*ani_scale_factor_y))
	table.insert(arr, cc.DelayTime:create(4/60))
	if callback then
		table.insert(arr, cc.CallFunc:create(callback))
	end
	obj:runAction(cc.Sequence:create(arr))
end

-- 模拟按钮释放的动画， obj--按钮
function  GApi.playAnimTouchEnd(obj, callback, end_callback)
	local ani_scale_factor_x = obj.scale_x or 1.0
	local ani_scale_factor_y = obj.scale_y or 1.0
	local arr = {}
	if callback then
		table.insert(arr, cc.CallFunc:create(callback))
	end
	table.insert(arr, cc.ScaleTo:create(3/60, 1.1*ani_scale_factor_x, 1.1*ani_scale_factor_y))
	table.insert(arr, cc.DelayTime:create(3/60))
	table.insert(arr, cc.ScaleTo:create(2/60, 0.9*ani_scale_factor_x, 0.9*ani_scale_factor_y))
	table.insert(arr, cc.DelayTime:create(2/60))
	table.insert(arr, cc.ScaleTo:create(3/60, 1.0*ani_scale_factor_x, 1.0*ani_scale_factor_y))
	table.insert(arr, cc.DelayTime:create(3/60))
	if end_callback then
		table.insert(arr, cc.CallFunc:create(end_callback))
	end
	obj:runAction(cc.Sequence:create(arr))
end

function GApi.doExit()
	-- if GApi.isMainChannel() then
		cc.Director:getInstance():endToLua()
	--     return
	-- end
	-- local cfg = require"app.common.sdkcfg"
	-- if cfg[GConst.APP_CHANNEL] and cfg[GConst.APP_CHANNEL].exit then
	--    cfg[GConst.APP_CHANNEL].exit("", function()
	--        Director:endToLua()
	--    end)
	-- else
	--    Director:endToLua()
	-- end
end

function GApi.exitGame()
	-- local I18n = require "app.tools.i18n"
	-- local function process_dialog(data)
	--     if data.selected_btn == 2 then
		GApi.doExit()
	--     elseif data.selected_btn == 1 then
	--     end
	-- end
	-- local params = {
	--     title = "",
	--     body = I18n.global.exit_game_tips.string,
	--     btn_count = 2,
	--     btn_color = {
	--         [1] = GConst.BTN_TYPE.GREEN,
	--         [2] = GConst.BTN_TYPE.GOLD,
	--     },
	--     btn_text = {
	--         [1] = I18n.global.dialog_button_cancel.string,
	--         [2] = I18n.global.dialog_button_confirm.string,
	--     },
	--     selected_btn = 0,
	--     callback = process_dialog,
	-- }
	-- GFunc.showDialog(params)
end

function GApi.drawBoundingbox(container, n, borderColor)
	if DEBUG < 1 then
		return
	end
	borderColor = borderColor or cc.c4f(0, 1, 0, 0.5)
	local dn = CCDrawNode:create()
	local fillColor = cc.c4f(0, 0, 0, 0)
	local rect1 = n:getBoundingBox()
	local x0 = cc.rectGetMinX(rect1)
	local x1 = cc.rectGetMaxX(rect1)
	local y0 = cc.rectGetMinY(rect1)
	local y1 = cc.rectGetMaxY(rect1)
	local verts = {
		container:convertToNodeSpace(n:getParent():convertToWorldSpace(cc.p(x0,y0))),
		container:convertToNodeSpace(n:getParent():convertToWorldSpace(cc.p(x1,y0))),
		container:convertToNodeSpace(n:getParent():convertToWorldSpace(cc.p(x1,y1))),
		container:convertToNodeSpace(n:getParent():convertToWorldSpace(cc.p(x0,y1))),
	}
	local points = {
		cc.p(verts[1].x, verts[1].y),
		cc.p(verts[2].x, verts[2].y),
		cc.p(verts[3].x, verts[3].y),
		cc.p(verts[4].x, verts[4].y)
	}
	dn:drawPolygon(points, #points, fillColor, 2, borderColor)
	container:addChild(dn, GConst.Z_ORDER_TOP)
end

function GApi.showToast(text)
    local Toast = require "app.ui.uiHelper.toast"
    Toast:showToast(text)
end

function GApi.schedule(node, param1, param2)
    if type(param1) == "function" then
        if not node or tolua.isnull(node) then return end
        node:runAction(cc.CallFunc:create(param1))
    elseif node ~= nil then
        if not node or tolua.isnull(node) then return end
        node:runAction(cc.Sequence:create(
            cc.DelayTime:create(param1),
            cc.CallFunc:create(param2)
        ))
    elseif node == nil then
        local scene = Director:getRunningScene()
        scene:runAction(cc.Sequence:create(
            cc.DelayTime:create(param1),
            cc.CallFunc:create(param2)
        ))
    end
end

function GApi.getAngleByPos(p1, p2)
	local p = cc.pSub(p2, p1)
	local angle = math.radian2angle(math.atan2(p.x, p.y))
	return angle - 90
end

return GApi