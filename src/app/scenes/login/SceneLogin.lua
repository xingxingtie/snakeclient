--登录场景
local M = class("SceneLogin", cc.Scene)
local SceneRoom = require("app.scenes.room.SceneRoom")
local SceneHall = require("app.scenes.hall.SceneHall")
local SceneRegister = require("app.scenes.register.SceneRegister")
local cursor  = require("app.tool.cursor")

function M:ctor() 
    self:_initUI()

    self:_registerMsgProcess()

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

    self._TFAccount  = ui.root:getChildByName("input_account")
    self._TFPassword = ui.root:getChildByName("input_password")
    self._RefText    = ui.root:getChildByName("ref_text")

    cursor.attachCusor(self._TFAccount, self._RefText)
    cursor.attachCusor(self._TFPassword, self._RefText)
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_login", 
        handler(self, self._onMsgLogin))
end

function M:_unregisterMsgProcess()
    G_MsgManager:unregisterMsgProcess("s2c_login")
end

--登录成功
function M:_onMsgLogin(msg)    
    if msg.retCode == 0 then 
        G_GameData:setUserID(msg.id)
        display.runScene(SceneHall:create())
    else
        self:toastErrorCode(msg.retCode)
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
    if self._TFAccount:getString() == "" then 
        self._TFAccount:setString("tuo")
    end

    if self._TFPassword:getString() == "" then 
        self._TFPassword:setString("haha")
    end    

    local code = G_MsgManager:packData(
        "c2s_login", 
        {
            account = self._TFAccount:getString(),
            password = self._TFPassword:getString(),
        })

    G_SocketTCP:send(code)
end

--进入
function M:onEnter()
   
end

function M:onExit()
    self:_unregisterMsgProcess()
end

return M

