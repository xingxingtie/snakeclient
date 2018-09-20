--网络数据切包器 切包和存储数据缓存
--数据包定义为 2字节包长 + 4字节包id + 具体数据

local CLIPSTAGE_HEAD  = 1
local CLIPSTAGE_DATA  = 2

local NetPacket = require("app.socket.NetPacket")
local M = class("NetDataClipper")

function M:ctor()
    self._buff = ""
    self._packet = NetPacket:create()
    self._stage = CLIPSTAGE_HEAD
end

function M:clipper(data, query)

    if self._stage == CLIPSTAGE_HEAD then 
        self._buff = self._buff .. data

        local len = string.len(self._buff)
     
        if len >= 2 then 
            _, self._packet.length, self._buff = string.unpack(self._buff, ">HA"..len - 2)

            self._stage = CLIPSTAGE_DATA

            self:clipper("", query)
        end
    end 

    if self._stage == CLIPSTAGE_DATA then 
        self._buff = self._buff .. data

        local len = string.len(self._buff)

        if (len >= self._packet.length) then 
            local format = string.format(">IA%dA%d", self._packet.length-4, len - self._packet.length)

            _, self._packet.id, self._packet.data, self._buff = string.unpack(self._buff, format)        

            table.insert(query, self._packet)
            self._packet = NetPacket:create()

            self._stage = CLIPSTAGE_HEAD
            self:clipper("", query)
        end
    end
end

--追加网络数据 返回切好的包
function M:appendData(data)

    if not data then return end

    local packArr = {}
    
    self:clipper(data, packArr)

    return packArr
end

return M