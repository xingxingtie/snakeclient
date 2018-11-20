--事件注册、分发管理

local M = class("EventManager")

function M:ctor()
    self._pool = {}
end

--添加事件注册
function M:addEventListener(evt, listener, tag)
    local record = self._pool[tag]

    if not record then
        record = {}
        self._pool[tag] = record
    end

    record[evt] = listener
end

--消息分发
function M:dispatchEvent(evt, ...)
    for k, v in pairs(self._pool) do 
        if v[evt] then 
            v[evt](...)
        end
    end
end

--删除一类事件注册
function M:removeEventListenerByTag(tag)
    self._pool[tag] = nil
end

--删除一个事件注册
function M:removeEventListener(tag, evt)
    local record = self._pool[tag]

    if not record then return end

    record[evt] = nil
end

return M
