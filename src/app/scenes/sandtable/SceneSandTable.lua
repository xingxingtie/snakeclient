--沙盘

local LayerMap = require("app.scenes.sandtable.LayerMap")
local Const = require("app.const.Const")
local Snake = require("app.scenes.sandtable.Snake")
local SimServer = require("app.scenes.sandtable.SimServer")
local ConstMsgID = require("app.const.ConstMsgID")
local M = class("SceneSandTable", cc.Scene)

function M:ctor()
    self._commandList = {}     --命令列表
  
    self._nextTurnIndex = 1    --下一个待执行的回合索引 nextTurnIndex ==1 执行完后指导第1回合的游戏表现。 nextTurnIndex ==x执行完后指导第x回合的游戏表现。
    self._maxTurnIndex  = 0    --收到的最大的轮回索引号
    self._currentTurn   = 0    --当前正在表现的回合

    self._snakeList = {}
    self:_initUI()
    self:enableNodeEvents()

    self._updateElapse = 0
end

function M:_initUI()
    self._layerMap = LayerMap:create(Const.LINE, Const.ROW, Const.MapWidth, Const.MapHeight)
        :addTo(self)

    self:_addKeyBoardListener()
end

function M:_addKeyBoardListener()
    local lookTable = {
        [28] = Const.DIR_UP,
        [29] = Const.DIR_DOWN,
        [26] = Const.DIR_LEFT,
        [27] = Const.DIR_RIGHT,
    }

    local onKeyReleased = function ( keycode, event )
        if(lookTable[keycode]) then 
            local cmd = {
                cmdType = Const.CMD_CHANG_DIR, 
                cmdValue = lookTable[keycode]
            }
            self:_sendCommand(cmd)
        end
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--发送个人命令
function M:_sendCommand(cmd)
    print("发送命令&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    local code = G_MsgManager:packData(
        ConstMsgID.c2s_userop, "c2s_userop", 
        cmd)

    G_SocketTCP:send(code)
end

--处理命令
function M:_doCommand(cmdList)
    --dump(cmdList, "cmdList")
    local movedFlag = {}

    for k,v in ipairs(cmdList.turnCmd) do 

        if v.cmdType == Const.CMD_NONE and not movedFlag[v.userID] then 

            self._layerMap:moveSnake(v.userID)

            movedFlag[v.userID] = true

        elseif (v.cmdType == Const.CMD_CHANG_DIR and not movedFlag[v.userID]) then 

            self._layerMap:moveSnake(v.userID, v.cmdValue)

            movedFlag[v.userID] = true
        end
    end

    --print("执行成功..........................", self._nextTurnIndex)

    --只要执行一条命令 则下一个待执行的轮回索引+1    
    self._nextTurnIndex = self._nextTurnIndex + 1

    --新一轮开始后，重置更新时间
    self._updateElapse = 0
    self._overTime = false
end

--索取轮回命令 当检测到
function M:_acquireTurnMsg()
    local lackTurn = {}

    for index = self._nextTurnIndex, self._maxTurnIndex - 1 do 
        if not self._commandList[index] then 
            table.insert(lackTurn, index)
        end
    end

    --索要历史轮回命令
end

--一轮到时间后开始执行命令
function M:_overtimeTurn()
    --print("一轮时间到 开始执行", self._commandList[self._nextTurnIndex], self._nextTurnIndex, #self._commandList)
    --dump(self._commandList, "self._commandList")
    local nextCmd = self._commandList[self._nextTurnIndex]

    --命令已到位则执行
    if nextCmd then 
        self:_doCommand(nextCmd)
    end

    --无论如何逻辑轮回一直向前步进
    self._currentTurn = self._currentTurn + 1
end

--更新帧
function M:_update(dt)
    --print("update")
    self._updateElapse = self._updateElapse + dt

    self._updateElapse = math.min(self._updateElapse, Const.StepDuration)

    --超时则表现层停止
    if not self._overTime then 
        self._layerMap:update(self._updateElapse)
    end

    if(self._updateElapse == Const.StepDuration) then 
        self._overTime = true
    end
end

--启动沙盘
function M:run(firstTurnOP)

    self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self._overtimeTurn), 
        0.1, 
        false)

    --启用帧事件
    self:scheduleUpdate(handler(self, self._update))

    --添加指导第一回合表现的命令
    self:_onMsgTurnCommand(firstTurnOP)

    --手动超时一次
    self:_overtimeTurn()

    --注册网络消息
    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_turnop, 
        "s2c_turnop", 
        handler(self, self._onMsgTurnCommand))

end

--一轮的命令到达
function M:_onMsgTurnCommand(cmd)
    --dump(cmd, "cmd")

    --print("命令到达", cmd.turnIndex, self._currentTurn, self._nextTurnIndex)

    local turnIndex = cmd.turnIndex
    --print(self._nextTurnIndex .. "  " .. turnIndex)

    --数据晚到，则立马进行执行
    if(self._nextTurnIndex == turnIndex and self._currentTurn >= self._nextTurnIndex) then
        self:_doCommand(cmd)
    end

    --记录最新的轮回命令索引
    if self._maxTurnIndex < turnIndex then 
        self._maxTurnIndex = turnIndex
    end

    --发生了服务器轮回大于当前轮回的情况
    -- if self._maxTurnIndex > (self._currentTurn + 1) then 
    --     assert(false, "发生了服务器轮回大于当前轮回的情况")
    -- end

    --发生了掉包情况
    -- if self._maxTurnIndex > self._nextTurnIndex then 
    --     self:_acquireTurnMsg()
    -- end

    self._commandList[turnIndex] = cmd
end

function M:addPlayer(playerList)
    for k,v in pairs(playerList) do 

        local snake = Snake:create(
            v.id, 
            10000, 
            cc.p(20, 5), 
            cc.p(1, 10), 
            Const.DIR_RIGHT, 
            Const.StepDuration)

        table.insert(self._snakeList, snake)

        self._layerMap:enterSnake(snake)
    end
end

function M:onEnter()

end

return M
