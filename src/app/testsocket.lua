local EventConst = require("app.signal.EventConst")

G_Signal:addEventListener(EventConst.EVENT_CONNECT, function() 
    local data = {
        name = "hello",
        id = 9999
    }

    local code = G_MsgManager:packData(100, "person", data)

    G_SocketTCP:send(code)

end, 1)

G_Signal:addEventListener(EventConst.EVENT_DISCONNECT, function() print("连接失败") end, 
    1)

G_MsgManager:registerMsgProcess(101, "person", 
    function(msg) dump(msg, "收到数据") end)

G_SocketTCP:connect("192.168.147.128", 8888)

local timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
    function() G_SocketTCP:update() end,
    0.05,  
    false)


