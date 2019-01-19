
--在snake这里理应让他看不到任何帧同步的东西
--1 蛇头占据四个碰撞格子
--2 每100毫秒蛇头步进一个格子 每个格子8像素

local Const = require("app.const.Const")
local SnakeStage = require("app.scenes.sandtable.SnakeStage")
local M = class("SnakeData")

-- speed 像素/秒
function M:ctor(group, headp, tailp, speed, map, mountPoint)
    self._group = group
    self._speed = speed
    self._map   = map
    self._mountPoint = mountPoint
    self._passPosArr = {}
    
    self._cmdHandler = {}
    self._cmdHandler[Const.CMD_TYPE_KEYBOARD] = handler(self, self._handleKeyboardCMD)
    self._cmdHandler[Const.CMD_TYPE_MOUSE]    = handler(self, self._handleMouseCMD)

    self._head = nil
    self._tail = nil
    self:_initUI(headp, tailp, speed)
end

function M:_initUI(headp, tailp, speed, v)
    self._head = SnakeStage:create(
        self._mountPoint,
        self._map:getTileWidth(),
        self._map:getTileHeight(),
        speed,
        true) 
    self._head:setPosition(headp.x, headp.y) 
    self._tail = self._head

    local pre = self._head 
    for i=1, 5 do 
        local next = SnakeStage:create(
            self._mountPoint,
            self._map:getTileWidth(),
            self._map:getTileHeight(),
            speed,
            false)         
        next:setPosition(headp.x, headp.y) 
        pre:setNextStage(next)
        pre = next
    end

    --竖着的蛇
    if headp.x == tailp.x then 
        local cmd =  {x = (headp.y > tailp.y) and Const.keyCode_UP or Const.keyCode_DOWN}
        self:_handleKeyboardCMD(cmd)
    elseif headp.y == tailp.y then 
        local cmd =  {x = (headp.x > tailp.x) and Const.keyCode_RIGHT or Const.keyCode_LEFT}
        self:_handleKeyboardCMD(cmd)
    end
end

--处理键盘命令, 改变方向时将改变蛇头行进的速率
function M:_handleKeyboardCMD(cmd)
    local passPos = cc.p(self._head:getPosition())

    if (cmd.x == Const.keyCode_UP) then
        passPos.y = passPos.y + 8
    elseif (cmd.x == Const.keyCode_DOWN) then 
        passPos.y = passPos.y - 8
    elseif (cmd.x == Const.keyCode_LEFT) then 
        passPos.x = passPos.x - 8
    elseif (cmd.x == Const.keyCode_RIGHT) then
        passPos.x = passPos.x + 8
    end

    self._head:passKeyPos(passPos)
end

--更新位置
function M:_updatePosition(dt)
    local stage = self._head
    while stage do 
        stage:update(dt)
        stage = stage:getNextStage()
    end
end

--处理鼠标命令
function M:_handleMouseCMD()

end

--添加蛇节
function M:appendStage()
    local next = SnakeStage:create(
        self._mountPoint,
        self._map:getTileWidth(),
        self._map:getTileHeight(),
        speed,
        false)  

    next:setPosition(self._tail:getPosition())

    self._tail:setNextStage(next)
    next:setPreStage(self._tail)
    self._tail = next
end

function M:recordKeyPos()
    local stage = self._head
    while stage do 
        table.insert(self._passPosArr, stage:recordKeyPos())
        stage = stage:getNextStage()
    end
end

function M:passKeyPos()
    local index = 1
    local stage = self._head:getNextStage()
    while stage do 
        stage:passKeyPos(self._passPosArr[index])
        stage = stage:getNextStage()
        index = index + 1
    end 
    self._passPosArr = {}
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

return M