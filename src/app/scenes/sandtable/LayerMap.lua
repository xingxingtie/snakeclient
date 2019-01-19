--地图层
--地图被隐形的分为一个一个的格子，蛇每次前进一步则占据一个格子，
--一个格子的占据并非在一帧内完成，为了表现平滑会经历多帧蛇头才会占据格子

local SnakeStage = require("app.scenes.sandtable.SnakeStage")
local M = class("LayerMap", cc.Layer)

function M:ctor(line, row, mapWidth, mapHeight)
    self._line = line
    self._row = row
    self._mapWidth = mapWidth
    self._mapHeight = mapHeight

    self._tileWidth  = mapWidth / row 
    self._tileHeight = mapHeight / line 

    self._mapRTData = MapRTData:create()

    self._snakeList = {}
    self:_initUI()
end

function M:_initUI()
    local bg = display.newSprite("map.jpg")
        :addTo(self)
        :move(display.cx, display.cy)
    local scale = display.width / bg:getContentSize().width
    bg:setScale(scale)
end

--获取地图像素坐标
function M:_dataPosToMapPos(dataX, dataY)
    local X = dataX * self._tileWidth  - self._tileWidth  / 2
    local Y = dataY * self._tileHeight - self._tileHeight / 2
    
    return X, Y
end

--渲染一条蛇
function M:_renderSnake(snake)
    local body = snake:getBody()

    for k, v in ipairs(body) do 
        v.sp = SnakeStage:create(nil, self, self._tileWidth, self._tileHeight)
        v.x, v.y = self:_dataPosToMapPos(v.dataX, v.dataY)
        v.targetX, v.targetY = v.x, v.y
        v.sp:move(v.x, v.y)
    end

    local body = snake:getBody()
end

--放入一条蛇,蛇新加入时没有显示对象需要构造
function M:enterSnake(snake)
    --print("蛇进入:" .. snake:getID())

    self:_renderSnake(snake)

    self._snakeList[snake:getID()] = snake
end

--移动蛇 在这个点进行碰撞检测
function M:moveSnake(snakeID, dir)
    --print("更新蛇！！！！！！！！！！！！！！！！")
    local snake = self._snakeList[snakeID]

    dir = dir or snake:getDir()

    snake:gotoTarget()
    snake:moveTo(dir, self._tileWidth, self._tileHeight)

    -- local head = snake:getHead()
    -- --如果碰撞则整条蛇死掉
    -- if(self._mapRTData:ifCrash(head.dataX, head.dataY)) then 
    --     local body = snake:getBody()
    --     for k, v in ipairs(body) do 
    --         self._mapRTData:moveOut(v.dataX, v.dataY)
    --     end

    --     snake:die()
    -- else
    --     local tail = snake:getTail()
    --     self._mapRTData:headIn(head.dataX, head.dataY, snake:getGroup())
    --     self._mapRTData:moveOut(tail.dataX, tail.dataY)
    -- end

    --self._mapRTData
end 

--精准时钟来移动蛇
function M:update(elapse)
    for k, v in pairs(self._snakeList) do
        v:update(elapse)
    end
end
        
return M


