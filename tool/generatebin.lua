local parser = require "sprotoparser"
local sproto = require "sproto"

local param = {...}

local generate = function(filepath)
	print(filepath)
	
	local file = io.open(filepath, "r")
	
	if file then
		local content = file:read("*a")
        io.close(file)
        return parser.parse(content)
	end
	
	return nil
end

local exportbin = function(content, filepath)
	local file = io.open(filepath, "w+b")
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
	end
end

--生成协议号
local exportNetID = function(content, filepath)
    local file = io.open(filepath, "w+b")
    file:write("local M = {}\n\n")

    local id = 1
    for typename, t in pairs(content.type) do

        if (string.find(typename, "c2s") or string.find(typename, "s2c")) then 

            local str = string.format("M.%s = %d\n\n", typename, id)

            if file:write(str) == nil then return false end

            id = id + 1
        end
    end

    file:write("return M")

    io.close(file)
end

local content, ret = generate(param[1])

exportbin(content, param[2])
