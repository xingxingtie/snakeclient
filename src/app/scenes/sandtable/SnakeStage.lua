-- 蛇节
local M = class("SnakeStage", cc.Node)

function M:ctor(color, mountPoint, width, height)
    self:addTo(mountPoint)

    self:_initUI(width, height)
end

function M:_initUI(width, height)
    --local sp = display.newSprite("stage.png")
    local sp = display.newSprite("head.jpg")
        :addTo(self)

    local size = sp:getContentSize()
    sp:setScaleX(width / size.width)
    sp:setScaleY(height / size.height)
end

function M:die()
    self:removeSelf()
end

return M

