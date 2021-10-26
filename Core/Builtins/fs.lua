local fs = import("@creationix/coro-fs/coro-fs.lua")

local function fsModuleLoader(moduleName)
	return fs
end

package.preload["fs"] = fsModuleLoader