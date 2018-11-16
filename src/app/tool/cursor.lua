--光标 单行文本输入时会用到

local M = {}

function M._textFieldEventHandler(event)
    local textField = event.target

    if event.name == "ATTACH_WITH_IME" then 
        textField.cursor:setVisible(true)
        textField.cursorAnimation:resume()

    elseif event.name == "DETACH_WITH_IME" then 
        textField.cursor:setVisible(false)
        textField.cursorAnimation:resume()

    elseif event.name == "INSERT_TEXT" or event.name == "DELETE_BACKWARD" then 
        local ifPasswordMode = textField:isPasswordEnabled()
        if ifPasswordMode then   --密码模式
            local strLen = string.len(textField:getString())
            textField.refLabel:setString(string.rep(".", strLen))
        else 
            textField.refLabel:setString(textField:getString())
        end

        textField.cursor:setPositionX(
            textField.refLabel:getContentSize().width + 3)
    end
end

--refLabel用来计算实际的文本长度
function M.attachCusor(textField, refLabel)

    local effectNode = require("ui.effect_cursor").create()

    local animation = effectNode["animation"] 
    effectNode.root:runAction(animation)
    animation:gotoFrameAndPlay(1, true)
    animation:pause()
  
    effectNode = effectNode.root
    effectNode:setCascadeOpacityEnabled(true)
    effectNode:setVisible(false)

    textField.refLabel = refLabel
    textField.cursor = effectNode 
    textField.cursorAnimation = animation
    textField:addChild(effectNode)
  
    textField:onEvent(M._textFieldEventHandler)
end

return M