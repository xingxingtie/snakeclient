--网络数据包

local M = class("NetPacket")

function M:ctor()
    self.length = nil
    self.id     = nil
    self.data   = nil
end

return M