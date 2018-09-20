

local SceneRoom = require("app.scenes.room.SceneRoom")
local ConstMsgID = require("app.const.ConstMsgID")

local M = class("SceneWelcome", cc.load("mvc").ViewBase)

function M:onCreate()
    -- add background image
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
    btn:setTouchEnabled(false)
    btn:onClick(handler(self, self.onBtnEnterClick))
    btn:setAnchorPoint(0.5, 0.5)

    self:enableNodeEvents()
    
    self.btnEnter = btn
end

--按键进入
function M:onBtnEnterClick(sender)
    display.runScene(SceneRoom:create())
end

--登录成功
function M:_onMsgLogin(msg)

    for k,v in pairs(msg) do 
        print(k, v)
    end
    
    if msg.retCode == 0 then 
        print("登录成功 我的id是:" .. msg.id)
    else 
        print("登录失败....")    
    end

    self.btnEnter:setTouchEnabled(true)
end

--进入
function M:onEnter()
    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_login, 
        "s2c_login", 
        handler(self, self._onMsgLogin))

    print("开始登录服务器")
    --开始连接服务器
    G_SocketTCP:connect("192.168.81.108", 8888)
end

--离开
function M:onExit()
    print("离开欢迎界面")
end

return M
