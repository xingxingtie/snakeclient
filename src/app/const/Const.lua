local M = {}

M.DELTAGROUP = 10000   --队伍放大因子

M.LINE = 50       --地图被分成的行数
M.ROW  = 89       --地图被分成的列数
M.MapWidth  = 1280     --地图总宽度
M.MapHeight = 720      --地图总高度

M.TurnDuration    = 0.1  --一个轮回1000毫秒
M.StepDuration    = 0.1  --步进一次1000毫秒
--M.ActionCD        = 900   --行动冷却时间也就是说，按键一次900毫秒以后才接受第二次按键

M.keyCode_UP = 28
M.keyCode_DOWN = 29
M.keyCode_LEFT = 26
M.keyCode_RIGHT = 27

M.DIR_UP    = 1
M.DIR_DOWN  = 2
M.DIR_LEFT  = 3
M.DIR_RIGHT = 4

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