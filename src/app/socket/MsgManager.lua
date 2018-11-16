
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
end
 
function M:_launchSocket()
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function() G_SocketTCP:update() end,
        0.01,  
        false)
end

--分发包
function M:_dispatchPackage(packArr)
    if not packArr then return end

    for _, pack in ipairs(packArr) do 
        local list = self._listener[pack.id]

        print("协议id", pack.id)

        for k,v in pairs(list) do 
            local msg = self._sp:decode(v, pack.data)
            k(msg)
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
function M:registerMsgProcess(protoName, callback)
    assert(callback, "网络包监听函数不能为空")
    assert(ConstMsgID[protoName], "协议id不能为空" .. protoName)

    local id = ConstMsgID[protoName]
    local list = self._listener[id]

    if not list then 
        list = {}
        self._listener[id] = list
    end

    assert(not list[callback], "同一个监听函数不能监听两次同一个网络包")

    list[callback] = protoName
end

function M:packData(protoName, tab)
    assert(ConstMsgID[protoName], "协议id不能为空")
    tab = tab or {}

    local msgid = ConstMsgID[protoName]
    local code = self._sp:encode(protoName, tab)
    local len = string.len(code)

    code = string.pack(">HIA", len + 4, msgid, code)   
    return code
end


function M:UnregisterMsgProcess(id, callback)
    local list = self._listener[id]

    if not list then return end

    list[callback] = nil
end

return M