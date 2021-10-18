

local serpent = import("../Libs/serpent.lua")

-- Upvalues
local serpent_dump = serpent.dump

function serialize(object)
	return serpent_dump(object)
end

return serialize