-- 碰撞数据
local M = class("Collision")

--line 地图行数
--row  地图列数
--地图像素宽度 width
--地图像素高度 height
function M:ctor(row, line, width, height)
    self._map = {}
    self._line = line
    self._row = row

    self._width = width
    self._height = height

    self._tileWidth  = width / row 
    self._tileHeight = height / line 

    print("砖块长宽", width, height, line, row, self._tileWidth, self._tileHeight)

    self:_initMap(line, row)
end

--构造二维数组  数组中的每个元素记录的是某个队伍的蛇身占的次数
function M:_initMap(line, row)
    for l = 1, line do
        local oneLine = {}
        for r = 1, row do 
            oneLine[r] = {num = 0, group = 0}
        end
        self._map[l] = oneLine
    end
end

--像素xy转换成mapxy
function M:pixelXY2mapXY(px, py)
    X = math.ceil(px / self._tileWidth)
    Y = math.ceil(py / self._tileHeight)

    return X, Y
end

--将xy坐标对齐格子的中心位置
function M:alignPixelXY(X, Y)
    self:mapXY2PixelXY(pixelXY2mapXY(X, Y))
end

--获取某个格子的中间的像素位置
function M:mapXY2PixelXY(mapx, mapy)
    local X = mapx * self._tileWidth  - self._tileWidth  / 2
    local Y = mapy * self._tileHeight - self._tileHeight / 2
    
    return X, Y
end

--是否撞车
function M:_isCrash(group, x, y)
    --如果越界则算撞车
    if x < 1 or x > self._line or y < 1 or y > self._row then 
        return true
    end

    local originGroup = self._map[y][x];

    if originGroup ~= 0 and originGroup ~= group then
        return true
    end

    return false
end

--减少某个位置的一个通路数据
function M:_decGroupNum(group, x, y)
    local num = self._map[y][x].num
    num = num - 1

    self._map[y][x].num = num
    if num == 0 then 
        self._map[y][x].group = 0
    end
end

--增加某个位置的一个通路数据
function M:_incGroupNum(group, x, y)
    local num = self._map[y][x].num
    if num == 0 then 
        self._map[y][x].group = group
    end

    self._map[y][x].num = num + 1
end

--处理蛇死亡  清理碰撞数据
function M:_handleSnakeDie(snake)
    snake:die()

    for body in ipairs(snake:getBody()) do 
        local x, y = body:getMapXY()
        self:_decGroupNum(x, y)
    end
end

--蛇头进入
function M:headInto(snake, x, y)
    local group = snake:getGroup()

    if self:_isCrash(group, x, y) then 
        self:_handleSnakeDie(snake)
        return false
    else
        self:_incGroupNum(group, x, y) 
        return true   
    end
end

--蛇尾离开
function M:tailLeave(snake, x, y)
    local group = snake:getGroup()

    self:_decGroupNum(group, x, y)
end

--获取砖块宽度
function M:getTileWidth()
    return self._tileWidth
end

--获取砖块高度
function M:getTileHeight()
    return self._tileHeight
end

return M