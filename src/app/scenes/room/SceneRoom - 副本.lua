
local SceneSandTable = require("app.scenes.sandtable.SceneSandTable")
local ConstMsgID = require("proto.ConstMsgID")

local M = class("SceneRoom", cc.Scene)
function M:ctor() 
    self:_initUI()

    self:enableNodeEvents()
end

function M:_initUI()
    local label = cc.Label:createWithSystemFont("匹配界面", "Arial", 40)
        :move(0, display.height)
        :addTo(self)
    label:setAnchorPoint(0, 1)

    --按钮
    local btn = ccui.Button:create("widget/btn_lan.png", "widget/btn_lan.png", "widget/btn_hui.png")
        :move(display.cx, display.cy)
        :addTo(self)
    btn:setTitleText("开始匹配")
    btn:setTitleColor(cc.c3b(0xff, 0xff, 0xff))
    btn:setTitleFontSize(39)
    btn:setTouchEnabled(true)
    btn:onClick(handler(self, self.onBtnMatchClick))
    btn:setAnchorPoint(0.5, 0.5)

    --沙盘场景
    self._sandScene = SceneSandTable:create()
    self._sandScene:retain()


    room_layer
end

--匹配
function M:_onMsgMatch(msg)

    dump(msg.userList, "匹配玩家列表")
    
    self._sandScene:addPlayer(msg.userList)

end

--游戏开始
function M:_onMsgGameStart(msg)

    dump(msg, "游戏开始")

    self._sandScene:run(msg.turnCmd)

    display.runScene(self._sandScene)
end

function M:onEnter()
    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_match, 
        "s2c_match", 
        handler(self, self._onMsgMatch))

    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_gamestart, 
        "s2c_gamestart", 
        handler(self, self._onMsgGameStart))
end

function M:onExit()
    
end

function M:onBtnMatchClick()
    local code = G_MsgManager:packData(
        "c2s_match", {})
    G_SocketTCP:send(code)
end

return M