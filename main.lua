-- TODO: Do not hardcode this
EVO_VERSION_STRING = "0.0.1"

-- Expose the top-level module container so packages can access it from anywhere
Evo = {
	version = EVO_VERSION_STRING
}


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

function Evo:LoadBuiltins()
	import("Core/Builtins/aliases")
	import("Core/Builtins/log")
end

Evo:LoadBuiltins()
Evo:ProcessUserInput()
