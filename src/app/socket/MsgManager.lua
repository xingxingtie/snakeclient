
local NetDataClipper = require("app.socket.NetDataClipper")
local EventConst = require("app.signal.EventConst")
local Socket = require("app.socket.Socket")
local sproto = require("app.tool.sproto")
local ConstMsgID = require("proto.ConstMsgID")

local M = class("MsgManager")
function M:ctor(fileName)
    self._sp = sproto.parsefile(fileName or "./res/proto/gameproto.bin")

    self._clipper = NetDataClipper:create()

    self._listener = {}

    self:_launchSocket()

    self._frameEventListener = nil
end
 
function M:_launchSocket()
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function(dt) 
            G_SocketTCP:update()
            if self._frameEventListener then self._frameEventListener(dt) end
        end,
        0,          --0 每帧都会被调用
        false)
end
--分发包
function M:_dispatchPackage(packArr)
    if not packArr then return end

    for _, pack in ipairs(packArr) do 
        local info = self._listener[pack.id]

        assert(info, "have none listener of msg id:" .. pack.id)

        local msg = self._sp:decode(info.__protoName, pack.data)
        local listenerList = info.__listenerList

        --dump( msg, info.__protoName)

        for k,v in pairs(listenerList) do 
            v(msg)
        end
    end
end

function M:handle(event, data)
    if event == EventConst.EVENT_DATA then
        local packArr = self._clipper:appendData(data)
        self:_dispatchPackage(packArr)

    elseif event == EventConst.EVENT_CONNECT then 
        G_Signal:dispatchEvent(EventConst.EVENT_CONNECT)

    elseif event == EventConst.EVENT_DISCONNECT then 
        G_Signal:dispatchEvent(EventConst.EVENT_DISCONNECT)
    end
end

--[[
    id : 协议id   
    callback :  回调函数
    protoName : 指明用哪个协议格式去解包

--]]
function M:registerMsgProcess(protoName, callback, flag)
    assert(callback, "网络包监听函数不能为空")
    assert(ConstMsgID[protoName], "协议id不能为空" .. protoName)

    flag = flag or "__noflag__"

    local id = ConstMsgID[protoName]
    local info = self._listener[id]

    if not info then 
        info = {
            __protoName    = protoName,
            __listenerList = {}
        }
        self._listener[id] = info
    end

    assert(not info[flag], "同一个监听函数不能监听两次同一个网络包")

    info.__listenerList[flag] = callback
end

function M:UnregisterMsgProcess(protoName, flag)
    local id = ConstMsgID[protoName]
    local info = self._listener[id]

    if not info then return end

    flag = flag or "__noflag__"
    info.__listenerList[flag] = nil
end

local EmptyTab = {}
function M:packData(protoName, tab)
    assert(ConstMsgID[protoName], "协议id不能为空")
    tab = tab or EmptyTab

    local msgid = ConstMsgID[protoName]
    local code = self._sp:encode(protoName, tab)
    local len = string.len(code)

    code = string.pack(">HIA", len + 4, msgid, code)   
    return code
end

function M:RegisterFrameEventListener(listener)
    self._frameEventListener = listener
end

return M