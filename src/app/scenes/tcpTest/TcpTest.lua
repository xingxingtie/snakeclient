--tcp 帧同步测试
--前端自己没有逻辑帧，使用后端逻辑帧到达的时间当成前端的逻辑帧
--前端指令在按下键的时候立马发出
--测试结果：前端画面会有抖动不平滑

local Role = require("app.scenes.tcpTest.role")
local M = class("TcpTest", cc.Scene)

function M:ctor(playerList, msg)
    self._roleList = {}

    self._turnDuration = msg.turnTime

    self:_initUI(playerList)

    self:_registerMsgProcess()

    self:enableNodeEvents()
end

function M:_initUI(playerList)
    for _, v in ipairs(playerList) do 
        local role = Role:create()
            :addTo(self)
            
        self._roleList[v.userID] = role
    end
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_turnCommand", 
        handler(self, self._onMsgTurnCommand))

    G_MsgManager:registerMsgProcess(
        "s2c_launch", 
        handler(self, self._onMsgLaunch))
end

function M:_frameUpdate(dt)
    for _, v in pairs(self._roleList) do 
        v:update(dt)
    end
end

function M:_onMsgTurnCommand(msg)
    local turnIndex = msg.turnIndex

    --分发命令
    for _, v in ipairs(msg.turnCmd) do 
        local role = self._roleList[v.userID]
        role:onCommand(v.cmd, self._turnDuration, turnIndex)
    end

    --沙盘推演
    for _, v in pairs(self._roleList) do 
        if (v:getTurnIndex() ~= turnIndex) then 
            v:onCommand(nil, self._turnDuration, turnIndex)
        end
    end 
end

function M:_onMsgLaunch()
    self:_onMsgTurnCommand({turnCmd = {}})
end

M.preTime = 0

function M:onEnter()
    local onKeyReleased = function ( keycode, event )    
        local code = G_MsgManager:packData(
            "c2s_userCommand", {cmd = keycode})
        M.preTime = os.clock()
        G_SocketTCP:send(code)
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    G_MsgManager:RegisterFrameEventListener(
        handler(self, self._frameUpdate))

    local code = G_MsgManager:packData("c2s_loadComplete")
    G_SocketTCP:send(code)
end

return M