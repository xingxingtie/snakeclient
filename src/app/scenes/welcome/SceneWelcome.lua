

local SceneRoom = require("app.scenes.room.SceneRoom")
local SceneLogin = require("app.scenes.login.SceneLogin")
local ConstMsgID = require("app.const.ConstMsgID")
local Const = require("app.const.Const")
local EventConst = require("app.signal.EventConst")

local M = class("SceneWelcome", cc.load("mvc").ViewBase)

function M:onCreate()
    self:enableNodeEvents()

    self:_initUI()
end

function M:_initUI()
    -- display.newSprite("bg.jpg")
    --     :move(display.center)
    --     :addTo(self)
    -- add HelloWorld label

    local label = cc.Label:createWithSystemFont("欢迎界面", "Arial", 40)
        :move(0, display.height)
        :addTo(self)
    label:setAnchorPoint(0, 1)

    local btn = ccui.Button:create("widget/btn_lan.png", "widget/btn_lan.png", "widget/btn_hui.png")
        :move(display.cx, 50)
        :addTo(self)
    btn:setTitleText("进 入")
    btn:setTitleColor(cc.c3b(0xff, 0xff, 0xff))
    btn:setTitleFontSize(39)
    btn:setTouchEnabled(true)
    btn:onClick(handler(self, self.onBtnEnterClick))
    btn:setAnchorPoint(0.5, 0.5)
end

--按键进入
function M:onBtnEnterClick(sender)
    G_Signal:addEventListener(EventConst.EVENT_CONNECT, handler(self,self._onEventConnect), 1)

    --开始连接服务器
    G_SocketTCP:connect(Const.IP, 8888)
end

function M:_onEventConnect()
    display.runScene(SceneLogin:create())
end

--进入
function M:onEnter()
   
end

--离开
function M:onExit()
    print("离开欢迎界面")
end

return M
