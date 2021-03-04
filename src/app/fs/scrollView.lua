local UIScrollView = class("UIScrollView", function()
    local scrollView =  ccui.ScrollView:create()
    scrollView._setDirection = scrollView.setDirection
    scrollView._setContentSize = scrollView.setContentSize
    scrollView:setScrollBarEnabled(false)
    return scrollView
end)

UIScrollView._setInnerContainerPosition = GApi.getSuperMethod(ccui.ScrollView, "setInnerContainerPosition")

UIScrollView.DIRECTION = {
    NONE = 0,
    VERTICAL = 1,
    HORIZONTAL = 2,
    BOTH = 3
}

UIScrollView.ALIGN_DIRECTION = {
    NONE = 0,
    TOP_TO_BOTTOM = 1,
    BOTTOM_TO_TOP = 2,
    LEFT_TO_RIGHT = 3,
    RIGHT_TO_LEFT = 4
}

function UIScrollView:ctor()
end

function UIScrollView:createWithAutoAlign()
    local sv = UIScrollView:create()
    sv:initWithAutoAlign()
    return sv
end

function UIScrollView:initWithAutoAlign()
    self.realtime_calculate_size = false
    self.item_space = 0
    self.container_space = 0
    self.grid_max_length = 0
    self.grid_space = 0
    self.grid_item_pos = 0
    self.grid_item_count = 0
    self.grid_item_num = 0
    self.grid_item_direction = UIScrollView.ALIGN_DIRECTION.NONE
    self.direction = UIScrollView.DIRECTION.NONE
    self.align_direction = UIScrollView.ALIGN_DIRECTION.NONE
    self.content_width = 0
    self.content_height = 0
    self.view_size = cc.size(0, 0)
    self.items = {}
    self.check_flag = nil
    self.event_enable = nil

    self.container = fs.Widget:create()
    self:addChild(self.container)
    self:setEventEnabled(true)
end

function UIScrollView:setEventEnabled(enable)
    self.event_enable = enable
end

function UIScrollView:setCheckFlag(flag)
    self.check_flag = flag
end

function UIScrollView:setSpace(space)
    self.item_space = space
end

function UIScrollView:addSpace(space)
    self.content_height = self.content_height + space
    self:alignContainer()
end

function UIScrollView:setContainerSpace(space)
    self.container_space = space
end

function UIScrollView:setDirection(direction)
    self.direction = direction
    self:_setDirection(direction)
end

function UIScrollView:setAlignDirection(direction)
    self.align_direction = direction
end

function UIScrollView:setGridAlignDirection(direction)
    self.grid_item_direction = direction
end

function UIScrollView:setGridMaxLength(length)
    self.grid_max_length = length
end

function UIScrollView:setContentSize(...)
    local args = {...}
    if #args == 1 then
        self.view_size = args[1]
    else
        self.view_size = cc.size(args[1], args[2])
    end
    self:_setContentSize(...)
end

function UIScrollView:setItemSize(size)
    self.item_size = size
end

-- 每个子项的高度不一样时，需要调用
function UIScrollView:setRealtimeCalculateSize(is_realtime)
    self.realtime_calculate_size = is_realtime
end

function UIScrollView:getAllItems()
    return self.items
end

function UIScrollView:getItemById(index)
    return self.items[index]
end

function UIScrollView:getItemsCount()
    return #self.items
end

function UIScrollView:alignItemPosition(item, item_size, index, is_first, is_insert, space)
    if self.direction == UIScrollView.DIRECTION.VERTICAL then
        local anchor_point = item:getAnchorPoint()
        local reverse = nil
        local height = nil
        if self.align_direction == UIScrollView.ALIGN_DIRECTION.NONE or self.align_direction == UIScrollView.ALIGN_DIRECTION.TOP_TO_BOTTOM then
            reverse = 1
            height = item_size.height*anchor_point.y
        elseif self.align_direction == UIScrollView.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            reverse = -1
            height = item_size.height*(1 - anchor_point.y)
        else
            return
        end
        if is_first then -- 第一个item
            self.content_height = self.content_height + item_size.height + self.container_space + space
            local item_posx = nil
            local item_posy = (height - self.content_height)*reverse
            if self.grid_max_length > 0 then
                self.grid_item_num = 0
                self.grid_item_count = math.floor(self.grid_max_length/item_size.width)
                if self.grid_item_count < 1 then
                    self.grid_item_count = 1
                elseif self.grid_item_count > 1 then
                    self.grid_space = (self.grid_max_length - (item_size.width*self.grid_item_count))/(self.grid_item_count - 1)
                end
                self.grid_item_pos = 0
                if self.grid_item_direction == UIScrollView.ALIGN_DIRECTION.RIGHT_TO_LEFT then
                    item_posx = self.grid_max_length - (1 - anchor_point.x)*item_size.width
                else
                    item_posx = anchor_point.x*item_size.width
                end
            else
                item_posx = (anchor_point.x - 0.5)*item_size.width
            end
            item:setPosition(item_posx, item_posy)
        else
            local item_posx = nil
            if self.grid_max_length > 0 then
                if self.grid_item_count == 1 then
                    local grid_item_count = math.floor(self.grid_max_length/item_size.width)
                    if self.grid_item_count ~= grid_item_count and index >= grid_item_count then
                        self.grid_item_count = grid_item_count
                    end
                end
                if self.grid_item_num + 1 >= self.grid_item_count then
                    self.grid_item_num = 0
                    self.grid_item_pos = 0
                    self.content_height = self.content_height + item_size.height + self.item_space + space
                else
                    self.grid_item_num = self.grid_item_num + 1
                    self.grid_item_pos = (item_size.width + self.grid_space)*self.grid_item_num
                end
                if self.grid_item_direction == UIScrollView.ALIGN_DIRECTION.RIGHT_TO_LEFT then
                    item_posx = self.grid_max_length - self.grid_item_pos - (1 - anchor_point.x)*item_size.width
                else
                    item_posx = self.grid_item_pos + anchor_point.x*item_size.width
                end
            else
                item_posx = (anchor_point.x - 0.5)*item_size.width
                self.content_height = self.content_height + item_size.height + self.item_space + space
            end
            local item_posy = (height - self.content_height)*reverse
            if is_insert then -- 插到前面
                item:setPosition(self.items[index]:getPosition())
                if index <= #self.items - 1 then
                    for i = index, #self.items - 1 do
                        self.items[i]:setPosition(self.items[i + 1]:getPosition())
                    end
                end
                self.items[#self.items]:setPosition(item_posx, item_posy)
            else -- 放到最后
                item:setPosition(item_posx, item_posy)
            end
        end
    elseif self.direction ==  UIScrollView.DIRECTION.HORIZONTAL then
        local anchor_point = item:getAnchorPoint()
        local reverse
        local width
        if self.align_direction == UIScrollView.ALIGN_DIRECTION.NONE or self.align_direction == UIScrollView.ALIGN_DIRECTION.LEFT_TO_RIGHT then
            reverse = -1
            width = item_size.width*(1 - anchor_point.x)
        elseif self.align_direction == UIScrollView.ALIGN_DIRECTION.RIGHT_TO_LEFT then
            reverse = 1
            width = item_size.width*anchor_point.x
        else
            return
        end
        if is_first then -- 添加到第一个
            self.content_width = self.content_width + item_size.width + self.container_space + space
            local item_posx = (width - self.content_width)*reverse
            local item_posy = nil
            if self.grid_max_length > 0 then
                self.grid_item_num = 0
                self.grid_item_count = math.floor(self.grid_max_length/item_size.height)
                if self.grid_item_count < 1 then
                    self.grid_item_count = 1
                elseif self.grid_item_count > 1 then
                    self.grid_space = (self.grid_max_length - (item_size.height*self.grid_item_count))/(self.grid_item_count - 1)
                end
                self.grid_item_pos = 0
                if self.grid_item_direction == UIScrollView.ALIGN_DIRECTION.BOTTOM_TO_TOP then
                    item_posy =  anchor_point.y*item_size.height
                else
                    item_posy = self.grid_max_length - (1 - anchor_point.y)*item_size.height
                end
            else
                item_posy = (anchor_point.y - 0.5)*item_size.height
            end
            item:setPosition(item_posx, item_posy)
        else
            local item_posy = nil
            if self.grid_max_length > 0 then
                if self.grid_item_num + 1 >= self.grid_item_count then
                    self.grid_item_num = 0
                    self.grid_item_pos = 0
                    self.content_width = self.content_width + item_size.width + self.item_space + space
                else
                    self.grid_item_num = self.grid_item_num + 1
                    self.grid_item_pos = (item_size.height + self.grid_space)*self.grid_item_num
                end
                if self.grid_item_direction == UIScrollView.ALIGN_DIRECTION.BOTTOM_TO_TOP then
                    item_posy = self.grid_item_pos + anchor_point.y*item_size.height
                else
                    item_posy = self.grid_max_length - self.grid_item_pos - (1 - anchor_point.y)*item_size.height
                end
            else
                item_posy = (anchor_point.y - 0.5)*item_size.height
                self.content_width = self.content_width + item_size.width + self.item_space + space
            end
            local item_posx = (width - self.content_width)*reverse
            if is_insert then -- 插到前面
                item:setPosition(self.items[index]:getPosition())
                if index <= #self.items - 1 then
                    for i = index, #self.items - 1 do
                        self.items[i]:setPosition(self.items[i + 1]:getPosition())
                    end
                end
                self.items[#self.items]:setPosition(item_posx, item_posy)
            else -- 放到最后
                item:setPosition(item_posx, item_posy)
            end
        end
    end
end

function UIScrollView:alignContainer()
    self:stopOverallScroll()
    if self.direction == UIScrollView.DIRECTION.VERTICAL then
        if self.align_direction == UIScrollView.ALIGN_DIRECTION.NONE or self.align_direction == UIScrollView.ALIGN_DIRECTION.TOP_TO_BOTTOM then
            self:alignContainerVerticalTop()
        elseif self.align_direction == UIScrollView.ALIGN_DIRECTION.BOTTOM_TO_TOP then
            self:alignContainerVerticalBottom()
        end
    elseif self.direction == UIScrollView.DIRECTION.HORIZONTAL then
        if self.align_direction == UIScrollView.ALIGN_DIRECTION.NONE or self.align_direction == UIScrollView.ALIGN_DIRECTION.LEFT_TO_RIGHT then
            self:alignContainerHorizontalLeft()
        elseif self.align_direction == UIScrollView.ALIGN_DIRECTION.RIGHT_TO_LEFT then
            self:alignContainerHorizontalRight()
        end
    end
end

function UIScrollView:alignContainerVerticalTop()
    local last_posy = self.container:getPositionY()
    local content_height = self.content_height + self.container_space
    local container_posy = self.view_size.height < content_height and content_height or self.view_size.height
    self:getInnerContainer():setContentSize(cc.size(self.view_size.width, container_posy))
    if self.grid_max_length > 0 then
        self.container:setPosition((self.view_size.width - self.grid_max_length)/2, container_posy)
    else
        self.container:setPosition(self.view_size.width/2, container_posy)
    end
    if container_posy > last_posy then -- add
        local min_container_offset_y = self.view_size.height - container_posy
        local container_pos = self:getInnerContainerPosition()
        if container_pos.y - container_posy + last_posy > min_container_offset_y then
            self:setInnerContainerPosition(cc.p(container_pos.x, container_pos.y - container_posy + last_posy))
        else
            self:setInnerContainerPosition(cc.p(container_pos.x, min_container_offset_y))
        end
    elseif container_posy < last_posy then -- reduce
        local max_container_offset_y = 0
        local container_pos = self:getInnerContainerPosition()
        if container_pos.y - container_posy + last_posy < max_container_offset_y then
            self:setInnerContainerPosition(cc.p(container_pos.x, container_pos.y + last_posy - container_posy))
        else
            self:setInnerContainerPosition(cc.p(container_pos.x, max_container_offset_y))
        end
    end
end

function UIScrollView:alignContainerVerticalBottom()
    local content_height = self.content_height + self.container_space
    local container_posy = content_height > self.view_size.height and content_height or self.view_size.height
    self:getInnerContainer():setContentSize(cc.size(self.view_size.width, container_posy))
    if self.grid_max_length > 0 then
        self.container:setPosition((self.view_size.width - self.grid_max_length)/2, 0)
    else
        self.container:setPosition(self.view_size.width/2, 0)
    end

    local min_container_offset_y = self.view_size.height - container_posy
    local container_pos = self:getInnerContainerPosition()
    if container_pos.y < min_container_offset_y then
        self:setInnerContainerPosition(cc.p(container_pos.x, min_container_offset_y))
    end
end

function UIScrollView:alignContainerHorizontalLeft()
    local content_width = self.content_width + self.container_space
    local container_posx = content_width > self.view_size.width and content_width or self.view_size.width
    self:getInnerContainer():setContentSize(cc.size(container_posx, self.view_size.height))
    if self.grid_max_length > 0 then
        self.container:setPosition(0, (self.view_size.height - self.grid_max_length)/2)
    else
        self.container:setPosition(0, self.view_size.height/2)
    end

    local min_container_offset_x = self.view_size.width - container_posx
    local container_pos = self:getInnerContainerPosition()
    if container_pos.x < min_container_offset_x then
        self:setInnerContainerPosition(cc.p(min_container_offset_x, container_pos.y))
    end
end

function UIScrollView:alignContainerHorizontalRight()
    local last_posx = self.container:getPositionX()
    local content_width = self.content_width + self.container_space
    local container_posx = self.view_size.width < content_width and content_width or self.view_size.width
    self:getInnerContainer():setContentSize(cc.size(container_posx, self.view_size.height))
    if self.grid_max_length > 0 then
        self.container:setPosition(container_posx, (self.view_size.height - self.grid_max_length)/2)
    else
        self.container:setPosition(container_posx, self.view_size.height/2)
    end

    if container_posx > last_posx then -- add
        local min_container_offset_x = self.view_size.width - container_posx
        local container_pos = self:getInnerContainerPosition()
        if container_pos.x - container_posx + last_posx > min_container_offset_x then
            self:setInnerContainerPosition(cc.p(container_pos.x - container_posx + last_posx, container_pos.y))
        else
            self:setInnerContainerPosition(cc.p(min_container_offset_x, container_pos.y))
        end
    elseif container_posx < last_posx then -- reduce
        local max_container_offset_x = 0
        local container_pos = self:getInnerContainerPosition()
        if container_pos.x + last_posx - container_posx < max_container_offset_x then
            self:setInnerContainerPosition(cc.p(container_pos.x + last_posx - container_posx, container_pos.y))
        else
            self:setInnerContainerPosition(cc.p(max_container_offset_x, container_pos.y))
        end
    end
end

function UIScrollView:alignItem(item, index, is_first, is_insert, space)
    local item_size = nil
    if self.realtime_calculate_size then
        local content_size = item:getContentSize()
        item_size = cc.size(content_size.width*item:getScaleX(), content_size.height*item:getScaleY())
    else
        if self.item_size == nil then
            local content_size = item:getContentSize()
            self:setItemSize(cc.size(content_size.width*item:getScaleX(), content_size.height*item:getScaleY()))
        end
        item_size = self.item_size
    end
    space = space or 0
    self:alignItemPosition(item, item_size, index, is_first, is_insert, space)
    self:alignContainer()
end

function UIScrollView:autoAlign()
    if #self.items > 0 then
        if self.item_size == nil then
            local item_size = self.items[1]:getContentSize()
            self:setItemSize(cc.size(item_size.width*self.items[1]:getScaleX(), item_size.height*self.items[1]:getScaleY()))
        end
        self:resetContent()
        local item_size = nil
        for i, item in ipairs(self.items) do
            if self.realtime_calculate_size then
                local content_size = item:getContentSize()
                item_size = cc.size(content_size.width*item:getScaleX(), content_size.height*item:getScaleY())
            else
                item_size = self.item_size
            end
            self:alignItemPosition(item, item_size, i, i <= 1, false, 0)
        end
        self:alignContainer()
    end
end

function UIScrollView:addItem(item, index)
    if index then
        table.insert(self.items, index, item)
    else
        table.insert(self.items, item)
    end
    self.container:addChild(item)
end

function UIScrollView:addItemWithAlign(item, space)
    self:alignItem(item, #self.items + 1, #self.items <= 0, false, space)
    self:addItem(item)
end

function UIScrollView:insertItem(item, index)
    self:addItem(item, index)
end

function UIScrollView:insertItemWithAlign(item, index, space)
    self:alignItem(item, index, #self.items <= 0, index <= #self.items, space)
    self:addItem(item, index)
end

function UIScrollView:removeItemByIndex(start_index, end_index)
    if self.direction == UIScrollView.DIRECTION.VERTICAL then
        local remove_count = end_index - start_index + 1
        local total_count = #self.items
        if remove_count < total_count then
            self.content_height = self.content_height - math.abs(self.items[total_count]:getPositionY() - self.items[total_count - remove_count]:getPositionY())
        else
            self.content_height = self.view_size.height
        end
        if self.grid_max_length > 0 then
            local reduce_num = remove_count%self.grid_item_count
            self.grid_item_num = self.grid_item_num - reduce_num
            if self.grid_item_num < 0 then
                self.grid_item_num = self.grid_item_num + self.grid_item_count
            end
            self.grid_item_pos = (self.item_size.width + self.grid_space)*self.grid_item_num
        end
    elseif self.direction == UIScrollView.DIRECTION.HORIZONTAL then
        local remove_count = end_index - start_index + 1
        local total_count = #self.items
        if remove_count < total_count then
            self.content_width = self.content_width - math.abs(self.items[total_count]:getPositionX() - self.items[total_count - remove_count]:getPositionX())
        else
            self.content_width = self.view_size.width
        end
        if self.grid_max_length > 0 then
            local reduce_num = remove_count%self.grid_item_count
            self.grid_item_num = self.grid_item_num - reduce_num
            if self.grid_item_num < 0 then
                self.grid_item_num = self.grid_item_num + self.grid_item_count
            end
            self.grid_item_pos = (self.item_size.height + self.grid_space)*self.grid_item_num
        end
    end
    self:alignContainer()
    if end_index < #self.items then
        local replace_end_index = #self.items
        local remove_count = end_index - start_index + 1
        local replace_start_index = replace_end_index - remove_count + 1
        if replace_start_index <= end_index then
            replace_start_index = end_index + 1
        end
        for i = replace_start_index, replace_end_index do
            local item = self.items[i]
            local replaced_index = i - remove_count
            while replaced_index >= start_index do
                local replaced_item = self.items[replaced_index]
                item:setPosition(replaced_item:getPosition())
                self.items[replaced_index] = item
                item = replaced_item
                replaced_index = replaced_index - remove_count
            end
            self.items[i] = item
        end
    end
    for i = start_index, end_index do
        local item = table.remove(self.items)
        item:removeFromParent()
    end
    if #self.items <= 0 then
        self:resetContent()
    end
end

function UIScrollView:removeItem(start_index, end_index)
    if #self.items > 0 then
        if start_index then
            if start_index > #self.items then
                start_index = #self.items
            elseif start_index < 0 then
                return
            end
        else
            start_index = #self.items
        end
        if end_index then
            if end_index < start_index then
                end_index = start_index
            elseif end_index > #self.items then
                end_index = #self.items
            end
        else
            end_index = start_index
        end
        self:removeItemByIndex(start_index, end_index)
    end
end

function UIScrollView:swapItem(index_a, index_b)
    if index_a == index_b then
        return
    end
    if index_a == nil or index_b == nil then
        return
    end
    local item_a = self.items[index_a]
    local item_b = self.items[index_b]
    if item_a and item_b then
        local pos_a_x, pos_a_y = item_a:getPosition()
        local pos_b_x, pos_b_y = item_b:getPosition()
        item_a:setPosition(pos_b_x, pos_b_y)
        item_b:setPosition(pos_a_x, pos_a_y)
        self.items[index_a] = item_b
        self.items[index_b] = item_a
    end
end

function UIScrollView:moveItemToHead(index)
    self:moveItem(index, 1)
end

function UIScrollView:moveItemToTail(index)
    self:moveItem(index, #self.items)
end

function UIScrollView:moveItem(index, move_to)
    if index == nil then
        return
    end
    if move_to then
        if move_to < 1 then
            move_to = 1
        elseif move_to > #self.items then
            move_to = #self.items
        end
    else
        move_to = #self.items
    end
    if index == move_to then
        return
    end
    if self.items[index] == nil or self.items[move_to] == nil then
        return
    end
    if index < move_to then -- 往后移动
        local move_index = move_to
        local move_item = self.items[move_index]
        local move_to_posx, move_to_posy = self.items[move_to]:getPosition()
        while index < move_index do
            local last_item = self.items[move_index - 1]
            move_item:setPosition(last_item:getPosition())
            self.items[move_index - 1] = move_item
            move_item = last_item
            move_index = move_index - 1
        end
        move_item:setPosition(move_to_posx, move_to_posy)
        self.items[move_to] = move_item
    elseif index > move_to then -- 往前移动
        local move_index = move_to
        local move_item = self.items[move_index]
        local move_to_posx, move_to_posy = self.items[move_to]:getPosition()
        while index > move_index  do
            local next_item = self.items[move_index + 1]
            move_item:setPosition(next_item:getPosition())
            self.items[move_index + 1] = move_item
            move_item = next_item
            move_index = move_index + 1
        end
        move_item:setPosition(move_to_posx, move_to_posy)
        self.items[move_to] = move_item
    end
end

function UIScrollView:getScrollRect()
    assert(self:getParent(), "must be parent")
    local box = self:getBoundingBox()
    local x0 = cc.rectGetMinX(box)
    local y0 = cc.rectGetMinY(box)
    local size = self:getContentSize()
    local pos = self:getParent():convertToWorldSpace(cc.p(x0, y0))
    return cc.rect(pos.x, pos.y, size.width, size.height)
end

function UIScrollView:setInnerContainerPosition(pos)
    self:_setInnerContainerPosition(pos)
end

function UIScrollView:removeAllItems()
    self.items = {}
    self.container:removeAllChildren()
    self:resetContent()
end

function UIScrollView:resetContent()
    self.content_width = 0
    self.content_height = 0
    self.grid_item_pos = 0
    self.grid_item_count = 0
    self.grid_item_num = 0
    self:setInnerContainerSize(self.view_size)
    self:setInnerContainerPosition(cc.p(0, 0))
end

function UIScrollView:getViewContentSize()
    return cc.size(self.content_width, self.content_height)
end

return UIScrollView