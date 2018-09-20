--模拟服务器

local M = class("SimServer")
local Const = require("app.const.Const")

function M:ctor(sandTable, touchLayer)
    self._sandTable = sandTable
    self._turnIndex = 1                     --当前轮回索引
    self._curTurnCommand = {user = {}}      --当前轮多个玩家命令集合
    self._commandHistory = {}               --命令历史列表

    self._usersID = {1, 2}

    self:_addKeyBoardListener(touchLayer)
end

function M:_addKeyBoardListener(touchLayer)

    local lookTable = {
        [28] = Const.DIR_UP,
        [29] = Const.DIR_DOWN,
        [26] = Const.DIR_LEFT,
        [27] = Const.DIR_RIGHT,
    }

    local onKeyReleased = function ( keycode, event )
        if(lookTable[keycode]) then 
            local cmd = {
                id = 1,
                cmdList = {{cmdType = Const.CMD_CHANG_DIR, cmdValue = lookTable[keycode]}}
            }
            self:onMsgCommand(cmd)                
            local cmd = {
                id = 2,
                cmdList = {{cmdType = Const.CMD_CHANG_DIR, cmdValue = lookTable[keycode]}}
            }

            self:onMsgCommand(cmd)    
        end
    end
    
    --28 29 26 27

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
    self.__key_event_handle__ = listener
end

--构造空闲命令
function M:_constructIdleCmd(userID)
    return {
        id = userID,
        cmdList = {{cmdType = Const.CMD_NONE, cmdValue = 0}}
    }
end

--将B合并到A
function M:_combineCmd(cmdA, cmdB)
    for k,v in ipairs(cmdB.cmdList) do 
        table.insert(cmdA.cmdList, v)
    end
end

function M:_overtimeFirstTurn()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)

    self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self._overtimeIdle), 
        0.1, 
        false)
    --print("_overtimeFirstTurn")

    self:_overtimeIdle()
end 

--发送当前轮命令
function M:_sendCurTurnCommand()
    self._curTurnCommand.turnIndex = self._turnIndex
    self._sandTable:onMsgTurnCommand(self._curTurnCommand)
    self._turnIndex = self._turnIndex + 1

    table.insert(self._commandHistory, self._curTurnCommand)

    self._curTurnCommand = {user = {}}
end

--到达触发idle的时间
function M:_overtimeIdle()
    for k,v in ipairs(self._usersID) do
        if not self._curTurnCommand.user[v] then
            table.insert(self._curTurnCommand, self:_constructIdleCmd(v))
            self._curTurnCommand.user[v] = #self._curTurnCommand + 1
        end
    end

    --发包
    self:_sendCurTurnCommand()
end

--收到单个玩家命令
function M:onMsgCommand(cmd)
    local cmdIndex = self._curTurnCommand.user[cmd.id]

    --已经有了则合并 按规则不会合并
    if cmdIndex then
        self:_combineCmd(self._curTurnCommand[cmdIndex], cmd)
        print("触发了合并")
    else
        table.insert(self._curTurnCommand, cmd)
        self._curTurnCommand.user[cmd.id] = #self._curTurnCommand
    end
end

function M:run()
    self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self._overtimeFirstTurn), 
        0.05, 
        false)
end

return M

