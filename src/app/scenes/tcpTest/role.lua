--被控制的角色

local M = class("TcpTest", cc.Node)

local SPEED = 80 --每秒位移

function M:ctor()
    self._startTime = 0
    self._duration = 0
    self._moving = false

    self._originPosition = cc.p(0, 0)
    self._targetPosition = cc.p(0, 0)
    self._commandRegister = {}

    self._curCommand = nil
    self._curTurnIndex = nil

    self:_initUI()
end

function M:_initUI()
    self._targetPosition.x = display.cx
    self._targetPosition.y = display.cy

    self:setPosition(self._targetPosition)

    local node = display.newSprite("head.jpg")
        :addTo(self)
    node:setScale(0.3)
end

function M:_beginDoCommand(dt)
    self:setPosition(self._targetPosition)

    self._originPosition.x = self._targetPosition.x
    self._originPosition.y = self._targetPosition.y

    self._startTime = 0
    self._duration = dt
end


--更新渲染帧 dt是秒
function M:update(dt)
    if not self._moving then
        return
    end

    self._startTime = self._startTime + dt
    
    local ratio = math.min(
        self._startTime / self._duration * 1000,
        1)

    self:setPosition(
        self._originPosition.x + (self._targetPosition.x - self._originPosition.x) * ratio, 
        self._originPosition.y + (self._targetPosition.y - self._originPosition.y) * ratio)
end

--执行命令
function M:onCommand(command, dt, turnIndex)
    if self._curTurnIndex == turnIndex then
        return
    end

    if command and (command == 28 or command == 29 or command == 26 or command == 27) then
        self._curCommand = command
    else 
        command = self._curCommand
    end

    self._curTurnIndex = turnIndex    

    self:_beginDoCommand(dt)

    local offset = SPEED * dt / 1000

    if (command == 28) then 
        self._targetPosition.y = self._targetPosition.y + offset
        self._moving = true
    elseif (command == 29) then 
        self._targetPosition.y = self._targetPosition.y - offset
        self._moving = true
    elseif (command == 26) then 
        self._targetPosition.x = self._targetPosition.x - offset
        self._moving = true
    elseif (command == 27) then 
        self._targetPosition.x = self._targetPosition.x + offset
        self._moving = true
    end
end

function M:getTurnIndex() 
    return self._curTurnIndex
end

return M
