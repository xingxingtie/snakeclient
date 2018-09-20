local parser = require "sprotoparser"

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

local export = function(content, filepath)
	local file = io.open(filepath, "w+b")
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
	end
end

export(generate(param[1]), param[2])







