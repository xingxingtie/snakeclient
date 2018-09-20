
local SceneSandTable = require("app.scenes.sandtable.SceneSandTable")
local ConstMsgID = require("app.const.ConstMsgID")

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
end

--匹配
function M:_onMsgMatch(msg)
    print("玩家匹配结束...")
end

--游戏开始
function M:_onMsgGameStart(msg)
    display.runScene(SceneSandTable:create())
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
    local code = G_MsgManager:packData(ConstMsgID.c2s_match, "c2s_match", {})
    G_SocketTCP:send(code)
end

return M