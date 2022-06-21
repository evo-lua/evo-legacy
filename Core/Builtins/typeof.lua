local type = type

local function typeof(object)
	if type(object) ~= "table" then return type(object) end

	if type(object.__className) ~= "string" then return type(object) end

	return object.__className
end

_G.typeof = typeof