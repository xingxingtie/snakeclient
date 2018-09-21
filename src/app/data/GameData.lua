local M = class("GameData")

function M:ctor()
    self._gameID = nil  --游戏id
end

function M:setGameID(gameID)
    self._gameID = gameID
end

function M:getGameID()
    return self._gameID
end


return M
