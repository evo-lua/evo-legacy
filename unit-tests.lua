require 'busted.runner'()

-- The busted runner seems to export these for the current script only. Requiring it in every file is too annoying
_G.describe = describe
_G.it = it

import("./Tests/Extensions/table.spec.lua")
