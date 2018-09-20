--地图实时数据 用来记录地图的格子被蛇身占领情况
local M = class("MapRTData")
local Const = require("app.const.Const")

function M:ctor(line, row)
    self._line = line
    self._row  = row    
    self._map = {}
end

function M:clear()
    for i=1, line do 
        local oneLine = {}
        for j=1, row do 
            table.insert(oneLine, 0)
        end
        table.insert(self._map, oneLine)
    end
end

--是否是空地
function M:isEmpty(x, y) 
    assert(x <= self._row and x >= 0 and y <= self._line and y >= 0, string.format("MapRTData::isEmpty中x:%d, y:%d越界", x, y)) 

    return (self._map[y][x] % Const.DELTAGROUP) == 0
end

--一头扎进某个位置
function M:headIn(x, y, group)
    assert(x <= self._row and x >= 0 and y <= self._line and y >= 0, string.format("MapRTData::headin中x:%d, y:%d越界", x, y))

    if(self._map[y][x] == 0) then
        self._map[y][x] = group + 1
    end

    self._map[y][x] = self._map[y][x] + 1
end

--移出某个位置
function M:moveOut(x, y)
    assert(x <= self._row and x >= 0 and y <= self._line and y >= 0, string.format("MapRTData::tailOut中x:%d, y:%d越界", x, y))    

    local occupyNum = self._map[y][x] % Const.DELTAGROUP

    if(occupyNum == 1) then 
        self._map[y][x] = 0
    else 
        self._map[y][x] = self._map[y][x] - 1
    end
end

--是否碰撞，碰墙和撞到其它蛇身则算碰撞
function M:ifCrash(x, y, group) 
    --判断是否撞墙
    if(x <= 0 or x > self._row or y <= 0 or y > self._line) then return true end

    if(self:isEmpty(x, y)) then return false end

    local occupyNum = self._map[y][x] % Const.DELTAGROUP
    local occupyGroup = self._map[y][x] - occupyNum

    return occupyGroup == group
end

--随机生成食物点, 一次性生成多个食物点
function M:randomFood(num)

end

return M
