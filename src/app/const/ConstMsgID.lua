--协议号

local M = {}

--登录
M.c2s_login = 0
M.s2c_login = 1

--大厅
M.c2s_match = 100
M.s2c_match = 101

--房间
M.c2s_userop = 200         --玩家操作
M.s2c_turnop = 201         --一轮的玩家操作集合
M.s2c_gamestart = 202      --游戏开始

return M