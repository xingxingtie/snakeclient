

local SceneRoom = require("app.scenes.room.SceneRoom")
local SceneLogin = require("app.scenes.login.SceneLogin")
local Const = require("app.const.Const")
local EventConst = require("app.signal.EventConst")

local M = class("SceneWelcome", cc.load("mvc").ViewBase)

function M:onCreate()
    self:enableNodeEvents()

    self:_initUI()

    print("构造 sceneWelcome")
end

function M:_initUI()
    local bg = display.newSprite("bg.jpg")
        :addTo(self)
        :move(display.cx, display.cy)
    local scale = display.width / bg:getContentSize().width
    bg:setScale(scale)

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
    G_Signal:addEventListener(
        EventConst.EVENT_CONNECT, 
        handler(self,self._onEventConnect), 
        "sceneWelcome")

    --开始连接服务器
    print("尝试连接1111")
    G_SocketTCP:connect(Const.IP, 8888)
end

function M:_onEventConnect()
    print("连接成功")
    display.runScene(SceneLogin:create())
end

-- function M:kkk()
--     self:callAfter(0.1, handler(self, self.kkk))
-- end

--进入
function M:onEnter()
    -- self:callAfter(0, handler(self, self.kkk))

    -- local node = display.newSprite("head.jpg")
    --     :addTo(self)
    --     :move(0,300)
    -- node:setScale(0.3)

    -- node:moveTo({
    --     time = 60,
    --     x = 1280,
    --     y = 300})
end

--离开
function M:onExit()
    print("离开欢迎界面")

    G_Signal:removeEventListenerByTag("sceneWelcome")
end

return M
