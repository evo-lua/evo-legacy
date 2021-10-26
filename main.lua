local Evo = {}

local uv = require("uv")
local ffi = require("ffi")

-- TODO: Add as optional debug helper, only loaded if DEBUG_COROUTINES is true
local threads = {} -- todo remove threads when they're dead
function coroutine.setname(thread, label)
	DEBUG(format("Tagged coroutine %s as %s", thread, label))
	threads[thread] = label
end

function coroutine.getname(thread)
	return threads[thread] or "<anonymous>"
end

-- local coroutine_status = coroutine.status
-- function coroutine.status(thread)
-- 	DEBUG(format("Status of coroutine %s IS %s", threads[thread], string.upper(coroutine_status(thread))))
-- 	return coroutine_status(thread)
-- end

local coroutine_yield = coroutine.yield
function coroutine.yield(...)
	local thread = coroutine.running()
	DEBUG(format("Coroutine %s is now YIELDING", threads[thread]))
	return coroutine_yield(thread, ...)
end

local coroutine_resume = coroutine.resume
function coroutine.resume(thread, ...)
	DEBUG(format("Coroutine %s is now RESUMING", threads[thread]))
	return coroutine_resume(thread, ...)
end

function coroutine.dump()
	for thread, label in pairs(threads) do
		DEBUG(format("Coroutine %s IS %s", label, string.upper(coroutine.status(thread))))
	end
end

function Evo:ProcessUserInput()
	-- There's always one argument, the runtime itself (but it's stored at index "0", so Lua doesn't count it)
	local hasCommandLineArguments = (#args > 0)
	if not hasCommandLineArguments then
		self:DisplayHelpText()
		return
	end

	local scriptFile = args[1]
	local userscript = function()
		local compiledChunk = loadfile(scriptFile)
		assert(compiledChunk, "Failed to load user script " .. tostring(scriptFile))
		compiledChunk()
	 end

	local userScript = coroutine.create(userscript)
	coroutine.setname(userScript, "userScript")
	local mainThread, isMain = coroutine.running()
	coroutine.setname(mainThread, "mainThread")
	local ranWithoutErrors, errorMessage = coroutine.resume(userScript)
	errorMessage = errorMessage or "<Mo message was provided by the script>"

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
	import("Core/Builtins/json")
	import("Core/Builtins/log")
	import("Core/Builtins/serialize")
end

function Evo:ExportSharedConstants()
	import("Core/SharedConstants.lua")
end

function Evo:StartEventLoop()
	uv.run()
end

Evo:LoadBuiltins()
Evo:ExportSharedConstants()

Evo:ProcessUserInput()

Evo:StartEventLoop()
