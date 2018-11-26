
local SceneSandTable = require("app.scenes.sandtable.SceneSandTable")
local TcpTest = require("app.scenes.tcpTest.TcpTest")
--local TcpTest = require("app.scenes.answerlockstep.TcpTest")
local PlayerItem = require("app.scenes.room.PlayerItem")


local PLAYER_UI_NUM = 6

local M = class("SceneRoom", cc.Scene)
function M:ctor() 
    self._owner = nil

    self:_initUI()

    self:_registerMsgProcess()

    self:enableNodeEvents()
end

function M:_initUI()
    local ui = require("res.ui.room_layer").create()
    self:addChild(ui.root)
    ui.root:setContentSize(display.size)
    ccui.Helper:doLayout(ui.root)

    self.btnStart = ui.root:getChildByName("btn_start")
    self.btnStart:onClick(handler(self, self._onBtnStart))
    self.btnStart:setVisible(false)

    self._playerUIList = {}
    for i=1, PLAYER_UI_NUM do 
        local node = ui.root:getChildByName("player_" .. i)

        local item = PlayerItem:create(
            node, 
            handler(self, self._applyEnterRoom),
            handler(self, self._changeSeat),
            i)
        table.insert(self._playerUIList, item)
    end
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_startGame", 
        handler(self, self._onMsgStartGame))

    G_MsgManager:registerMsgProcess(
        "s2c_roomInfo", 
        handler(self, self._onMsgRoomInfo))

    G_MsgManager:registerMsgProcess(
        "s2c_playerJoinRoom", 
        handler(self, self._onMsgPlayerJoinRoom))

    G_MsgManager:registerMsgProcess(
        "s2c_playerLeaveRoom", 
        handler(self, self._onMsgLeaveRoom))

    G_MsgManager:registerMsgProcess(
        "s2c_changeSeat", 
        handler(self, self._onMsgChangeSeat))
end

function M:_unregisterMsgProcess()
    G_MsgManager:UnregisterMsgProcess("s2c_startGame")
    G_MsgManager:UnregisterMsgProcess("s2c_roomInfo")
    G_MsgManager:UnregisterMsgProcess("s2c_playerJoinRoom")
    G_MsgManager:UnregisterMsgProcess("s2c_playerLeaveRoom")
    G_MsgManager:UnregisterMsgProcess("s2c_changeSeat")
end

function M:_applyEnterRoom()

end

function M:_changeSeat(targetSeat)

    local code = G_MsgManager:packData(
        "c2s_changeSeat",
        {targetSeat = targetSeat})

    G_SocketTCP:send(code)
end

--游戏开始
function M:_onMsgStartGame(msg)
    if msg.retCode ~= 0 then 
        self:toastErrorCode(msg.retCode)

    else 
        local playerInfo = {}
        for _, v in ipairs(self._playerUIList) do 
            local info = v:getData()
            table.insert(playerInfo, info)
        end

        display.runScene(
            TcpTest:create(playerInfo, msg))
    end
end

function M:_onMsgRoomInfo(msg)
    if msg.retCode == 0 then 
        self._owner = msg.ownerID

        self.btnStart:setVisible(self._owner == G_GameData:getUserID())

        for _, info in ipairs(msg.userList) do
            local item = self._playerUIList[info.position]

            item:update(info, info.userID == msg.ownerID)
        end
    else
        self:toastErrorCode(msg.retCode)
    end
end

function M:_onMsgPlayerJoinRoom(msg)
    local info = msg.playerinfo
    local item = self._playerUIList[info.position]

    item:update(info, info.userID == self._owner)
end

function M:_onMsgLeaveRoom(msg)
    self._sandScene:run(msg.turnCmd)

    display.runScene(self._sandScene)
end

function M:_onMsgChangeSeat(msg)
    if msg.retCode == 0 then 
        local playerInfo, ifOwner = self._playerUIList[msg.originSeat]:getData()
        self._playerUIList[msg.originSeat]:reset()
        self._playerUIList[msg.targetSeat]:update(playerInfo, ifOwner)
    else 
        self:toastErrorCode(msg.retCode)
    end
end

function M:_onBtnStart()
    local code = G_MsgManager:packData(
        "c2s_startGame")
    G_SocketTCP:send(code)
end

function M:onEnter()
    local code = G_MsgManager:packData(
        "c2s_roomInfo")

    G_SocketTCP:send(code)
end

function M:onExit()
    M:_unregisterMsgProcess()
end

function M:onBtnMatchClick()
    local code = G_MsgManager:packData(
        "c2s_match", {})
    G_SocketTCP:send(code)
end

return M
