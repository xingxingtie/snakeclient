--注册场景
local M = class("SceneRegister", cc.Scene)
local SceneRoom = require("app.scenes.room.SceneRoom")
local ConstMsgID = require("app.const.ConstMsgID")

function M:ctor(onRegisterSuccess) 
    self._onRegisterSuccess = onRegisterSuccess

    self:_initUI()

    self:enableNodeEvents()
end

function M:_initUI()
    local ui = require("res.ui.register_layer").create()
    self:addChild(ui.root)
    ui.root:setContentSize(display.size)
    ccui.Helper:doLayout(ui.root)

    local btnRegister = ui.root:getChildByName("btn_register")
    btnRegister:onClick(handler(self, self._onBtnRegister))

    self._TFAccount = ui.root:getChildByName("input_account")
    self._TFPassword = ui.root:getChildByName("input_password")
    self._TFConfirmPassword = ui.root:getChildByName("input_confirmpassword")

    --
    G_MsgManager:registerMsgProcess(
        ConstMsgID.s2c_register, 
        "s2c_register", 
        handler(self, self._onMsgRegister))
end

--登录成功
function M:_onMsgRegister(msg)    
    if msg.retCode == 0 then 
        if self._onRegisterSuccess then 
            self._onRegisterSuccess()
        end
        print("显示注册成功")
        self:toast("注册成功")
    else
        self:toast("注册失败, errorID:%d", msg.retCode)
    end
end

--登录
function M:_onBtnRegister()

    local password = self._TFPassword:getString()
    local confirm_password = self._TFConfirmPassword:getString()

    if password ~= confirm_password then 
        self:toast("密码不一致")
        return
    end

    local code = G_MsgManager:packData(
        ConstMsgID.c2s_register, 
        "c2s_register", 
        {
            account = self._TFAccount:getString(),
            password = self._TFPassword:getString(),
        })

    G_SocketTCP:send(code)
end

--进入
function M:onEnter()
   
end

return M