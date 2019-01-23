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
local Const = require("app.const.Const")
local M = class("SnakeStage", cc.Node)

local tileWidth   = nil
local tileHeight  = nil
local speed       = nil
local stageWidth  = nil    --蛇节宽度
local perStep     = nil
local newPos      = {}

function M:ctor(mapConfig, map)
    self._mapConfig = mapConfig
    self:_flushConfig(mapConfig)

    self._preStage         = preStage  --上一个蛇节
    self._nextStage        = preStage  --下一个蛇节

    self._map              = map
    self._dir              = nil
    self._curStartIndex    = 0

    self._mapTargetArr     = {}    --地图目标点
    self._pixelTargetArr   = {}    --像素目标点
    self._preIndex         = nil

    self:_initUI()
end

function M:_flushConfig(mapConfig)
    tileWidth   = mapConfig.tileWidth
    tileHeight  = mapConfig.tileHeight
    speed       = mapConfig.speed
    stageWidth  = mapConfig.stageWidth
    perStep     = 1 / speed
end

function M:_initUI()
    local sp = display.newSprite("stage.png")
        :addTo(self)

    local size = sp:getContentSize()
    sp:setScaleX(stageWidth * tileWidth  / size.width)
    sp:setScaleY(stageWidth * tileHeight / size.height)
end

--格子位置转换成像素位置
function M:_mapPosToPixelPos(pos)
    local startX, startY = self._map:mapXY2PixelXY(pos.minX, pos.minY)
    local endX, endY     = self._map:mapXY2PixelXY(pos.maxX, pos.maxY)

    return cc.p(
        (startX + endX) / 2,
        (startY + endY) / 2)
end

--初始化位置
function M:initPos(pos)
    pos.dir = nil
    local pixelPos = self:_mapPosToPixelPos(pos)
    self:setPosition(pixelPos.x, pixelPos.y)

    for i=1, stageWidth + speed do
        self._mapTargetArr[i]   = pos
        self._pixelTargetArr[i] = pixelPos
    end

    self._curStartIndex = 1
end

--更新蛇头目标位置
function M:_updateHeadTargetPos()
    local endIndex = #self._mapTargetArr - stageWidth
    for i=1, stageWidth do 
        self._mapTargetArr[i]   = self._mapTargetArr[endIndex + i]
        self._pixelTargetArr[i] = self._pixelTargetArr[endIndex + i]    
    end

    local dir   = self._dir
    local stepX = Const.DIR_STEP[dir].x
    local stepY = Const.DIR_STEP[dir].y
    local lastPos = self._mapTargetArr[stageWidth]

    for i=1, speed do
        local pos = {
            minX = lastPos.minX + stepX,
            minY = lastPos.minY + stepY,
            maxX = lastPos.maxX + stepX,
            maxY = lastPos.maxY + stepY,
            dir  = dir,
        }

        self._mapTargetArr[stageWidth + i] = pos;
        self._pixelTargetArr[stageWidth + i] = self:_mapPosToPixelPos(pos);

        lastPos = pos
    end
end

-- 更新蛇节目标位置 复制上一个蛇节已经计算好的位置
function M:_updateStageTargetPos()
    local endIndex = #self._mapTargetArr - stageWidth
    for i=1, stageWidth do 
        self._mapTargetArr[i]   = self._mapTargetArr[endIndex + i]
        self._pixelTargetArr[i] = self._pixelTargetArr[endIndex + i]    
    end

    local targetArr = self._preStage:getPixelTargetArr()
    local mapArr = self._preStage:getMapTargetArr()
    for i=1, speed do
       self._mapTargetArr[i + stageWidth]   = mapArr[i]
       self._pixelTargetArr[i + stageWidth] = targetArr[i]
    end
end

--更新目标位置
function M:updateTargetPos()
    if not self._preStage then 
        self:_updateHeadTargetPos()
    else 
        self:_updateStageTargetPos()
    end

    self._preIndex = nil
end

--获取蛇头新进入的位置
function M:getNewIntoMapPos(index)
    local targetPos = self._mapTargetArr[index]
    newPos.minX = targetPos.minX
    newPos.maxX = targetPos.maxX
    newPos.minY = targetPos.minY
    newPos.maxY = targetPos.maxY

    if self._dir == Const.DIR_RIGHT then 
        newPos.minX = newPos.maxX
    elseif self._dir == Const.DIR_LEFT then 
        newPos.maxX = newPos.minX
    elseif self._dir == Const.DIR_UP then 
        newPos.minY = newPos.maxY
    elseif self._dir == Const.DIR_DOWN then
        newPos.maxY = newPos.minY
    end

    return newPos
end

--获取移出的格子
function M:getNewOutMapPos(index)
    local targetPos = self._mapTargetArr[index]
    newPos.minX = targetPos.minX
    newPos.maxX = targetPos.maxX
    newPos.minY = targetPos.minY
    newPos.maxY = targetPos.maxY

    local dir = targetPos.dir
    --print("dir--", dir)
    if dir == nil then 
        return nil
    end

    if dir == Const.DIR_RIGHT then 
        newPos.maxX = newPos.minX
    elseif dir == Const.DIR_LEFT then 
        newPos.minX = newPos.maxX
    elseif dir == Const.DIR_UP then 
        newPos.maxY = newPos.minY
    elseif dir == Const.DIR_DOWN then
        newPos.minY = newPos.maxY
    end

    return newPos
end

-- function M:headInto(snake, index)
--     if self._preIndex ~= index then 
--         local newPos = self:getNewIntoMapPos(index)
--         self._map:headInto(snake, newPos)
--         self._preIndex = index
--     end
-- end

-- function M:tailLeave(snake, index)
--     if self._preIndex ~= index then 
--         local newPos = self:getNewOutMapPos(index)
--         if newPos then 
--             self._map:tailLeave(snake, newPos)
--         end
--         self._preIndex = index
--     end
-- end

function M:countRunPer(curPer)
    --寻找目标点 
    local endIndex   = stageWidth + 1
    local prePer     = 0
    while (prePer + perStep) < curPer do 
        prePer = prePer + perStep
        endIndex  = endIndex + 1
    end

    curPer = (curPer - prePer) / perStep

    return endIndex, curPer
end

--更新位置
function M:updatePosition(index, curPer)
    local startPos   = self._pixelTargetArr[index - 1]
    local endPos     = self._pixelTargetArr[index]

    self._curStartIndex = index - 1

    self:setPosition(
        startPos.x + (endPos.x - startPos.x) * curPer,
        startPos.y + (endPos.y - startPos.y) * curPer)
end

function M:changeDir(dir)
    self._dir = dir
end

function M:getDir()
    return self._dir
end

--获取当前地图位置
function M:getCurMapPos()
    return self._mapTargetArr[self._curStartIndex]
end

function M:getMapTargetArr()
    return self._mapTargetArr
end

function M:getPixelTargetArr()
    return self._pixelTargetArr
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

function M:getTargetPosition()

end

function M:die()
    self:removeSelf()
end

return M

