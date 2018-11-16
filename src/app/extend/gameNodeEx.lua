local errorCode = require("proto.errorCode")

local Node = cc.Node

--飘字
function Node:toast(str, ...)

    local scene = display.getRunningScene()
    if not scene.toastNum then 
        scene.toastNum = 0
    end
    
    local formatStr = string.format(str, ...)
    
    --新建一个toast
    local newToast = function()  
        scene.toastNum = scene.toastNum - 1

        local label = cc.Label:createWithSystemFont(formatStr, "Arial", 36)
            :move(display.cx, display.cy)
            :addTo(scene, 10000)
            :moveBy({x = 0, y = 100, time = 1})
            :fadeOut({time = 1})
            :callAfter(1, function() 
                self:removeFromParent()    
            end)
    end

    display.getRunningScene():callAfter(
        0.3 * scene.toastNum, 
        newToast)

    scene.toastNum = scene.toastNum + 1
end

--飘错误码
function Node:toastErrorCode(error)
    self:toast(errorCode[error])
end
