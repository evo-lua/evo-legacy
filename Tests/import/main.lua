

print("This is the bundle's entry point")

-- TODO Move test to evo-luvi and use the existing assertion utilities
-- TODO Add CI workflow for this test

-- assert path is string
-- if absolutePath exists in cache, load from cache
-- If relativePath exists in bundle, then load from bundle?
-- assert file exists on disk
-- if absolutePath exists on disk, load module from it
local uv = require("uv")

local moduleCache = {}
local prefixStack = {}

function import(modulePath)
	print("Dumping prefix stack...")
	dump(prefixStack)

	local cwd = uv.cwd()
	local scriptPath = path.resolve(path.join(cwd, scriptFile)) -- Remove the operators if they're present
	local scriptDirectory = path.dirname(scriptPath) -- Remove the file name to get the script's "cwd" even if cwd is elsewhere
	local scriptFile = args[1] or "main.lua" -- Will include the .. operator if it isn't the bundle's root file (on disk)

	-- print("Source: " .. source)
	print("Script file: " .. scriptFile)
	print("Script path: " .. scriptPath)
	print("Script directory: " .. scriptDirectory)

	-- If no parent chain existed, use the main entry point instead
	local parentModule = (#prefixStack == 0) and scriptFile or prefixStack[#prefixStack] -- It must be the entry point (top-level module)

	local parentDirectory = path.dirname(parentModule)
	local absolutePath = path.resolve(path.join(parentDirectory, modulePath))

	print("Importing from path: " .. parentDirectory .. "/" .. modulePath)
	print("Resolved to: " .. absolutePath)

	print("Parent directory for this import: " .. parentDirectory)

	local cachedModule = moduleCache[absolutePath]
	if cachedModule then
		-- Nested imports can't happen here, so we don't need to update the prefix stack
		print("Returning from module cache...")
		return cachedModule, absolutePath, parentModule
	end

	-- By always pushing the latest prefix before loading, the context can be reconstructed from inside the nested import call
	prefixStack[#prefixStack+1] = absolutePath

	print("Dumping prefix stack...")
	dump(prefixStack)

	print("Loading from disk...")
	local loadedModule = dofile(absolutePath)

	if (#prefixStack > 0) then
		-- This must be a nested call, so we want to clear out the parent hierarchy before exiting
		local removedParent = table.remove(prefixStack)
		print("Removed parent element from prefix stack: " .. removedParent)
	end

	print("Cached new module: " .. absolutePath)
	moduleCache[absolutePath] = loadedModule

	return loadedModule, absolutePath, parentModule
end

-- A module in the same folder can be loaded as-is
local bundledModule = import("bundled-module.lua")
assert(type(bundledModule) == "table", "Type of bundledModule is not table")
assert(bundledModule.someField == 42, "bundledModule.someField is not 42")

-- After a module has been loaded, it is cached and won't be reloaded from disk
bundledModule.isLoaded = true
assert(bundledModule.isLoaded == true, "bundledModule is loaded")
local reimportedModule, absolutePath, parentModule = import("bundled-module.lua")
assert(reimportedModule == bundledModule, "The re-imported module isn't retrieved from cache")
assert(reimportedModule.isLoaded == true, "reimportedModule is also loaded")

-- The path should be resolved directly from the entry point
local expectedAbsolutePath = path.join(uv.cwd(), "bundled-module.lua")
assert(absolutePath == expectedAbsolutePath, absolutePath .. " IS NOT " .. expectedAbsolutePath)

-- The parent should be the module that imported it, i.e. the main/entry point
assert(parentModule == "main.lua", tostring(parentModule) .. " IS NOT " .. "main.lua")


-- The main module has no parent module (since it's not imported anywhere else, hopefully)

-- When a module is loaded from another file, its parent is set to the module that imported it
