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

--Create player_1
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_1 = innerProject.root
player_1.animation = innerProject.animation
player_1:setName("player_1")
player_1:setTag(34)
player_1:setCascadeColorEnabled(true)
player_1:setCascadeOpacityEnabled(true)
player_1:setPosition(170.0000, 633.1910)
player_1:setScaleX(0.9400)
player_1:setScaleY(1.0000)
layout = ccui.LayoutComponent:bindLayoutComponent(player_1)
layout:setPositionPercentX(0.1328)
layout:setPositionPercentY(0.8794)
layout:setLeftMargin(170.0000)
layout:setRightMargin(1110.0000)
layout:setTopMargin(86.8090)
layout:setBottomMargin(633.1910)
innerProject.animation:setTimeSpeed(1.0000)
player_1:runAction(innerProject.animation)
Layer:addChild(player_1)

--Create player_2
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_2 = innerProject.root
player_2.animation = innerProject.animation
player_2:setName("player_2")
player_2:setTag(40)
player_2:setCascadeColorEnabled(true)
player_2:setCascadeOpacityEnabled(true)
player_2:setPosition(238.0000, 459.7096)
layout = ccui.LayoutComponent:bindLayoutComponent(player_2)
layout:setPositionPercentX(0.1859)
layout:setPositionPercentY(0.6385)
layout:setLeftMargin(238.0000)
layout:setRightMargin(1042.0000)
layout:setTopMargin(260.2904)
layout:setBottomMargin(459.7096)
innerProject.animation:setTimeSpeed(1.0000)
player_2:runAction(innerProject.animation)
Layer:addChild(player_2)

--Create player_3
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_3 = innerProject.root
player_3.animation = innerProject.animation
player_3:setName("player_3")
player_3:setTag(46)
player_3:setCascadeColorEnabled(true)
player_3:setCascadeOpacityEnabled(true)
player_3:setPosition(306.0000, 287.9055)
layout = ccui.LayoutComponent:bindLayoutComponent(player_3)
layout:setPositionPercentX(0.2391)
layout:setPositionPercentY(0.3999)
layout:setLeftMargin(306.0000)
layout:setRightMargin(974.0000)
layout:setTopMargin(432.0945)
layout:setBottomMargin(287.9055)
innerProject.animation:setTimeSpeed(1.0000)
player_3:runAction(innerProject.animation)
Layer:addChild(player_3)

--Create player_4
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_4 = innerProject.root
player_4.animation = innerProject.animation
player_4:setName("player_4")
player_4:setTag(52)
player_4:setCascadeColorEnabled(true)
player_4:setCascadeOpacityEnabled(true)
player_4:setPosition(860.0000, 633.1912)
layout = ccui.LayoutComponent:bindLayoutComponent(player_4)
layout:setPositionPercentX(0.6719)
layout:setPositionPercentY(0.8794)
layout:setLeftMargin(860.0000)
layout:setRightMargin(420.0000)
layout:setTopMargin(86.8088)
layout:setBottomMargin(633.1912)
innerProject.animation:setTimeSpeed(1.0000)
player_4:runAction(innerProject.animation)
Layer:addChild(player_4)

--Create player_5
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_5 = innerProject.root
player_5.animation = innerProject.animation
player_5:setName("player_5")
player_5:setTag(58)
player_5:setCascadeColorEnabled(true)
player_5:setCascadeOpacityEnabled(true)
player_5:setPosition(792.0000, 459.7096)
layout = ccui.LayoutComponent:bindLayoutComponent(player_5)
layout:setPositionPercentX(0.6188)
layout:setPositionPercentY(0.6385)
layout:setLeftMargin(792.0000)
layout:setRightMargin(488.0000)
layout:setTopMargin(260.2904)
layout:setBottomMargin(459.7096)
innerProject.animation:setTimeSpeed(1.0000)
player_5:runAction(innerProject.animation)
Layer:addChild(player_5)

--Create player_6
innerCSD = require("ui.player_item")
innerProject = innerCSD.create(callBackProvider)
local player_6 = innerProject.root
player_6.animation = innerProject.animation
player_6:setName("player_6")
player_6:setTag(64)
player_6:setCascadeColorEnabled(true)
player_6:setCascadeOpacityEnabled(true)
player_6:setPosition(724.0000, 287.9100)
layout = ccui.LayoutComponent:bindLayoutComponent(player_6)
layout:setPositionPercentX(0.5656)
layout:setPositionPercentY(0.3999)
layout:setLeftMargin(724.0000)
layout:setRightMargin(556.0000)
layout:setTopMargin(432.0900)
layout:setBottomMargin(287.9100)
innerProject.animation:setTimeSpeed(1.0000)
player_6:runAction(innerProject.animation)
Layer:addChild(player_6)

--Create btn_start
local btn_start = ccui.Button:create()
btn_start:ignoreContentAdaptWithSize(false)
btn_start:loadTextureNormal("res/widget/btn_lv.png",0)
btn_start:loadTexturePressed("res/widget/btn_lv.png",0)
btn_start:loadTextureDisabled("Default/Button_Disable.png",0)
btn_start:setTitleFontSize(14)
btn_start:setTitleColor({r = 65, g = 65, b = 70})
btn_start:setScale9Enabled(true)
btn_start:setCapInsets({x = 15, y = 11, width = 203, height = 62})
btn_start:setLayoutComponentEnabled(true)
btn_start:setName("btn_start")
btn_start:setTag(70)
btn_start:setCascadeColorEnabled(true)
btn_start:setCascadeOpacityEnabled(true)
btn_start:setPosition(640.0000, 98.2443)
layout = ccui.LayoutComponent:bindLayoutComponent(btn_start)
layout:setPositionPercentX(0.5000)
layout:setPositionPercentY(0.1365)
layout:setPercentWidth(0.1820)
layout:setPercentHeight(0.1167)
layout:setSize({width = 233.0000, height = 84.0000})
layout:setLeftMargin(523.5000)
layout:setRightMargin(523.5000)
layout:setTopMargin(579.7557)
layout:setBottomMargin(56.2443)
Layer:addChild(btn_start)

--Create Text_15
local Text_15 = ccui.Text:create()
Text_15:ignoreContentAdaptWithSize(true)
Text_15:setTextAreaSize({width = 0, height = 0})
Text_15:setFontName("fonts/mnjcy.ttf")
Text_15:setFontSize(38)
Text_15:setString([[开  始]])
Text_15:setLayoutComponentEnabled(true)
Text_15:setName("Text_15")
Text_15:setTag(76)
Text_15:setCascadeColorEnabled(true)
Text_15:setCascadeOpacityEnabled(true)
Text_15:setPosition(113.7907, 40.3550)
Text_15:setTextColor({r = 229, g = 229, b = 229})
layout = ccui.LayoutComponent:bindLayoutComponent(Text_15)
layout:setPositionPercentX(0.4884)
layout:setPositionPercentY(0.4804)
layout:setPercentWidth(0.4249)
layout:setPercentHeight(0.5238)
layout:setSize({width = 99.0000, height = 44.0000})
layout:setLeftMargin(64.2907)
layout:setRightMargin(69.7093)
layout:setTopMargin(21.6450)
layout:setBottomMargin(18.3550)
btn_start:addChild(Text_15)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(0)
result['animation']:setTimeSpeed(1.0000)
--Create Animation List

result['root'] = Layer
return result;
end

return Result

