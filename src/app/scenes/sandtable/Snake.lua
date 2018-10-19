-- 蛇身数据

local Const = require("app.const.Const")
local M = class("SnakeData")

function M:ctor(id, group, SP, EP, dir, moveDuration)
    self._body = {}

    self._dir = 0    --蛇头方向

    self._id = id

    self._moveTime = moveDuration

    self._group = group

    self:initSnake(SP, EP, dir)
end

 --一节，蛇身由很多节组成
function M:_constructOneStage(mapX, mapY, x, y, sp)
    return {
        dataX = mapX, 
        dataY = mapY,
        x = 0,
        y = 0,
        targetX = 0,
        targetY = 0,
        sp = nil      --sp是显示对象
    }
end

--初始化蛇身  SP:头部位置 EP:尾部位置
--最初蛇身是一条直线
function M:initSnake(SP, EP, dir)
    if(SP.x == EP.x) then
        local step = (SP.y > EP.y) and -1 or 1
        for y = SP.y, EP.y, step do 
            local stage = self:_constructOneStage(SP.x, y)
            table.insert(self._body, stage)    
        end
    else
        local step = (SP.x > EP.x) and -1 or 1
        for x = SP.x, EP.x, step do 
            local stage = self:_constructOneStage(x, SP.y)
            table.insert(self._body, stage)    
        end
    end

    self._dir = dir
end

--向某个方向移动 计算蛇身所有节点的位置
function M:moveTo(dir, stageWidth, stageHeight)
    local dirStep = Const.DIR_STEP[dir]
    local preStage = nil

    local body = self:getBody()
    --print("蛇身长度", #body)
    -- for k, v in ipairs(body) do 
    --     print("move前:", v.x, v.y)
    -- end

    for k, v in ipairs(self:getBody()) do 
        if preStage then 
            v.targetX = preStage.x 
            v.targetY = preStage.y

            v.dataX = preStage.dataX
            v.dataY = preStage.dataY

            preStage = v
           
        else 
            v.targetX = v.x + dirStep.x * stageWidth
            v.targetY = v.y + dirStep.y * stageHeight

            v.dataX = v.dataX + dirStep.x
            v.dataY = v.dataY + dirStep.y

            preStage = v

            --print("蛇头起始位置:", v.x, v.y)
            --print("蛇头目标位置:", v.targetX, v.targetY, v.sp:getPosition())
        end
    end

    self._dir = dir
end

function M:update(elapse) 
    local ratio = elapse / self._moveTime

    for k, v in ipairs(self._body) do 
        local midX = v.x + (v.targetX - v.x) * ratio
        local midY = v.y + (v.targetY - v.y) * ratio

        v.sp:move(midX, midY)
    end
end

--直接跳到目标位置
function M:gotoTarget()
    for k, v in ipairs(self._body) do 
        v.sp:move(v.targetX, v.targetY)

        v.x = v.targetX
        v.y = v.targetY
    end
end

--蛇死亡，则移除所有蛇节
function M:die()
    for k, v in ipairs(self._body) do 
        v.sp:die()
    end
end

--获取蛇头位置
function M:getHead()
    return self._body[1]    
end

--获取蛇尾位置
function M:getTail()
    return self._body[#self._body]    
end

function M:getDir()
    return self._dir
end

function M:getID()
    return self._id
end

function M:getBody()
    return self._body
end

function M:getGroup()
    return self._group
end

return M