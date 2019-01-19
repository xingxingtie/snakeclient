--[[
    数学公式：
    L： 蛇节长度, 每个蛇节在移动了蛇节的长度后就必须：1--将当前位置设定为要传递给下一个蛇节的目标位置 2-将前一个蛇节的位置更新为自己的目标位置 
    V:  蛇速，每回合移动的格子数；
    M:  格子长度；

    V 是 M的整数倍
    L 是 M的整数倍

    1 一回合开始前计算每一个蛇节要经过的格子，一回合中这个蛇节将必定走完这些格子。
    2 当前蛇节要走的格子，是通过上一个蛇节传递下来的。
]]

-- 蛇节
-- 蛇节最终的位置受惯性向量和速度向量的影响  
local M = class("SnakeStage", cc.Node)

--speed是格子的个数
function M:ctor(mountPoint, width, height, speed, isHead)
    self:addTo(mountPoint)

    self:_initUI(width, height, isHead)

    self._preStage         = preStage
    self._nextStage        = preStage
    self._targetPos        = nil
    self._speed            = speed
    self._velocity         = cc.p(0, 0) --速度向量

    self._keyPos      = nil
    self._targetPos   = nil

    self._mapStart    = nil       --蛇节所在格子位置
    self._mapTarget   = nil       --蛇节所在格子位置

    self._pixelStart  = nil       --开始位置
    self._pixelTarget = nil       --目标位置

    self._durationTime = 0           --移动总时间
    self._curTime      = 0           --移动当前时间
end

function M:_initUI(width, height, isHead)
    self._isHead = isHead

    sp = display.newSprite("stage.png")
        :addTo(self)
    local size = sp:getContentSize()

    sp:setScaleX(width  / size.width)
    sp:setScaleY(height / size.height)

    -- if isHead then 
    --     local sp = display.newSprite("head.png")
    --         :addTo(self)
    --     sp:setAnchorPoint(cc.p(323/723, 282/375))
    -- else 
    --     sp = display.newSprite("stage.png")
    --         :addTo(self)
    --     local size = sp:getContentSize()

    --     sp:setScaleX(width  * 2 / size.width)
    --     sp:setScaleY(height * 2 / size.height)
    -- end
end

--记录关键位置，蛇身的其它节以后会经历这个位置
function M:recordKeyPos()
    return cc.p(self:getPosition())
end

--更新目标位置
--对于蛇头 直接跳到下一个速度到达的位置
--对于蛇节 取用上一个蛇节的关键位置
function M:updateTargetPos()
    if not self._preStage then 
        self._mapStart    = self._mapTarget
        self._mapTarget.x = self._velocity.x
        self._mapTarget.x = self._velocity.y
    else 
        self._mapStart  = self._mapTarget
        self._mapTarget = self._preStage:getKeyPos()
    end
end

--生成关键位置
function M:generateKeyPos()
    self._keyPos = self._targetPos
end

--分发位置,迅速设定蛇身各节的位置
function M:passKeyPos(passPos)
    if not passPos then 
        return 
    end

    self._targetPos = passPos
    local X,Y = self:getPosition()

    if X == passPos.x and Y == passPos.y then 
        return
    end

    --设置速度即可
    local diffX = passPos.x - X
    local diffY = passPos.y - Y

    --横着走
    if math.abs(diffX) > math.abs(diffY) then 
        self._velocity.y = 0
        self._velocity.x = diffX > 0 and self._speed or -self._speed
    else 
        self._velocity.x = 0
        self._velocity.y = diffY > 0 and self._speed or -self._speed
    end

    --print("设施pass", os.clock(), X, Y, passPos.x, passPos.y, self._velocity.x, self._velocity.y)
end

function M:setNextStage(stage)
    self._nextStage = stage
end

function M:getNextStage()
    return self._nextStage
end

function M:setPreStage(stage)
    self._preStage = stage
end

function M:getPreState()
    return self._preStage
end

function M:getKeyPos()
    return self.__keyPos
end

--1--将当前位置设定为要传递给下一个蛇节的目标位置 2-将前一个蛇节的位置更新为自己的目标位置

--更新位置
function M:update(dt)
    local stepX = self._velocity.x * dt
    local stepY = self._velocity.y * dt

    local posX, posY = self:getPosition()
    self:setPosition(posX + stepX, posY + stepY)
end

function M:getTargetPosition()

end

function M:die()
    self:removeSelf()
end

return M

