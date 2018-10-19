local Node = cc.Node


function Node:toast(str, ...)
    local formatStr = string.format(str, ...)

    print("formatStr", formatStr)

    local label = cc.Label:createWithSystemFont(formatStr, "Arial", 36)
        :move(display.cx, display.cy)
        :addTo(self, 10000)
        :moveBy({x = 0, y = 100, time = 1})
        :fadeOut({time = 1})

    label:callAfter(1, function() label:removeFromParent() end)
    
    return label
end

