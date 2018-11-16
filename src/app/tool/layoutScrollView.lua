--布局scrollView
local M = {}

--将scrollView和内部的容器宽度调整为width
function M.adjustScrollView(scrollView, width)
    local scrollViewSize = scrollView:getContentSize()
    scrollViewSize.width = width

    scrollView:setContentSize(scrollViewSize)
    scrollView:setInnerContainerSize(scrollViewSize)
end

-- 从上到下，从左到右平铺
-- item要求在设置其x为0，y为scrollView中容器的高度时，位于滚动框的左上角
function M.tile(scrollView, itemList, itemWidth, itemHeight, blankY, marginX)
    local innerC     = scrollView:getInnerContainer()
    local innerSize  = innerC:getContentSize()
    local scrollSize = scrollView:getContentSize()
    local rowNum     = (#itemList == 1) and 1 or math.floor(innerSize.width / itemWidth)
   
    local lineNum   = math.ceil(#itemList / rowNum)
    blankY = blankY or 5
    marginX = marginX or 10

    innerSize.height = lineNum * (itemHeight + blankY) - blankY
    innerSize.height = scrollSize.height > innerSize.height and scrollSize.height or innerSize.height
    scrollView:setInnerContainerSize(innerSize)
    local index = 1
    local X = (rowNum == 1) and (innerSize.width - itemWidth) / 2 or marginX
    local originX = X
    local Y = innerSize.height
    local blankX = (rowNum == 1) and 0 or (innerSize.width - rowNum * itemWidth - 2 * marginX) / (rowNum - 1) + itemWidth
    
    for i=1, lineNum do 
        for j=1, rowNum do 
            local item = itemList[index]
            if not item then return end
            item:setPosition(X, Y)
            scrollView:addChild(item)
            X = X + blankX
            index = index + 1
        end

        Y = Y - itemHeight - blankY
        X = originX
    end
end

return M