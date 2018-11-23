--云风博客中提到的经典帧同步做法
--[[
    如果只是想验证基础模型就不要想太复杂，不要在搞明白之前就考虑优化。不要考虑任何网络波动，延迟，丢包（用 TCP 假定连接稳定绝对不会断）。

    1. 客户端把操作依次发出去，回合时间到了就发个回合结束标记。

    2. 服务器收到什么转发什么，不做任何处理。和时间也没任何关系。

    3. 客户端只有收到所有玩家（包括自己）的回合结束标记后，再表现这个回合。不然就卡住等待。

    > 如果按照这种方式去做，并且把第n回合的操作严格的交给第n+1回合去执行(第1回合需要自行驱动运行)。那么从回合结束时数据发出去，到接受到新回合这一段时间画面一定会卡帧。

    > 如果按照这种方式去做，并且把第n回合的操作严格的交给第n+2回合去执行（第1、2回合需要自行驱动运行）。
       每回合发送回合标记的时候要指明是第几回合的标记。 比如第五回合结束发送了第五回合的结束标记，ping值小于100时，第六回合结束前一定能收到第五回合的操作（包括结束标记），
       第六回合收到第五回合操作后，并不会立即执行，而是要等到第六回合结束，在推演第7回合的时候使用。  
]]

local THINK_TIME = 0.1

local Role = require("app.scenes.answerlockstep.role")
local M = class("TcpTest", cc.Scene)

function M:ctor(playerList, msg)
    self._roleList          = {}
    self._commandList       = {}     --玩家命令列表，记录了每回合的玩家数据
    self._turnIndex         = 0      --当前回合计数
    self._commandQueue      = {}     --玩家尚未发出去的指令队列      
    self._hugray            = false  --是否饥饿   

    self._turnDuration = msg.turnTime

    self:_initUI(playerList)

    self:_registerMsgProcess()

    self:enableNodeEvents()

    self._curCommand = nil
end

function M:_initUI(playerList)
    
    display.newLayer(cc.c3b(255, 255, 255))
        :addTo(self)
    
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

function M:_ifCmdArrive(cmd)

    if not cmd then 
        return false
    end

    local countA = 0
    for k, v in pairs(cmd) do
        countA = countA + 1
    end

    local countB = 0
    for k, v in pairs(self._roleList) do
        countB = countB + 1
    end

    return countA == countB
end

--进入下一轮
function M:_enterNextTurn(turnCmd)
    if turnCmd then 
        for k,v in pairs(turnCmd) do 
            local role = self._roleList[k]

            if #v == 1 and v[1] == 0 then 
                v[1] = nil
            end

            role:onCommand(v[1])    --只执行一个命令       

            if v[1] then 
                --print("执行命令", os.clock())
            end
        end
    end

    --沙盘推演 0.1秒后的状态
    for _, v in pairs(self._roleList) do 
        v:updateLogic(THINK_TIME)
    end

    self._turnIndex = self._turnIndex + 1

    --0.1秒后一回合结束,处理回合结束逻辑
    self:callAfter(THINK_TIME, handler(self, self._onTurnOver))
end

--回合结束处理
function M:_onTurnOver()
    --print("回合结束", os.clock())
    --发送当前回合命令 若没有则发0
    if #self._commandQueue == 0 then 
        self._commandQueue[1] = 0
    end
    local code = G_MsgManager:packData(
        "c2s_userCommand", {
        cmd = self._commandQueue,
        turnIndex = self._turnIndex})

    G_SocketTCP:send(code)

    self._commandQueue = {}

    --如果是第2回合结束，那么查找第一回合的数据是否已经到达
    
    if self._turnIndex >= 2 then 
        local curTurnCmd = self._commandList[self._turnIndex - 1]

        if self:_ifCmdArrive(curTurnCmd) then --如果第1回合操作完全到达，则立即进入第3回合
            self:_enterNextTurn(curTurnCmd)
        else 
            print("饥饿")
            self._hugray = true
            return
        end
    end

    --如果是第一回合结束则立即进入第二回合
    if self._turnIndex == 1 then 
        self:_enterNextTurn()
    end
end

function M:_frameUpdate(dt)
    for _, v in pairs(self._roleList) do 
        v:update(dt)
    end
end

function M:_onMsgTurnCommand(msg)
    msg = msg.userCmd

    local cmd = self._commandList[msg.turnIndex]
    if not cmd then
        cmd = {} 
        self._commandList[msg.turnIndex] = cmd
    end

    cmd[msg.userID] = msg.cmd

    if self._hugray then 
        local curTurnCmd = self._commandList[self._turnIndex - 1]
        if self:_ifCmdArrive(curTurnCmd) then --如果第1回合操作完全到达，则立即进入第3回合
            self:_enterNextTurn(curTurnCmd)

            self._hugray = false
        end
    end
end

function M:_onMsgLaunch()

    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            self:_frameUpdate(dt)
        end,
        0,
        false)

    self._turnIndex = 0
    self:_enterNextTurn()

    --进入
end

function M:onEnter()
    local onKeyReleased = function ( keycode, event )    
        -- local code = G_MsgManager:packData(
        --     "c2s_userCommand", {cmd = keycode})
        -- G_SocketTCP:send(code)

        print("发出命令", os.clock())

        table.insert(self._commandQueue, keycode)
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --G_MsgManager:RegisterFrameEventListener(handler(self, self._frameUpdate))

    local code = G_MsgManager:packData("c2s_loadComplete")
    G_SocketTCP:send(code)
end

return M