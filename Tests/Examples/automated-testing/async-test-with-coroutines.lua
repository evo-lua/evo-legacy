-- To demonstrate the effect, this scenario uses libuv primitives directly
local uv = require("uv")

local scenario = Scenario:Construct("Asynchronous Test with Coroutines")

function scenario:OnSetup()
	print("[OnSetup] Storing the running coroutine")
	self.currentThread = coroutine.running() -- Your program/the "user script" is stored here
end

function scenario:OnRun()
	print("[OnRun] Queueing asynchronous I/O request")

	local function onAsyncRequestCompleted(errorMessage)
		print("[Callback] The asynchronous I/O request completed (with or without errors)")
		-- Error handling etc. goes here (omitted for brevity)

		if type(errorMessage) == "string" then
			print("[Callback] Oh no! There was an error:\n\t" .. errorMessage)
		end

		print("[Callback] Resuming the current thread")
		coroutine.resume(self.currentThread) -- Pick up the paused thread and continue with running your test
	end
	uv.fs_open("testfile.txt", "r", 438, onAsyncRequestCompleted) -- This will error if the file doesn't exist, but that's OK

	print("[OnRun] Pausing the current thread")
	coroutine.yield() -- Interrupts execution, to be continued later
	print("[OnRun] Execution continues after the yield")
end

return scenario