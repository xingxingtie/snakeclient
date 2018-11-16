
local SceneSandTable = require("app.scenes.sandtable.SceneSandTable")

local PLAYER_UI_NUM = 6

local M = class("SceneRoom", cc.Scene)
function M:ctor() 
    self:_initUI()

    self:_registerMsgProcess()

    self:enableNodeEvents()
end

function M:_initUI()
    local ui = require("res.ui.room_layer").create()
    self:addChild(ui.root)
    ui.root:setContentSize(display.size)
    ccui.Helper:doLayout(ui.root)

    local btnStart = ui.root:getChildByName("btn_start")
    btnStart:onClick(handler(self, self._onBtnStart))

    self._playerUIList = {}
    for i=1, PLAYER_UI_NUM do 
        local node = ui.root:getChildByName("player_" .. i)
        node:setVisible(false)
        table.insert(self._playerUIList, node)
    end
end

function M:_renderPlayerUI(roomPlayerInfo)
    local ui = self._playerUIList[roomPlayerInfo.position]:getChildByName("bg")

    ui:getChildByName("name"):setString(roomPlayerInfo.name)

    local totalCount = roomPlayerInfo.winCount + roomPlayerInfo.loseCount
    local str = string.format(
        "胜率:%d 局数:%d", 
        roomPlayerInfo.winCount / totalCount * 100,
        totalCount)
    ui:getChildByName("winning"):setString(str)
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
        "s2c_leaveRoom", 
        handler(self, self._onMsgLeaveRoom))
end

--游戏开始
function M:_onMsgStartGame(msg)
    self._sandScene:run(msg.turnCmd)

    display.runScene(self._sandScene)
end

function M:_onMsgRoomInfo(msg)
    for _, info in ipairs(msg.roomPlayerInfo) do
        self:_renderPlayerUI(info)
    end
end

function M:_onMsgPlayerJoinRoom(msg)
    self._sandScene:run(msg.turnCmd)

    display.runScene(self._sandScene)
end

function M:_onMsgLeaveRoom(msg)
    self._sandScene:run(msg.turnCmd)

    display.runScene(self._sandScene)
end


function M:onEnter()
    local code = G_MsgManager:packData(
        "c2s_roomInfo")

    G_SocketTCP:send(code)
end

function M:onExit()
    
end

function M:onBtnMatchClick()
    local code = G_MsgManager:packData(
        "c2s_match", {})
    G_SocketTCP:send(code)
end

return M