--沙盘

local LayerMap = require("app.scenes.sandtable.LayerMap")
local Const = require("app.const.Const")
local Snake = require("app.scenes.sandtable.Snake")
local SimServer = require("app.scenes.sandtable.SimServer")
local M = class("SceneSandTable", cc.Scene)

function M:ctor()
    self._commandList = {}     --命令列表
  
    self._nextTurnIndex = 0    --下一个待执行的轮
    self._maxTurnIndex  = 0    --收到的最大的轮回索引号
    self._currentTurn   = 1    --当前轮

    self._snakeList = {}
    self:_initUI()
    self:enableNodeEvents()

    self._updateElapse = 0
end

function M:_initUI()
    self._layerMap = LayerMap:create(Const.LINE, Const.ROW, Const.MapWidth, Const.MapHeight)
        :addTo(self)    

    local snake = Snake:create(1, 10000, cc.p(20, 30), cc.p(1, 30), Const.DIR_RIGHT, Const.StepDuration)
    self._snakeList[1] = snake

    local snake = Snake:create(2, 20000, cc.p(20, 10), cc.p(1, 10), Const.DIR_RIGHT, Const.StepDuration)
    self._snakeList[2] = snake

    self._layerMap:enterSnake(self._snakeList[1])
    self._layerMap:enterSnake(self._snakeList[2])

    --self._server = SimServer:create(self, self._layerMap)
end

--处理命令
function M:_doCommand(cmd)
    --dump(cmd)
    for k,v in ipairs(cmd) do

        local moved = false
        for _, userCmd in ipairs(v.cmdList) do
            local id = v.id

            if(userCmd.cmdType == Const.CMD_NONE and not moved) then 

                self._layerMap:moveSnake(id)

                moved = true

            elseif (userCmd.cmdType == Const.CMD_CHANG_DIR and not moved) then 

                self._layerMap:moveSnake(id, userCmd.cmdValue)

                moved = true
            end
        end
    end
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
    --print("一轮时间到 开始执行", self._commandList[self._nextTurnIndex])
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
    self._updateElapse = self._updateElapse + dt

    --print(dt, self._updateElapse)

    self._updateElapse = math.min(self._updateElapse, Const.StepDuration)

    self._layerMap:update(self._updateElapse)

    if not self._overTime then 
        self._layerMap:update(self._updateElapse)
    end

    if(self._updateElapse == Const.StepDuration) then 
        self._overTime = true
    end
end

--启动沙盘
function M:run()
    self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self._overtimeTurn), 
        0.1, 
        false)

    self:_doCommand({
        {id = 1, cmdList = {{cmdType = Const.CMD_NONE, cmdValue = 0}} },
        {id = 2, cmdList = {{cmdType = Const.CMD_NONE, cmdValue = 0}} },
    })

    --启用帧事件
    self:scheduleUpdate(handler(self, self._update))

    --self._server:run()
end

--一轮的命令到达
function M:onMsgTurnCommand(cmd)
    --print("命令到达", cmd.turnIndex, self._currentTurn, self._nextTurnIndex)

    local turnIndex = cmd.turnIndex

    --数据晚到，则立马进行执行
    if(self._nextTurnIndex == turnIndex and self._currentTurn > self._nextTurnIndex) then
        self:_doCommand(cmd)
    end

    --记录最新的轮回命令索引
    if self._maxTurnIndex < turnIndex then 
        self._maxTurnIndex = turnIndex
    end

    --发生了服务器轮回大于当前轮回的情况
    if self._maxTurnIndex > self._currentTurn then 
        assert(false, "发生了服务器轮回大于当前轮回的情况")
    end

    --发生了掉包情况
    if self._maxTurnIndex > self._nextTurnIndex then 
        self:_acquireTurnMsg()
    end

    self._commandList[turnIndex] = cmd
end

function M:onEnter()
    self:run()
end

return M
