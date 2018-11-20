--单个玩家item

local M = class("PlayerItem")

function M:ctor(node, onTouch, onChangeSeat, seatID)
    self._node = node
    self._onTouch      = onTouch
    self._onChangeSeat = onChangeSeat
    self._seatID = seatID
    self._playerInfo = nil

    self:_initUI()
end

function M:_initUI()
    self.bg = self._node:getChildByName("bg")
    self.bg:onClick(handler(self, self._onClickNode))
    self.bg:setVisible(false)

    self.btn_changeDesk = self._node:getChildByName("btn_changeDesk")
    self.btn_changeDesk:onClick(handler(self, self._onBtnChangeSeat))
    self.btn_changeDesk:setVisible(true)
end

function M:_render(playerInfo, ifOwner)
    local bg = self._node:getChildByName("bg")

    bg:getChildByName("name"):setString(playerInfo.name)

    local totalCount = playerInfo.winCount + playerInfo.loseCount

    local str = string.format(
        "胜率:%d 局数:%d", 
        totalCount == 0 and 0 or (playerInfo.winCount / totalCount * 100),
        totalCount)
    bg:getChildByName("winning"):setString(str)

    bg:getChildByName("ownerFlag"):setVisible(ifOwner)

    self.bg:setVisible(true)
    self.btn_changeDesk:setVisible(false)
end

function M:_onClickNode()
    print("item 被点击")
end

function M:_onBtnChangeSeat()
    if self._onChangeSeat then 
        self._onChangeSeat(self._seatID)
    end
end

function M:update(playerInfo, ifOwner)
    self._playerInfo = playerInfo

    self._ifOwner = ifOwner

    self:_render(playerInfo, ifOwner)
end

function M:getData()
    return self._playerInfo, self._ifOwner
end

function M:reset()
    self.bg:setVisible(false)
    self.btn_changeDesk:setVisible(true)

    self._playerInfo = nil
    self._ifOwner = false
end



return M