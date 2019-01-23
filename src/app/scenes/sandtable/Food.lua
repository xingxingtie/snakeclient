--
-- Author: xingxingtie
-- Date: 2019-01-23 10:56:26
--
local M = class("SnakeStage", cc.Node)

function M:ctor(width, height)
    self:_initUI(width, height)
end

function M:_initUI(width, height)
    local sp = display.newSprite("btn_xing.png")
        :addTo(self)
    local size = sp:getContentSize()

    sp:setScaleX(width  / size.width)
    sp:setScaleY(height / size.height)
end

return M