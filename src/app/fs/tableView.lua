local UITableView = class("UITableView", function(size)
    local scrollView =  ccui.ScrollView:create()
    scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    if size then
        scrollView:setContentSize(size)
    end
    return scrollView
end)

UITableView._onEvent = GApi.getSuperMethod(ccui.ScrollView, "onEvent")
UITableView._setDirection = GApi.getSuperMethod(ccui.ScrollView, "setDirection")

UITableView.DIRECTION = {
    NONE = 0,
    VERTICAL = 1,
    HORIZONTAL = 2,
    BOTH = 3
}

UITableView.ALIGN_DIRECTION = {
    TOP_TO_BOTTOM = 0,
    BOTTOM_TO_TOP = 1,
}

function UITableView:ctor()
    self:init()
end

function UITableView:init()
    -- 子控件大小
    self.cell_width = 60
    self.cell_height = 60
    -- 开始结束间距
    self.start_space = 0
    self.finish_space = 0
    -- 总数据量
    self.max_cell_num = 0
    -- 总行数
    self.max_line = 0
    -- 单行（列）的个数
    self.line_cell_num = 1

    -- 初始化标志
    self.inited = false

    -- 是否跳转
    self.turn_flag = false

    self.min_idx = 0
    self.max_idx = 0

    self.direction = cc.SCROLLVIEW_DIRECTION_VERTICAL
    self.align_direction = self.ALIGN_DIRECTION.TOP_TO_BOTTOM

    self.container = ccui.Widget:create()
    self:addChild(self.container)
    self:onEvent()
end

-- 滑动方向 水平、垂直
function UITableView:setScrollDirection(direction)
    self.direction = direction
    self:_setDirection(direction)
end

-- 排序，上到下，下到上
function UITableView:setAlignDirection(direction)
    self.align_direction = direction
end

-- 起始留白（上、左）
function UITableView:setStartSpace(start_space)
    self.start_space = start_space
end

-- 结束留白（下、右）
function UITableView:setFinishSpace(finish_space)
    self.finish_space = finish_space
end

-- 设置每行的个数
function UITableView:setLineCellNum(line_cell_num)
    self.line_cell_num = line_cell_num
end

-- 设置总数
function UITableView:setMaxCellNum(max_cell_num)
    self.max_cell_num = max_cell_num
end

-- 获取当前显示的最小序号
function UITableView:getMinIdx()
    return self.min_idx
end

-- 获取当前显示的最大序号
function UITableView:getMaxIdx()
    return self.max_idx
end

-- 跳转到最小序号
function UITableView:turnToMinIdx(min_idx)
    if not min_idx then
        return
    end
    self.turn_flag = true
    self:_setMinIdx(min_idx)
    self:reloadData()
end

-- 获取当前显示的最大序号
function UITableView:turnToMaxIdx(max_idx)
    if not max_idx then
        return
    end
    self.turn_flag = true
    self:_setMaxIdx(max_idx)
    self:reloadData()
end

-- min_idx按照最小显示id计算
-- single_time 单个cell滑动的时间，用于计算总时间
-- attenuated 是否衰减
function UITableView:scrollToMinCellIdx(cell_idx, single_time, attenuated)
    if not cell_idx then
        return
    end
    local min_idx = math.ceil(cell_idx/self.line_cell_num)
    self:_scrollToMinIdx(min_idx, single_time, attenuated)
end

-- min_idx按照最小显示id计算
-- single_time 单个cell滑动的时间，用于计算总时间
-- attenuated 是否衰减
function UITableView:scrollToMinIdx(min_idx, single_time, attenuated)
    if not min_idx then
        return
    end
    self:_scrollToMinIdx(min_idx, single_time, attenuated)
end

function UITableView:_scrollToMinIdx(min_idx, single_time, attenuated)
    single_time = single_time or 0.01
    local pos = self:getInnerContainerPosition()
    local inner_size = self:getInnerContainerSize()
    local size = self:getContentSize()
    local n_min_idx = self:getMinIdx()
    local all_time = math.abs(n_min_idx - min_idx)*single_time
    local pos_x, pos_y = self:_calculatePositionByMinIdx(min_idx)
    if not pos_x or not pos_y then
        return
    end
    
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        local max_height = inner_size.height - size.height
        local per = 100 - math.abs(pos_y)/max_height*100
        self:scrollToPercentVertical(per, all_time, attenuated)
    else
        local max_width = inner_size.width - size.width
        local per = math.abs(pos_x)/max_width*100
        self:scrollToPercentHorizontal(per, all_time, attenuated)
    end
end

-- cell_idx 子控件id
-- single_time 单个cell滑动的时间，用于计算总时间
-- attenuated 是否衰减
function UITableView:scrollToMaxCellIdx(cell_idx, single_time, attenuated)
    if not cell_idx then
        return
    end
    local max_idx = math.ceil(cell_idx/self.line_cell_num)
    self:_scrollToMaxIdx(max_idx, single_time, attenuated)
end

-- max_idx按照最大显示id计算
-- single_time 单个cell滑动的时间，用于计算总时间
-- attenuated 是否衰减
function UITableView:scrollToMaxIdx(max_idx, single_time, attenuated)
    if not max_idx then
        return
    end
    self:_scrollToMaxIdx(max_idx, single_time, attenuated)
end

function UITableView:_scrollToMaxIdx(max_idx, single_time, attenuated)
    single_time = single_time or 0.01
    local pos = self:getInnerContainerPosition()
    local inner_size = self:getInnerContainerSize()
    local size = self:getContentSize()
    local n_max_idx = self:getMaxIdx()
    local all_time = math.abs(n_max_idx - max_idx)*single_time
    local pos_x, pos_y = self:_calculatePositionByMaxIdx(max_idx)
    if not pos_x or not pos_y then
        return
    end
    
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        pos_y = math.min(pos_y, 0)
        local max_height = inner_size.height - size.height
        local per = 100 - math.abs(pos_y)/max_height*100
        self:scrollToPercentVertical(per, all_time, attenuated)
    else
        pos_x = math.min(pos_x, 0)
        local max_width = inner_size.width - size.width
        local per = math.abs(pos_x)/max_width*100
        self:scrollToPercentHorizontal(per, all_time, attenuated)
    end
end

-- 设置数据刷新时最小子控件序号
-- 调用reloadData之前设置
function UITableView:_setMinIdx(min_idx)
    self.min_idx = math.max(min_idx, 0)
    self.max_idx = 0
end

-- 设置数据刷新时最大子控件序号
-- 调用reloadData之前设置
function UITableView:_setMaxIdx(max_idx)
    self.max_idx = math.min(max_idx, self.max_cell_num + 1)
    self.min_idx = 0
end

-- 显示debug区域
function UITableView:enableCellBox()
    self.enable_cell_box = true
end

-- 单项的大小（所有的项相同）
-- 只需要在初始化的时候设置一次
function UITableView:setCellSize(...)
    local args = {...}
    if #args == 1 then
        self.cell_width, self.cell_height = args[1].width, args[1].height
    else
        self.cell_width, self.cell_height = args[1], args[2]
    end
end

-- 设置填充数据的回调方法，会传入(index)
-- 回调返回的 Node 不能吞没事件，设置 setSwallowTouches(false)
function UITableView:setCreateCellCallback(cell_create_callback)
    self.cell_create_callback = cell_create_callback
end

-- 设置获取cell size的回调
function UITableView:setCellSizeCallback(callback)
    self.cell_size_callback = callback
end

-- 按照idx获取控件
function UITableView:getCellByIndex(idx)
    if not idx then
        return
    end
    local cell_idx = math.ceil(idx/self.line_cell_num)
    local icon_idx = (idx - 1)%self.line_cell_num + 1
    local cell = self.container:getChildByTag(cell_idx)
    if not cell then
        return
    end
    local inner_cell = cell:getChildByName("inner_cell_" .. icon_idx)
    return inner_cell
end

-- 按照idx更新控件
function UITableView:upadteCellByIndex(idx)
    local item_cell = self:getCellByIndex(idx)
    if not item_cell then
        return
    end
    local pos_x, pos_y = item_cell:getPosition()
    local anchor = item_cell:getAnchorPoint()
    local parent = item_cell:getParent()
    local name = item_cell:getName()
    item_cell:removeFromParent()
    local item_cell = self.cell_create_callback(self, idx)
    if item_cell then
        item_cell:setName(name)
        parent:addChild(item_cell)
        item_cell:setPosition(pos_x, pos_y)
        item_cell:setAnchorPoint(anchor)
    end
end

function UITableView:onEvent(event_callback)
    self:_onEvent(function(event)
        if event_callback then
            event_callback(event)
        end
        if event.name == "CONTAINER_MOVED" then
            if self.inited then
                local min_idx, max_idx = self:_calculateIndex()
                if self.min_idx ~= min_idx or self.max_idx ~= max_idx then
                    self.min_idx, self.max_idx = min_idx, max_idx
                    self:_checkItem(min_idx, max_idx)
                end
            end
        end
    end)
end

-- 刷新当前显示区域cell
function UITableView:reloadData()
    -- print("max_cell_num = ", self.max_cell_num)
    -- print("cell_width = ", self.cell_width)
    -- print("cell_height = ", self.cell_height)
    self.inited = false
    self.container:removeAllChildren()
    self._offset = {}
    self._offset[0] = self.start_space
    local max_width, max_height = 0, 0
    local size = self:getContentSize()
    self.max_line = math.ceil(self.max_cell_num/self.line_cell_num)

    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        max_height = self.start_space
        max_width = size.width
    else
        max_width = self.start_space
        max_height = size.height
    end

    for i = 1, self.max_line do
        local width, height = self:_cellSizeForTable(i)
        if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
            max_height = max_height + height
            self._offset[i] = max_height
        else
            max_width = max_width + width
            self._offset[i] = max_width
        end
    end
    
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        max_height = max_height + self.finish_space
        max_height = math.max(max_height, size.height)
    else
        max_width = max_width + self.finish_space
        max_width = math.max(max_width, size.width)
    end

    print("UITableView  ", max_width, max_height)
    local inner_size = self:getInnerContainerSize()
    if inner_size.width ~= max_width or inner_size.height ~= max_height then
        self:setInnerContainerSize(cc.size(max_width, max_height))
    end
    for i = 1, self.max_line do
        self:_resetCell(i)
    end

    if self.turn_flag and self.min_idx and self.min_idx ~= 0 then
        self:_calculatePositionByMinIdx(self.min_idx, true)
    elseif self.turn_flag and self.max_idx and self.max_idx ~= 0 then
        self:_calculatePositionByMaxIdx(self.max_idx, true)
    else
        self:resetPosition()
    end
    self.turn_flag = false

    self.inited = true
    self.min_idx, self.max_idx = self:_calculateIndex()
    self:_checkItem(self.min_idx, self.max_idx)
end

function UITableView:resetPosition()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            self:jumpToBottom()
        else
            self:jumpToTop()
        end
    else
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            self:jumpToRight()
        else
            self:jumpToLeft()
        end
    end
end

function UITableView:resetPositionReverse()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            self:jumpToTop()
        else
            self:jumpToBottom()
        end
    else
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            self:jumpToLeft()
        else
            self:jumpToRight()
        end
    end
end

function UITableView:_cellSizeForTable(idx)
    local cell = self.container:getChildByTag(idx)
    if self.cell_size_callback then
        return self.cell_size_callback(cell, idx)
    end

    local size = self:getContentSize()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        return size.width, self.cell_height
    else
        return self.cell_width, size.height
    end
end

function UITableView:_checkItem(min_idx, max_idx)
    -- -- print("min_idx, max_idx ", min_idx, max_idx)
    for idx = 1, self.max_line do
        local cell = self.container:getChildByTag(idx)
        if idx < min_idx or idx > max_idx then
            if cell and cell._is_create then
                self:_removeItem(idx)
            end
        else
            if not cell or not cell._is_create then
                self:_addItem(idx)
            end
        end
    end
end

function UITableView:_calculateIndex()
    local pos = self:getInnerContainerPosition()
    local inner_size = self:getInnerContainerSize()
    local size = self:getContentSize()

    local min_idx, max_idx = #self._offset, 0
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        local max_y, min_y
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            max_y = size.height - pos.y
            min_y = - pos.y
        else
            max_y = inner_size.height + pos.y
            min_y = inner_size.height + pos.y - size.height
        end
        for i = 1, #self._offset do
            if min_y < self._offset[i] then
                min_idx = i
                break
            end
        end
        for i = min_idx, #self._offset do
            max_idx = i
            if max_y <= self._offset[i] then
                break
            end
        end
    else
        local max_x, min_x
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            max_x = inner_size.width + pos.x
            min_x = inner_size.width + pos.x - size.width
        else
            max_x = size.width - pos.x
            min_x = - pos.x
        end
        for i = 1, #self._offset do
            if min_x < self._offset[i] then
                min_idx = i
                break
            end
        end
        for i = min_idx, #self._offset do
            max_idx = i
            if max_x <= self._offset[i] then
                break
            end
        end
    end
    
    -- print("min_idx, max_id'x = ", min_idx, max_idx)
    return min_idx, max_idx
end

function UITableView:_removeItem(idx)
    local cell = self.container:getChildByTag(idx)
    if cell and not tolua.isnull(cell) and cell._is_create then
        -- print("_removeItem  idx = ", idx, "min_idx = ", self.min_idx , "max_idx = ", self.max_idx)
        cell:setTag(idx + 100000)
        cell:runAction(cc.RemoveSelf:create())
        self:_resetCell(idx)
    end
    return cell
end

function UITableView:_addItem(idx)
    local cell = self.container:getChildByTag(idx)
    if not cell then
        cell = self:_resetCell(idx)
    end
    if not cell._is_create then
        self:_createLine(cell, idx)
    end
end

function UITableView:_resetCell(idx)
    local cell = self.container:getChildByTag(idx)
    if cell then
        cell:removeFromParent()
    end
    local width, height = self:_cellSizeForTable(idx)
    local inner_size = self:getInnerContainerSize()
    local cell = UIWidget:create()
    cell:setAnchorPoint(cc.p(0, 0))
    cell:setContentSize(cc.size(width, height))
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            cell:setPosition(0, self._offset[idx - 1])
        else
            cell:setPosition(0, inner_size.height - self._offset[idx])
        end
    else
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            cell:setPosition(inner_size.width - self._offset[idx], 0)
        else
            cell:setPosition(self._offset[idx - 1], 0)
        end
    end
    cell:setTag(idx)
    cell._is_create = false

    self.container:addChild(cell)
    if self.enable_cell_box then
        GlobalApi:drawBoundingbox(cell, cell)
    end
    return cell
end

function UITableView:_createLine(cell, idx)
    -- print("_createLine  idx = ", idx)
    cell._is_create = true
    local line_size = cell:getContentSize()
    local offset
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        offset = line_size.width/2 - (self.line_cell_num - 1)/2*self.cell_width
    else
        offset = line_size.height/2 + (self.line_cell_num - 1)/2*self.cell_height
    end
    for i = 1, self.line_cell_num do
        local index = (idx - 1)*self.line_cell_num + i
        if index <= self.max_cell_num then
            local item_cell = self.cell_create_callback(self, index)
            if item_cell then
                item_cell:setName("inner_cell_" .. i)
                cell:addChild(item_cell)

                if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
                    item_cell:setPosition(offset + (i - 1)*(self.cell_width), line_size.height/2)
                else
                    item_cell:setPosition(line_size.width/2, offset - (i - 1)*(self.cell_height))
                end
            end
        end
    end
    if self.enable_cell_box then
        GlobalApi:drawBoundingbox(cell, cell)
    end
end

function UITableView:_calculatePositionByMinIdx(min_idx, is_turn)
    if min_idx <= 0 then
        self:resetPosition()
        return
    elseif min_idx > self.max_line then
        self:resetPositionReverse()
        return
    end
    self:stopAutoScroll()
    local pos_x, pos_y
    local inner_size = self:getInnerContainerSize()
    local size = self:getContentSize()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        pos_x = 0
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            pos_y = - self._offset[min_idx - 1]
        else
            pos_y = size.height - inner_size.height + self._offset[min_idx - 1]
        end
    else
        pos_y = 0
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            pos_x = size.width - inner_size.width + self._offset[min_idx - 1]
        else
            pos_x = - self._offset[min_idx - 1]
        end
    end
    if is_turn and pos_x and pos_y then
        self:_setContainerPosition(pos_x, pos_y)
    end
    return pos_x , pos_y
end

function UITableView:_calculatePositionByMaxIdx(max_idx, is_turn)
    if max_idx <= 0 then
        self:resetPosition()
        return
    elseif max_idx > self.max_line then
        self:resetPositionReverse()
        return
    end
    self:stopAutoScroll()
    local pos_x, pos_y
    local inner_size = self:getInnerContainerSize()
    local width, height = self:_cellSizeForTable(max_idx)
    local size = self:getContentSize()
    if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
        pos_x = 0
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            pos_y = - self._offset[max_idx] + size.height
        else
            pos_y = self._offset[max_idx] - inner_size.height
        end
    else
        pos_y = 0
        if self.align_direction == self.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            pos_x = self._offset[max_idx] - inner_size.width
        else
            pos_x = - self._offset[max_idx] + size.width
        end
    end
    if is_turn and pos_x and pos_y then
        self:_setContainerPosition(pos_x, pos_y)
    end
    return pos_x , pos_y
end

function UITableView:_setContainerPosition(pos_x, pos_y)
    local inner_size = self:getInnerContainerSize()
    local size = self:getContentSize()
    if pos_y ~= 0 then
        pos_y = math.max(pos_y, size.height - inner_size.height)
        pos_y = math.min(pos_y, 0)
    end
    if pos_x ~= 0 then
        pos_x = math.max(pos_x, size.width - inner_size.width)
        pos_x = math.min(pos_x, 0)
    end
    self:setInnerContainerPosition(cc.p(pos_x, pos_y))
end

return UITableView