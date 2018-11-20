local M = class("GameData")

function M:ctor()
    self._userID = nil  --游戏id
end

function M:setUserID(value)
    self._userID = value
end

function M:getUserID()
   return self._userID
end

return M
