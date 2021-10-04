local serpent = require("../../Libs/serpent")

local dumpOptions = {
	compact = false, -- Do not remove spaces
	sortkeys = true, -- Display keys in lexicographical order (probably has some performance impact)
	indent = '  ', -- In a console window, tabs would take too much space
	fatal = false, -- Raise fatal error on non-serilizable value
	nocode = true, -- Replace bytecode loadstring with skipped comment (empty function body)

	-- Custom addition: Print function address (Lua print style)
	-- Note: This breaks serialization (non-reversible conversion) and is intended for human-readable dumps only
	convertFunctionsToStrings = true,
}

-- Upvalues
local print = print
local serpent_dump = serpent.dump
local string_gsub = string.gsub

function dump(object, stripBoilerplate)
	stripBoilerplate = (stripBoilerplate == nil) or true
	local serializedString = serpent_dump(object, dumpOptions)

	if not stripBoilerplate then
		print(serializedString)
	end

	-- Since dumps must be importable, serpent adds some clutter to enable this
	-- Unfortunately that makes it less readable, so let's remove it
	local serializationPrefix = "do local _ = "
	local serializationSuffix = "return _\nend"
	serializedString = string_gsub(serializedString, serializationPrefix, "")
	serializedString = string_gsub(serializedString, serializationSuffix, "")
	print(serializedString)
end

return dump