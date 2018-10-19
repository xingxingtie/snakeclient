--登录场景

local M = class("SceneLogin", cc.Scene)
local SceneRoom = require("app.scenes.room.SceneRoom")
local SceneRegister = require("app.scenes.register.SceneRegister")
local ConstMsgID = require("app.const.ConstMsgID")


function M:ctor() 
    self:_initUI()

    self:enableNodeEvents()
end

function M:_initUI()
    local ui = require("res.ui.login_layer").create()
    self:addChild(ui.root)
    ui.root:setContentSize(display.size)
    ccui.Helper:doLayout(ui.root)

    local btnLogin = ui.root:getChildByName("btn_login")
    btnLogin:onClick(handler(self, self._onBtnLogin))

    local btnRegister = ui.root:getChildByName("btn_register")
    btnRegister:onClick(handler(self, self._onBtnRegister))    

    self._TFAccount = ui.root:getChildByName("input_account")
    self._TFPassword = ui.root:getChildByName("input_password")
end

--登录成功
function M:_onMsgLogin(msg)    
    if msg.retCode == 0 then 
        G_GameData:setGameID(msg.id)
        display.runScene(SceneRoom:create())
        self:toast("登录成功")
    else
        self:toast("登录失败, errorID:%d", msg.retCode)
    end
end

--切换注册
function M:_onBtnRegister()
    local gotoLogin = function() 
        display.runScene(M:create())
    end

    display.runScene(SceneRegister:create(gotoLogin))
end

--登录
function M:_onBtnLogin()
    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_login, 
        "s2c_login", 
        handler(self, self._onMsgLogin))

    local code = G_MsgManager:packData(
        ConstMsgID.c2s_login, 
        "c2s_login", 
        {
            account = "xian", --self._TFAccount:getString(),
            password = "1",   --self._TFPassword:getString(),
        })

    G_SocketTCP:send(code)
end

--进入
function M:onEnter()
   
end

return M

