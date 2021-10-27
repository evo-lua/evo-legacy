local Evo = {}

local uv = require("uv")
local ffi = require("ffi")

function Evo:ProcessUserInput()
	-- There's always one argument, the runtime itself (but it's stored at index "0", so Lua doesn't count it)
	local hasCommandLineArguments = (#args > 0)
	if not hasCommandLineArguments then
		self:DisplayHelpText()
		return
	end

	local scriptFile = args[1]
	-- Run user scripts in a coroutine so it can yield() for sequential but non-blocking I/O
	local runUserScript = function()
		-- Since user scripts will yield whenever they call into asynchronous APIs, we can't use dofile here
		-- dofile would run the chunk in C land and cause  an "attempt to yield across C-call boundary" error
		local compiledChunk = loadfile(scriptFile)
		assert(compiledChunk, "Failed to load user script " .. tostring(scriptFile))
		compiledChunk()
	end

	local userScript = coroutine.create(runUserScript)
	local ranWithoutErrors, errorMessage = coroutine.resume(userScript)
	errorMessage = errorMessage or "<No message was provided by the script>"

	-- We want to assert this here in order to ensure the runtime never exits without indicating EXIT_FAILURE
	local formattedErrorMessage = format("Oh no! I've encountered an error while running %s :(\n%s", scriptFile, errorMessage)
	assert(ranWithoutErrors, formattedErrorMessage)
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
	import("Core/Builtins/fs")
	import("Core/Builtins/json")
	import("Core/Builtins/log")
	import("Core/Builtins/serialize")
end

function Evo:LoadStandardLibraryExtensions()
	import("Core/Extensions/table")
end

function Evo:ExportHighLevelAPI()
	import("Core/API/C_FileSystem")
end

function Evo:ExportSharedConstants()
	import("Core/SharedConstants.lua")
end

function Evo:StartEventLoop()
	uv.run()
end

Evo:LoadBuiltins()
Evo:LoadStandardLibraryExtensions()
Evo:ExportHighLevelAPI()
Evo:ExportSharedConstants()

Evo:ProcessUserInput()

Evo:StartEventLoop()
