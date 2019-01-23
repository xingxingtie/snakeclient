
--在snake这里理应让他看不到任何帧同步的东西
--1 蛇头占据四个碰撞格子
--2 每100毫秒蛇头步进一个格子 每个格子8像素

local Const = require("app.const.Const")
local SnakeStage = require("app.scenes.sandtable.SnakeStage")
local M = class("SnakeData")

-- speed 像素/秒
--function M:ctor(group, mapConfig, birthIndex, map, mountPoint)
function M:ctor(mapConfig, playerinfo, map, mountPoint)
    self._mapConfig  = mapConfig
    self._playerinfo = playerinfo
    self._map        = map
    self._mountPoint = mountPoint
    
    self._die      = false
    self._head     = nil
    self._tail     = nil
    self._preIndex = nil

    self:_initUI(mapConfig, playerinfo)
    self:_initEventListener()
end

function M:_initEventListener()
    self._cmdHandler = {}
    self._cmdHandler[Const.CMD_TYPE_KEYBOARD] = handler(self, self._handleKeyboardCMD)
    self._cmdHandler[Const.CMD_TYPE_MOUSE]    = handler(self, self._handleMouseCMD)    
end

function M:_initUI(mapConfig, playerinfo)
    self._head = self:appendStage()
    local birthData = mapConfig.brithPos[playerinfo.position]
    self._head:changeDir(birthData.dir)

    local birthPos  = {
        minX = birthData.x, 
        minY = birthData.y,
        maxX = birthData.x + mapConfig.stageWidth - 1,
        maxY = birthData.y + mapConfig.stageWidth - 1,
    }
    self._head:initPos(birthPos) 
    self._map:headInto(self, birthPos)

    --增加蛇节
    if mapConfig.bodyLenth > 1 then 
        for i=2, mapConfig.bodyLenth do 
            self:appendStage()
        end    
    end
end

--处理键盘命令, 改变方向时将改变蛇头行进的速率
function M:_handleKeyboardCMD(cmd)
    local oldDir = self._head:getDir()
    local newDir = Const.KEYCODE_DIR[cmd.x]

    if oldDir <= Const.DIR_DOWN and newDir <= Const.DIR_DOWN then 
        return
    end

    if oldDir > Const.DIR_DOWN and newDir > Const.DIR_DOWN then 
        return
    end

    self._head:changeDir(newDir)
end

local closeCrashCheck = false

--更新位置
function M:_updatePosition(dt)
    if self._die then 
        return
    end

    local index, per = self._head:countRunPer(dt)

    --更新地图碰撞数据
    if self._preIndex ~= index then 
        local enterPos = self._head:getNewIntoMapPos(index)
        self._map:headInto(self, enterPos)

        local leavePos = self._tail:getNewOutMapPos(index)
        if leavePos then 
            self._map:tailLeave(self, leavePos)            
        end
        self._preIndex = index
        closeCrashCheck = true
    end

    --更新蛇节位置
    local stage = self._head
    while stage do 
        stage:updatePosition(index, per)

        stage = stage:getNextStage()
    end
end

--处理鼠标命令
function M:_handleMouseCMD()

end

--添加蛇节
function M:appendStage()
    local stage = SnakeStage:create(self._mapConfig, self._map)
        :addTo(self._mountPoint)

    if self._tail then 
        stage:initPos(self._tail:getCurMapPos())
        self._tail:setNextStage(stage)
    end
    
    stage:setPreStage(self._tail)
    self._tail = stage

    return stage
end

function M:updateTargetPos()
    if self._die then 
        return
    end

    local stage = self._head
    while stage do 
        stage:updateTargetPos()
        stage = stage:getNextStage()
    end

    self._preIndex = nil
end

function M:update(dt)
    self:_updatePosition(dt)
end

function M:doCommand(cmd)
    local handler = self._cmdHandler[cmd.cmdType]
    if handler then 
        handler(cmd)
    end
end

function M:getGroup()
    return self._playerinfo.group
end

function M:doDie()
    self._die = true
end

function M:getUserID()
    return self._playerinfo.userID
end

function M:isDie()
    return self._die
end

return M