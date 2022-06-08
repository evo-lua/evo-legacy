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

function Evo:LoadDefaultSettings()
	_G.ENABLE_TEXT_TRANSFORMATIONS = true
end

function Evo:LoadBuiltins()
	import("Core/Builtins/assertions")
	import("Core/Builtins/aliases")
	import("Core/Builtins/event")
	import("Core/Builtins/fs")
	import("Core/Builtins/json")
	import("Core/Builtins/log")
	import("Core/Builtins/serialize")
	import("Core/Builtins/transform")
end

function Evo:LoadStandardLibraryExtensions()
	import("Core/Extensions/table")
end

function Evo:ExportHighLevelAPI()
	import("Core/API/C_EventLoop")
	import("Core/API/C_FileSystem")
	import("Core/API/C_Testing")
end

function Evo:ExportSharedConstants()
	import("Core/SharedConstants.lua")
end

function Evo:ExportPrimitives()
	import("Core/Primitives/Scenario.lua")
	import("Core/Primitives/TestSuite.lua")
end

local math_max = math.max

function Evo:StartEventLoop()
	local timeSinceLastUpdate = uv.hrtime()
	-- This allows applications to queue non-libuv tasks via event.register("EVENT_LOOP_UPDATE")
	if C_EventLoop.HasAsyncTasks() then
		local externalTaskTicker = uv.new_idle()
		externalTaskTicker:start(function()
			C_EventLoop.RunAsyncTasks()
			event.trigger("EVENT_LOOP_UPDATE")

			if not C_EventLoop.HasAsyncTasks() then
				-- The last task just finished, kill the handle to exit the program
				DEBUG("No more async tasks are scheduled, exiting...")
				externalTaskTicker:stop()
			else -- Must update external poll timers etc. while some are registered
				timeSinceLastUpdate = (uv.hrtime() - timeSinceLastUpdate) / 10E6 -- hr time in ns, sleep time in ms
				local sleepTime = math_max(POLL_TIME_IN_MILLISECONDS - timeSinceLastUpdate, 0) -- todo C_EventLoop.SetTickTime(20)
				-- DEBUG("Sleeping for " .. sleepTime .. " ms (last update: " .. timeSinceLastUpdate .. " ms)")
				uv.sleep(sleepTime)
				timeSinceLastUpdate = uv.hrtime()
			end
			end)
	end

	-- Exits immediately if there are no handles
	uv.run()
end

Evo:LoadDefaultSettings()
Evo:LoadBuiltins()
Evo:LoadStandardLibraryExtensions()
Evo:ExportSharedConstants()
Evo:ExportPrimitives()
Evo:ExportHighLevelAPI()

Evo:ProcessUserInput()

Evo:StartEventLoop()
