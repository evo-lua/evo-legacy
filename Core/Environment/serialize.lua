local serpent = require("../../Libs/serpent")

-- Upvalues
local serpent_dump = serpent.dump

function serialize(object)
	return serpent_dump(object)
end

return serialize