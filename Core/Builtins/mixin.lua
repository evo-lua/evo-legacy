local pairs = pairs
local tostring = tostring
local type = type

local function copyFunctionsFromMixin(target, mixin)
	if  type(target) ~= "table" then
		WARNING("Failed to mix in functions with target " .. tostring(target) .. " (not a table)")
		return
	end

	if  type(mixin) ~= "table" then
		WARNING("Failed to copy functions from mixin " .. tostring(mixin) .. " (not a table)")
		return
	end

	for key, value in pairs(mixin) do
		if type(value) == "function" and target[key] == nil then
			target[key] = value
		end
	end
end

function mixin(target, ...)
	local tablesToMixIn = { ... }

	for _, mixin in pairs(tablesToMixIn) do
		copyFunctionsFromMixin(target, mixin)
	end
end