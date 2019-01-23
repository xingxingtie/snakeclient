local Const = require("app.const.Const")

-- 地图配置文档
local M = {}

-- 荒原------------------------------------------------------------------------------------------------
M.WASTE_LAND = {
    bg          = "map.jpg",
    width       = 1280,
    height      = 720,
    row         = 80,
    stageLength = 5,
    speed       = 1,   --每回合走的格子数
    stageWidth  = 1,   --没个蛇节长或宽所占的格子数
    maxFoodNum  = 20,  --食物最大个数
    repeatNum   = 1,   --每个格子最大的占据个数
    bodyLenth   = 10,  --蛇身长度

    brithPos    = {    --出生点   
        {x = 1, y = 20, dir = Const.DIR_RIGHT},
        {x = 1, y = 22, dir = Const.DIR_RIGHT},
        {x = 1, y = 24, dir = Const.DIR_RIGHT},
        {x = 1, y = 26, dir = Const.DIR_RIGHT},
        {x = 1, y = 28, dir = Const.DIR_RIGHT},

        {x = 160, y = 20, dir = Const.DIR_LEFT},
        {x = 160, y = 22, dir = Const.DIR_LEFT},
        {x = 160, y = 24, dir = Const.DIR_LEFT},
        {x = 160, y = 26, dir = Const.DIR_LEFT},
        {x = 160, y = 28, dir = Const.DIR_LEFT},
    },  
}

M.WASTE_LAND.line            = math.floor(M.WASTE_LAND.height / M.WASTE_LAND.width * M.WASTE_LAND.row)
M.WASTE_LAND.tileWidth       = math.floor(M.WASTE_LAND.width  / M.WASTE_LAND.row)
M.WASTE_LAND.tileHeight      = math.floor(M.WASTE_LAND.height / M.WASTE_LAND.line)

--丛林------------------------------------------------------------------------------------------------

return M
