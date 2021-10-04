-- TODO: Do not hardcode this
EVO_VERSION_STRING = "0.0.1"

-- Expose the top-level module container so packages can access it from anywhere
Evo = {
	version = EVO_VERSION_STRING
}

-- Set up the global environment
printf = require("Core/Environment/printf")

-- LuaJIT API
local ffi = require("ffi")

function Evo:DisplayHelpText()
	printf("Welcome to Evo.lua v%s on %s-%s!", EVO_VERSION_STRING, ffi.os, ffi.arch)
	print()
	print("There's no interactive shell (REPL) currently,\nbut you can run any Lua script as you would expect:")
	print()
	print("evo myScript.lua [optional command line arguments go here]")
end

Evo:DisplayHelpText()