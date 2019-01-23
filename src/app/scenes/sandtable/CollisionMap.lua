-- 碰撞数据
local Const = require("app.const.Const")
local Food = require("app.scenes.sandtable.Food")
local M = class("Collision")

local line       = nil
local row        = nil
local tileWidth  = nil
local tileHeight = nil
local maxFoodNum = nil
local repeatNum  = nil

function M:ctor(mapConfig, foodMountPoint)  --FriendRuleBase
    self._mapConfig      = mapConfig
    self:_flushConfig(mapConfig)
    self._foodMountPoint = foodMountPoint
    self._map = {}
    self._idleList   = {}

    self._totalFlag = 0
    self._curFoodNum = 0        --当前食物数
    self:_initMap(mapConfig)    --没有被占据的格子表
    --self._maxFoodNum = 10     --最大食物数
end

function M:_flushConfig(mapConfig)
    line = mapConfig.line
    row  = mapConfig.row
    tileWidth  = mapConfig.tileWidth
    tileHeight = mapConfig.tileHeight
    maxFoodNum = mapConfig.maxFoodNum
    repeatNum  = mapConfig.repeatNum
end

--构造二维数组  数组中的每个元素记录的是某个队伍的蛇身占的次数
function M:_initMap(mapConfig)
    for y = 1, line do
        local oneLine = {}
        for x = 1, row do 
            oneLine[x] = {num = 0, group = 0, x = x, y = y}
        end
        self._map[y] = oneLine
    end

    --初始化空间
    local gridNum = line * row
    for i=1, gridNum do
       self._idleList[#self._idleList + 1] = nil      
    end
end

--像素xy转换成mapxy
function M:pixelXY2mapXY(px, py)
    X = math.floor(px / tileWidth)
    Y = math.floor(py / tileHeight)

    return X, Y
end

--获取某个格子的中间的像素位置
function M:mapXY2PixelXY(mapx, mapy)
    local X = mapx * tileWidth  - tileWidth  / 2
    local Y = mapy * tileHeight - tileHeight / 2
    
    return X, Y
end

--是否越界
function M:_isOverBound(rect)
    return rect.minX < 1 or 
       rect.maxX > row or 
       rect.minY < 1 or 
       rect.maxY > line
end

--是否碰撞到障碍物，碰到了之后返回碰到障碍物的x，y坐标
function M:_isCrash(group, rect)
    local map = self._map

    local crashCheck = function(X, Y) 
        local data = map[Y][X]
        local originGroup = data.group

        --空地
        if originGroup == 0 then 
            return false
        end

        --容纳不下了
        if data.num >= repeatNum then
            return true
        end

        --还可以容纳但是被别的队伍占了
        if originGroup ~= group then 
            return true
        end

        return false
    end

    for x = rect.minX, rect.maxX do 
        for y = rect.minY, rect.maxY do 
            if crashCheck(x, y) then 
                return true, x, y
            end
        end
    end

    return false
end

--减少某个位置的一个通路数据
function M:_decGroupNum(group, rect)
    for x = rect.minX, rect.maxX do 
        for y = rect.minY, rect.maxY do 
            local data = self._map[y][x] 
            local num = data.num - 1
            data.num = num
            if num == 0 then 
                data.group = 0
            end           

            self._totalFlag = self._totalFlag - 1
        end
    end
end

--增加某个位置的一个通路数据
function M:_incGroupNum(group, rect)
    for x = rect.minX, rect.maxX do 
        for y = rect.minY, rect.maxY do 
            local data = self._map[y][x] 
            local num = data.num + 1
            if num == 1 then 
                data.group = group
            end
            data.num = num

            self._totalFlag = self._totalFlag + 1
        end
    end
end

--处理蛇死亡  清理碰撞数据
function M:_handleSnakeDie(snake)
    snake:doDie()
    -- for body in ipairs(snake:getBody()) do 
    --     local x, y = body:getMapXY()
    --     self:_decGroupNum(x, y)
    -- end
end

--蛇头进入
function M:headInto(snake, rect)

    if self:_isOverBound(rect) then 
        self:_handleSnakeDie(snake)
        return
    end

    local group = snake:getGroup()
    local isCrash, crashX, crashY = self:_isCrash(group, rect)

    if isCrash then 
        local crashGroup = self._map[crashY][crashX].group
        if crashGroup == Const.GROUP_FOOD then 
            self:removeFood(crashX, crashY)
            snake:appendStage()
            self:_incGroupNum(group, rect) 
        else 
            self:_handleSnakeDie(snake)
        end
    else
        self:_incGroupNum(group, rect) 
    end

    --print("进 占据位置", self._totalFlag)
end

--蛇尾离开
function M:tailLeave(snake, rect)
    local group = snake:getGroup()
    self:_decGroupNum(group, rect)

    --print("出 占据位置", self._totalFlag)
end

function M:update(dt)
    if self._curFoodNum < maxFoodNum then 
        self:createFood()
    end
end

function M:removeFood(X, Y)
    local data = self._map[Y][X]
    data.group = 0
    assert(data.food, "找不到食物")

    data.food:removeFromParent()
    data.food = nil

    self._curFoodNum = self._curFoodNum - 1
end

function M:addFood(X, Y)
    local data = self._map[Y][X]

    assert(not data.food, "食物生成点位置原来就已经有了食物")

    --增加食物
    data.food = Food:create(tileWidth, tileHeight)
        :addTo(self._foodMountPoint)
        :move(self:mapXY2PixelXY(X, Y))

    data.group = Const.GROUP_FOOD

    self._curFoodNum = self._curFoodNum + 1

    return data.food
end

--产生食物
function M:createFood()
    local idleList = self._idleList
    local map = self._map
    local count = 0

    for X = 1, row do 
        for Y = 1, line do 
            local data = map[Y][X]
            if data.group == 0 then 
                count = count + 1
                idleList[count] = data
            end
        end
    end

    if(count == 0) then 
        return
    end

    local target = math.max(1, math.ceil(math.random() * count))
    local data = idleList[target]

    self:addFood(data.x, data.y)
end

return M