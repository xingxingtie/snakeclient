--云风博客中提到的经典帧同步做法
--[[
    针对传统的 lockstep 算法，通常是这样实现的：设定一个逻辑周期，通常是 100ms ，和渲染表现层分开。
    
    玩家在客户端的操作会被延迟确认。我们可以给没有操作设定延迟时长，从 0 到 50ms （一半的回合周期）。当收到回合确认同步信息（即所有玩家当前回合的操作指令）后，找到指令队列中延迟时间最短的那个时间，设置超时时长。超时后，把指令队列作为下个回合的操作指令打包发出。
    
    如果至少有一个 0 操作延迟的动作，那么就会在收到上个回合确认后，立刻发出。如果没有任何操作，那么最多会再等待 50ms 发出一个 idle 操作作为当前回合的操作指令。
    
    这个 10Hz 的逻辑周期，并不是由收到网络信息包驱动的，而是采用客户端内在的时钟稳定按 100ms 的心跳步进。网络正常的情况下，客户端会在逻辑心跳的时刻点之前就收到了所有其它玩家当前回合的操作指令；因为如果玩家在频繁交互，大部分动作都是 0 延迟的，会在上个回合时刻点就发出了；如果玩家没有操作，也会在 50ms 前发出操作；在网络单向延迟 50 ms （ ping 值 100ms）之下，是一定能提前获知下个回合沙盘要如何推演的。
    
    也就是说，若网络条件良好，每当逻辑周期心跳的那一刻，我们已经知道了所有人会做些什么。在逻辑层下，沙盘上所有单位都是离散运动的；我们确定知道在这个时刻，沙盘上的所有单位处于什么状态：在什么位置、什么移动速度、处于什么状态中…… 。对于表现层，只需要插值模拟逻辑确定的时刻点之间，把两个离散状态变为一个连续状态，单位的运动看起来平滑。
    
    当网络条件不好时，我们也可以想一些办法尽可能地让表现层平滑。例如，在下个回合的逻辑时刻点 20ms 之前再检查一次有没有收齐数据，如果没有，就减慢表现层的时间，推迟下个逻辑时刻点。玩家看起来本地的表现变慢了，但是并没有卡住。如果网络状态转好，又可以加快时钟赶上。
    
    如果实在是无法收到回合操作指令，最粗暴且有效的方法是直接弹出一个对话框，让本地游戏暂停等待。当同步正常（也就是收到了那个网络不好的玩家上个回合的操作指令后），再继续。如果玩家掉线或网络状态差到无法正常游戏而被踢下线，那么则可以在规则上让系统接管这个玩家，然后让剩下的玩家继续，之后的回合不再等待这个玩家的操作指令。
]]

local Role = require("app.scenes.tcpTest.role")
local M = class("TcpTest", cc.Scene)

function M:ctor(playerList, msg)
    self._roleList = {}

    self._turnDuration = msg.turnTime

    self:_initUI(playerList)

    self:_registerMsgProcess()

    self:enableNodeEvents()

    self._curCommand = nil
end

function M:_initUI(playerList)
    for _, v in ipairs(playerList) do 
        local role = Role:create()
            :addTo(self)

        self._roleList[v.userID] = role
    end
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_turnCommand", 
        handler(self, self._onMsgTurnCommand))

    G_MsgManager:registerMsgProcess(
        "s2c_launch", 
        handler(self, self._onMsgLaunch))
end

function M:_frameUpdate(dt)
    for _, v in pairs(self._roleList) do 
        v:update(dt)
    end
end

--逻辑时间到，执行命令。 必然包含每个玩家的命令
function M:_logicUpdate(dt)
    if self._curCommand == nil then
        print("时间到达命令没到")
        return
    end

    for _, v in ipairs(self._curCommand) do
        local role = self._roleList[v.userID]
        role:updateLogic(v.cmd, 0.1)
    end

    self._curCommand = nil
end

function M:_onMsgTurnCommand(msg)
    self._curCommand = msg.turnCmd 
end

function M:_onMsgLaunch()
    --self:_onMsgTurnCommand({turnCmd = {}})

    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            self:_frameUpdate(dt)
        end,
        0,
        false)

    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            self:_logicUpdate()
        end,
        0.1,
        false)

    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
           
        end,
        0.05,
        false)
end

M.preTime = 0

function M:onEnter()
    local onKeyReleased = function ( keycode, event )    
        local code = G_MsgManager:packData(
            "c2s_userCommand", {cmd = keycode})

        M.preTime = os.clock()

        G_SocketTCP:send(code)
    end
    
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    G_MsgManager:RegisterFrameEventListener(handler(self, self._frameUpdate))

    local code = G_MsgManager:packData("c2s_loadComplete")
    G_SocketTCP:send(code)
end

return M