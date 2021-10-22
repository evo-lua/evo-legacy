local serpent = import("../../Libs/serpent.lua")

local dumpOptions = {
	compact = true, -- Remove spaces
	fatal = true, -- Raise fatal error on non-serilizable value
}

-- Upvalues
local serpent_dump = serpent.dump

function serialize(object)
	return serpent_dump(object, dumpOptions)
end

return serialize