--沙盘
local Snake = require("app.scenes.sandtable.Snake")
local MapConfig = require("app.scenes.sandtable.MapConfig")
local CollisionMap = require("app.scenes.sandtable.CollisionMap")
local Const = require("app.const.Const")

local M = class("SceneSandTable", cc.Scene)
function M:ctor(playerList, msg)
    self._snakeList = {}

    self._turnDuration = msg.turnTime / 1000 --转换为秒值

    self:_registerMsgProcess()

    self:enableNodeEvents()

    self._duration = 0  --可用的持续时间 每次后端过来后会增加一定量的持续时间

    self:_initCollisionMap("WASTE_LAND")

    self:_initUI(playerList)
end

--初始化碰撞map
function M:_initCollisionMap(name)
    self._mapConfig = MapConfig[name]

    self._map = CollisionMap:create(self._mapConfig, self)
end

--设定和蛇交流都是通过格子编号，蛇内部才进行像素级处理
function M:_initUI(playerList)
    for i, v in ipairs(playerList) do
        if v.position <= 5 then 
            v.group = 1
        else 
            v.group = 2
        end

        local role = Snake:create(self._mapConfig, v, self._map, self)

        self._snakeList[v.userID] = role
    end

    -- local draw_manager = cc.DrawNode:create() 
    -- self:addChild(draw_manager)

    -- for x = 0, 1280, 8 do 
    --     draw_manager:drawSegment(
    --         cc.p(x, 0), 
    --         cc.p(x, 720), 
    --         1, 
    --         cc.c4b(153,153,50,0.5))        
    -- end

    -- for y = 0, 720, 8 do 
    --     draw_manager:drawSegment(
    --         cc.p(0, y), 
    --         cc.p(1280, y), 
    --         1, 
    --         cc.c4b(153,153,50,0.5))        
    
    -- end
    --local dot_1 = draw_manager:drawDot(cc.p(100,100),100,cc.c4b(153,153,50,0.5))
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_turnCommand", 
        handler(self, self._onMsgTurnCommand))

    G_MsgManager:registerMsgProcess(
        "s2c_launch", 
        handler(self, self._onMsgLaunch))
end

function M:_unregisterMsgProcess()
   G_MsgManager:unregisterMsgProcess("s2c_turnCommand")
   
   G_MsgManager:unregisterMsgProcess("s2c_launch")
end

function M:_frameUpdate(dt)
    dt = math.min(self._duration, dt)

    if dt <= 0 then 
        return
    end

    self._duration = self._duration - dt

    --地图更新
    self._map:update(dt)

    for _, v in pairs(self._snakeList) do 
        v:update(1 - self._duration / self._turnDuration)

        if v:isDie() then 
            self._snakeList[v:getUserID()] = nil
        end        
    end
end

function M:_onMsgTurnCommand(msg)
    --把之前没有用玩的时间用完
    self:_frameUpdate(self._duration)
    self._duration = self._turnDuration

    --分发命令
    for _, v in ipairs(msg.turnCmd) do 
        local role = self._snakeList[v.userID]
        if role then role:doCommand(v) end
    end

    --每条蛇记录并传递关键位置
    for _, v in pairs(self._snakeList) do 
        v:updateTargetPos()
    end
end

function M:_onMsgLaunch()
    math.randomseed(100)

    self._duration = 0

    self:_onMsgTurnCommand({turnCmd = {}})
end

function M:onEnter()
    local onKeyReleased = function ( keycode, event )    
        local code = G_MsgManager:packData(
            "c2s_userCommand", {
            cmdType = Const.CMD_TYPE_KEYBOARD,
            x = keycode})
        G_SocketTCP:send(code)
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    G_MsgManager:RegisterFrameEventListener(
        handler(self, self._frameUpdate))

    local code = G_MsgManager:packData("c2s_loadComplete")
    G_SocketTCP:send(code)
end

return M