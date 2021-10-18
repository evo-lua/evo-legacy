local bundledModule = {
	someField = 42
}

local uv = require("uv")

local moduleWithParent, absolutePath, parentModule = import("module-with-parent.lua")
assert(type(moduleWithParent) == "table", "moduleWithParent is not a table")
local expectedAbsolutePath = path.join(uv.cwd(), "module-with-parent.lua")
assert(absolutePath == expectedAbsolutePath, "moduleWithParent's absolute path is not " .. expectedAbsolutePath)
local selfPath = path.join(uv.cwd(), "bundled-module.lua")
assert(parentModule == selfPath, parentModule .. " IS NOT " .. selfPath)


return bundledModule