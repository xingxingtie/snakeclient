local M = {}

M.DELTAGROUP = 10000   --队伍放大因子

M.GROUP_FOOD = 100     --食物

M.keyCode_UP = 28
M.keyCode_DOWN = 29
M.keyCode_LEFT = 26
M.keyCode_RIGHT = 27

M.DIR_UP    = 1
M.DIR_DOWN  = 2
M.DIR_LEFT  = 3
M.DIR_RIGHT = 4

M.KEYCODE_DIR = {
    [M.keyCode_UP]   =  M.DIR_UP,
    [M.keyCode_DOWN] =  M.DIR_DOWN,
    [M.keyCode_LEFT] =  M.DIR_LEFT,
    [M.keyCode_RIGHT]=  M.DIR_RIGHT,
}

M.DIR_STEP = {
    [M.DIR_UP] =    {x = 0,  y = 1},
    [M.DIR_DOWN] =  {x = 0,  y = -1},
    [M.DIR_LEFT] =  {x = -1, y = 0},
    [M.DIR_RIGHT] = {x = 1,  y = 0},
}

M.CMD_NONE      = 0    --无命令
M.CMD_CHANG_DIR = 1    --改变方向
M.CMD_ADD_SPEED = 2    --加速

M.CMD_TYPE_KEYBOARD = 1
M.CMD_TYPE_MOUSE    = 2

--M.IP = "106.15.196.157"   --坨阿里云
M.IP = "192.168.147.128"  --家乡互动vm 
--M.IP = "192.168.81.108"  
--M.IP = "120.78.83.33"


return M