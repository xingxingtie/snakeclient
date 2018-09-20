
require("pack")

local SOCKETCONST = require("app.socket.SOCKETCONST")

--事件管理器
G_Signal = require("app.signal.EventManager"):create()

--消息管理器
G_MsgManager = require("app.socket.MsgManager"):create()

--tcp
G_SocketTCP = require("app.socket.Socket"):create(
    SOCKETCONST.SOCKTYPE_TCP,
    handler(G_MsgManager, G_MsgManager.handle))

--udp
G_SocketUDP = require("app.socket.Socket"):create(
    SOCKETCONST.SOCKTYPE_UDP,
    handler(G_MsgManager, G_MsgManager.handle))



