--------------------------------------------------------------
-- This file was automatically generated by Cocos Studio.
-- Do not make changes to this file.
-- All changes will be lost.
--------------------------------------------------------------

local luaExtend = require "LuaExtend"

-- using for layout to decrease count of local variables
local layout = nil
local localLuaFile = nil
local innerCSD = nil
local innerProject = nil
local localFrame = nil

local Result = {}
------------------------------------------------------------
-- function call description
-- create function caller should provide a function to 
-- get a callback function in creating scene process.
-- the returned callback function will be registered to 
-- the callback event of the control.
-- the function provider is as below :
-- Callback callBackProvider(luaFileName, node, callbackName)
-- parameter description:
-- luaFileName  : a string, lua file name
-- node         : a Node, event source
-- callbackName : a string, callback function name
-- the return value is a callback function
------------------------------------------------------------
function Result.create(callBackProvider)

local result={}
setmetatable(result, luaExtend)

--Create Layer
local Layer=cc.Node:create()
Layer:setName("Layer")
layout = ccui.LayoutComponent:bindLayoutComponent(Layer)
layout:setSize({width = 1280.0000, height = 720.0000})

--Create ScrollView
local ScrollView = ccui.ScrollView:create()
ScrollView:setBounceEnabled(true)
ScrollView:setInnerContainerSize({width = 1280, height = 720})
ScrollView:ignoreContentAdaptWithSize(false)
ScrollView:setClippingEnabled(true)
ScrollView:setBackGroundColorType(1)
ScrollView:setBackGroundColor({r = 255, g = 150, b = 100})
ScrollView:setLayoutComponentEnabled(true)
ScrollView:setName("ScrollView")
ScrollView:setTag(27)
ScrollView:setCascadeColorEnabled(true)
ScrollView:setCascadeOpacityEnabled(true)
ScrollView:setPosition(0.0000, 98.6951)
layout = ccui.LayoutComponent:bindLayoutComponent(ScrollView)
layout:setPositionPercentY(0.1371)
layout:setPercentWidth(1.0000)
layout:setPercentHeight(0.8611)
layout:setSize({width = 1280.0000, height = 620.0000})
layout:setHorizontalEdge(3)
layout:setTopMargin(1.3049)
layout:setBottomMargin(98.6951)
Layer:addChild(ScrollView)

--Create btn_createRoom
local btn_createRoom = ccui.Button:create()
btn_createRoom:ignoreContentAdaptWithSize(false)
btn_createRoom:loadTextureNormal("res/widget/btn_lv.png",0)
btn_createRoom:loadTexturePressed("res/widget/btn_lv.png",0)
btn_createRoom:loadTextureDisabled("Default/Button_Disable.png",0)
btn_createRoom:setTitleFontSize(14)
btn_createRoom:setTitleColor({r = 65, g = 65, b = 70})
btn_createRoom:setScale9Enabled(true)
btn_createRoom:setCapInsets({x = 15, y = 11, width = 203, height = 62})
btn_createRoom:setLayoutComponentEnabled(true)
btn_createRoom:setName("btn_createRoom")
btn_createRoom:setTag(3)
btn_createRoom:setCascadeColorEnabled(true)
btn_createRoom:setCascadeOpacityEnabled(true)
btn_createRoom:setPosition(1146.6970, 49.3286)
layout = ccui.LayoutComponent:bindLayoutComponent(btn_createRoom)
layout:setPositionPercentX(0.8959)
layout:setPositionPercentY(0.0685)
layout:setPercentWidth(0.1820)
layout:setPercentHeight(0.1167)
layout:setSize({width = 233.0000, height = 84.0000})
layout:setLeftMargin(1030.1970)
layout:setRightMargin(16.8027)
layout:setTopMargin(628.6714)
layout:setBottomMargin(7.3286)
Layer:addChild(btn_createRoom)

--Create Text_6
local Text_6 = ccui.Text:create()
Text_6:ignoreContentAdaptWithSize(true)
Text_6:setTextAreaSize({width = 0, height = 0})
Text_6:setFontName("fonts/mnjcy.ttf")
Text_6:setFontSize(35)
Text_6:setString([[创建房间]])
Text_6:setLayoutComponentEnabled(true)
Text_6:setName("Text_6")
Text_6:setTag(14)
Text_6:setCascadeColorEnabled(true)
Text_6:setCascadeOpacityEnabled(true)
Text_6:setPosition(113.3042, 40.5654)
Text_6:setTextColor({r = 255, g = 255, b = 0})
layout = ccui.LayoutComponent:bindLayoutComponent(Text_6)
layout:setPositionPercentX(0.4863)
layout:setPositionPercentY(0.4829)
layout:setPercentWidth(0.6052)
layout:setPercentHeight(0.4762)
layout:setSize({width = 141.0000, height = 40.0000})
layout:setLeftMargin(42.8042)
layout:setRightMargin(49.1958)
layout:setTopMargin(23.4346)
layout:setBottomMargin(20.5654)
btn_createRoom:addChild(Text_6)

--Create btn_listRoom
local btn_listRoom = ccui.Button:create()
btn_listRoom:ignoreContentAdaptWithSize(false)
btn_listRoom:loadTextureNormal("res/widget/btn_lv.png",0)
btn_listRoom:loadTexturePressed("res/widget/btn_lv.png",0)
btn_listRoom:loadTextureDisabled("Default/Button_Disable.png",0)
btn_listRoom:setTitleFontSize(14)
btn_listRoom:setTitleColor({r = 65, g = 65, b = 70})
btn_listRoom:setScale9Enabled(true)
btn_listRoom:setCapInsets({x = 15, y = 11, width = 203, height = 62})
btn_listRoom:setLayoutComponentEnabled(true)
btn_listRoom:setName("btn_listRoom")
btn_listRoom:setTag(15)
btn_listRoom:setCascadeColorEnabled(true)
btn_listRoom:setCascadeOpacityEnabled(true)
btn_listRoom:setPosition(903.5149, 49.3300)
layout = ccui.LayoutComponent:bindLayoutComponent(btn_listRoom)
layout:setPositionPercentX(0.7059)
layout:setPositionPercentY(0.0685)
layout:setPercentWidth(0.1820)
layout:setPercentHeight(0.1167)
layout:setSize({width = 233.0000, height = 84.0000})
layout:setLeftMargin(787.0149)
layout:setRightMargin(259.9851)
layout:setTopMargin(628.6700)
layout:setBottomMargin(7.3300)
Layer:addChild(btn_listRoom)

--Create Text_6
local Text_6 = ccui.Text:create()
Text_6:ignoreContentAdaptWithSize(true)
Text_6:setTextAreaSize({width = 0, height = 0})
Text_6:setFontName("fonts/mnjcy.ttf")
Text_6:setFontSize(35)
Text_6:setString([[列出房间]])
Text_6:setLayoutComponentEnabled(true)
Text_6:setName("Text_6")
Text_6:setTag(16)
Text_6:setCascadeColorEnabled(true)
Text_6:setCascadeOpacityEnabled(true)
Text_6:setPosition(113.3042, 40.5654)
Text_6:setTextColor({r = 255, g = 255, b = 0})
layout = ccui.LayoutComponent:bindLayoutComponent(Text_6)
layout:setPositionPercentX(0.4863)
layout:setPositionPercentY(0.4829)
layout:setPercentWidth(0.6052)
layout:setPercentHeight(0.4762)
layout:setSize({width = 141.0000, height = 40.0000})
layout:setLeftMargin(42.8042)
layout:setRightMargin(49.1958)
layout:setTopMargin(23.4346)
layout:setBottomMargin(20.5654)
btn_listRoom:addChild(Text_6)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(0)
result['animation']:setTimeSpeed(1.0000)
--Create Animation List

result['root'] = Layer
return result;
end

return Result

