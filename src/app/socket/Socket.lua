--socket 封装类，内部暂使用luasocket

local SOCKETCONST = require("app.socket.SOCKETCONST")
local EventConst = require("app.signal.EventConst")
local socket = require("socket.core")
local M = class("socket")

--构造并设置回掉方法
function M:ctor(socketType, callback)
    self._type = socketType
    self._callback = callback

    if(self._type == SOCKETCONST.SOCKTYPE_TCP) then
        self._sock = socket.tcp()
        self._sock:settimeout(0)
        self._connecting = false   
    else 
        self._sock = socket.udp()
    end
end

function M:_checkTcpConnect()
    local recvt, sendt, status = socket.select(nil, {self._sock}, 0)

    if(#sendt > 0) then 
        self._connecting = true

        self._callback(EventConst.EVENT_CONNECT)
    end
end

--连接
function M:connect(ip, port)
    if (self._type == SOCKETCONST.SOCKTYPE_TCP) then 
        self._sock:connect(ip, port)
    else 
        self._sock:setpeername(ip, port)
    end
end

--数据发送
function M:send(data)
    self._sock:send(data)
end

--更新
function M:update()
    if (self._type == SOCKETCONST.SOCKTYPE_TCP) then 
        if not self._connecting then 
            self:_checkTcpConnect()
        else 
            local response, receive_status, particle = self._sock:receive("*a")

            if receive_status == "closed" then
                self._callback(EventConst.EVENT_DISCONNECT)
                self._connecting = false
            else 
                if((response or particle) and string.len(particle) ~= 0) then 
                    self._callback(EventConst.EVENT_DATA, response or particle)
                end
            end
        end        
    end
end

return M