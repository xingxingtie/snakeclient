local M = class("SceneLogin", cc.Scene)
local SceneRoom = require("app.scenes.room.SceneRoom")
local SceneRegister = require("app.scenes.register.SceneRegister")
local cursor  = require("app.tool.cursor")
local layoutScrollView  = require("app.tool.layoutScrollView")
local RoomItem = require("app.scenes.hall.RoomItem")
local errorCode = require("proto.errorCode")

function M:ctor() 
    self:_initUI()

    self:_registerMsgProcess()

    self:enableNodeEvents()
end

function M:_initUI()
    local ui = require("res.ui.hall_layer").create()
    self:addChild(ui.root)
    ui.root:setContentSize(display.size)
    ccui.Helper:doLayout(ui.root)

    dump(display.size, "display size")

    self.scrollView = ui.root:getChildByName("ScrollView")
    layoutScrollView.adjustScrollView(self.scrollView, display.width)

    local btnCreatRoom = ui.root:getChildByName("btn_createRoom")
    btnCreatRoom:onClick(handler(self, self._onBtnCreateRoom))   

    local btnListRoom = ui.root:getChildByName("btn_listRoom")
    btnListRoom:onClick(handler(self, self._onBtnListRoom))  
end

function M:_registerMsgProcess()
    G_MsgManager:registerMsgProcess(
        "s2c_listRoom", 
        handler(self, self._onMsgListRoom))

    G_MsgManager:registerMsgProcess(
        "s2c_createRoom", 
        handler(self, self._onMsgCreateRoom))

    G_MsgManager:registerMsgProcess(
        "s2c_enterRoom", 
        handler(self, self._onMsgEnterRoom))    
end

function M:_unregisterMsgProcess()
    G_MsgManager:unregisterMsgProcess("s2c_listRoom")
    G_MsgManager:unregisterMsgProcess("s2c_createRoom")
    G_MsgManager:unregisterMsgProcess("s2c_enterRoom")
end

function M:_onMsgListRoom(msg)
    local innerC = self.scrollView:getInnerContainer()
    innerC:removeAllChildren()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    
    if not msg.roomList then
        return
    end

    local itemList = {}
    for _, v in ipairs(msg.roomList) do 
        local item = RoomItem:create(handler(self, self._applyEnterRoom))
        item:update(v)
        table.insert(itemList, item)
    end

    layoutScrollView.tile(self.scrollView, itemList, 250, 100)
    self.scrollView:stopAutoScroll()
    self.scrollView:scrollToTop(0.1, false)
end

function M:_onMsgCreateRoom(msg)
    if msg.retCode == 0 then 
        self:toast("创建房间成功")
    else
        self:toastErrorCode(msg.retCode)
    end
end

function M:_onMsgEnterRoom(msg)
    if msg.retCode == 0 or msg.retCode == errorCode.ALREADY_IN_ROOM then 
        display.runScene(SceneRoom:create())
    else
        self:toastErrorCode(msg.retCode)
    end
end

function M:_applyEnterRoom(roomInfo)
    local code = G_MsgManager:packData(
        "c2s_enterRoom", 
        {roomID = roomInfo.roomID})

    G_SocketTCP:send(code)
end

function M:_onBtnCreateRoom()
    local code = G_MsgManager:packData(
        "c2s_createRoom")

    G_SocketTCP:send(code)
end

function M:_onBtnListRoom()
    local code = G_MsgManager:packData(
        "c2s_listRoom")

    G_SocketTCP:send(code)
end

--进入
function M:onEnter()
   
end

function M:onExit()
    self:_unregisterMsgProcess()
end

return M
