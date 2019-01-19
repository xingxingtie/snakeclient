-- 地图配置文档
local M = {}

-- 荒原
M.WASTE_LAND = {
    bg          = "map.jpg",
    width       = 1280,
    height      = 720,
    row         = 80,
    stageLength = 5,
}

M.WASTE_LAND.line       = M.WASTE_LAND.height  / M.WASTE_LAND.width * M.WASTE_LAND.row

return M
