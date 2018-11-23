--被控制的角色

local M = class("TcpTest", cc.Node)

local SPEED = 100 --每秒位移

function M:ctor()
    self._startTime = 0
    self._duration = 0
    self._moving = false

    self._originPosition = cc.p(0, 0)
    self._targetPosition = cc.p(0, 0)
    self._commandRegister = {}
    self._curCommand = nil

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
    self._originPosition.x, self._originPosition.y = self:getPosition()

    self._startTime = 0
    self._duration = dt
end


--更新渲染帧
function M:update(dt)
    
    if not self._moving then 
        return
    end

    self._startTime = self._startTime + dt
    
    local ratio = self._startTime / self._duration
    ratio = ratio > 1 and 1 or ratio

    --print(ratio, os.clock())

    self:setPosition(
        self._originPosition.x + (self._targetPosition.x - self._originPosition.x) * ratio, 
        self._originPosition.y + (self._targetPosition.y - self._originPosition.y) * ratio)
end

--更新逻辑帧
function M:updateLogic(dt)
    local command = self._curCommand

    if not command then 
        self:setPosition(self._targetPosition)
        self._moving = false
        return
    end

    self:_beginDoCommand(dt)

    local offset = SPEED * dt

    if (command == 28) then 
        self._targetPosition.y = self._targetPosition.y + offset
    elseif (command == 29) then 
        self._targetPosition.y = self._targetPosition.y - offset
    elseif (command == 26) then 
        self._targetPosition.x = self._targetPosition.x - offset
    elseif (command == 27) then 
        self._targetPosition.x = self._targetPosition.x + offset
    end

    self._moving = true

    --self._curCommand = false
end

--执行命令
function M:onCommand(command, time)
    if command then 
       self._curCommand = command 

       --print("设置为", command, os.clock())
    end

    --print("耗时", os.clock() - time)
end

return M
