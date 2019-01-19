--单个房间item

local M = class("RoomItem", cc.Node)

function M:ctor(onClick)
    self._node = node
    self._onClick = onClick
    self._roominfo = nil

    self:_initUI()
end

function M:_initUI()
    self._node = require("res.ui.room_item").create().root

    local bg = self._node:getChildByName("bg")
    bg:onClick(handler(self, self._onClickNode))

    self:addChild(self._node)
end

function M:_render(roominfo)
    local bg = self._node:getChildByName("bg")

    local strNum = string.format("%d/%d", roominfo.playerNum, roominfo.capacity)
    bg:getChildByName("num"):setString(strNum)

    bg:getChildByName("name"):setString(roominfo.ownerName)
end

function M:_onClickNode()
    if self._onClick then 
        self._onClick(self._roominfo)
    end
end

function M:update(roominfo)
    self._roominfo = roominfo

    self:_render(roominfo)
end

return M