-- TODO: Do not hardcode this
EVO_VERSION_STRING = "0.0.1"

-- Expose the top-level module container so packages can access it from anywhere
Evo = {
	version = EVO_VERSION_STRING
}

PACKAGE_IMPORT_DIR = ".packages" -- Can change at runtime (global scope) by re-assigning

local uv = require("uv")

-- Set up the global environment
-- InitializeGlobalEnvironment()
-- TBD: Move to evo-luvi?
local luvi = require('luvi')
local bundle = luvi.bundle

-- High-level wrapper for Luvi's builtin bundling API (virtual file system)
local VFS = {}

function VFS:HasFile(filePath)
	local fileStats = bundle.stat(filePath)
	if fileStats and fileStats.type == "file" then return true end
end

function VFS:ReadFile(filePath)
	print("Reading file from bundle VFS: " .. filePath)
	local fileContents = bundle.readfile(filePath)
	local compiledChunk = loadstring(fileContents)()
	return compiledChunk
end

local uv = require("uv")
local moduleCache = {}

local function loadModule(modulePath, parentScriptPath, isEntryPoint)
	local scriptFile = args[1] or "main.lua" -- Will include the .. operator if it isn't the bundle's root file (on disk)

end

function import(modulePath)
	print(args[0], args[1])

	if type(modulePath) ~= "string" then
		return nil, "Usage: import(modulePath)"
	end
	local cwd = uv.cwd()

	local source =  debug.getinfo(1,"S").source:gsub("bundle:", "") -- Remove Luvi's prefix since we can't resolve paths otherwise
	local scriptFile = args[1] or "main.lua" -- Will include the .. operator if it isn't the bundle's root file (on disk)
	local scriptPath = path.resolve(path.join(cwd, scriptFile)) -- Remove the operators if they're present
	local scriptDirectory = path.dirname(scriptPath) -- Remove the file name to get the script's "cwd" even if cwd is elsewhere
	print("Source: " .. source)
	print("Script file: " .. scriptFile)
	print("Script path: " .. scriptPath)
	print("Script directory: " .. scriptDirectory)

	local absolutePath = path.resolve(path.join(cwd, modulePath))

	print("Importing from path: " .. cwd .. "/" .. modulePath)
	print("Resolved to: " .. absolutePath)

	local cachedModule = moduleCache[absolutePath]
	if cachedModule then
		print("Returning from module cache...")
		return cachedModule
	end

	if VFS:HasFile(modulePath) then
		print("Loading from the bundle's virtual file system")
		return VFS:ReadFile(modulePath)
	end

	print("Loading from disk...")

	local loadedModule = dofile(absolutePath)
	print(loadedModule)
	moduleCache[absolutePath] = loadedModule
	return loadedModule
end

-- Scenarios

-- circular import
-- import from cwd, .., another folder
-- import from another DISK (oh no)
-- import from lit package (deps/libs)
-- import from luarocks package (??)
-- import from epo package - .epo (??)

import("TestModule.lua")
import("TestModule.lua")
import("TestModule.lua")

_G.printf = import("Core/Environment/printf.lua")
_G.serialize = import("Core/Environment/serialize.lua")

-- TriggerEvent("APPLICATION_STARTUP")

-- LuaJIT API
local ffi = require("ffi")

function Evo:ProcessUserInput()
	-- There's always one argument, the runtime itself (but it's stored at index "0", so Lua doesn't count it)
	local hasCommandLineArguments = (#args > 0)
	if not hasCommandLineArguments then
		Evo:DisplayHelpText()
		return
	end

	local scriptFile = args[1]
	dofile(scriptFile) -- args is global, so there's no need to pass it along
end

function Evo:DisplayHelpText()
	printf("Welcome to Evo.lua v%s on %s-%s!", EVO_VERSION_STRING, ffi.os, ffi.arch)
	print()
	print("There's no interactive shell (REPL) currently,\nbut you can run any Lua script as you would expect:")
	print()
	print("evo myScript.lua [optional command line arguments go here]")
end

Evo:ProcessUserInput()

-- dump(path)

-- TriggerEvent("EVENT_LOOP_START")
-- TriggerEvent("EVENT_LOOP_END")


-- TriggerEvent("APPLICATION_SHUTDOWN")