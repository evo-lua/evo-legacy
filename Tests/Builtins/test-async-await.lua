assert(type(async) == "function", "The async builtin should be available")
assert(type(await) == "function", "The await builtin should be available")
assert(type(promise) == "table", "The promise builtin should be available")

local hasDeferredFunctionBeenCalled = false
local function functionToDefer()
	hasDeferredFunctionBeenCalled = true
end

async(functionToDefer)


assert(hasDeferredFunctionBeenCalled == false, "Should not call the deferred function before the promise was resolved")

-- We'll have to simulate resolving the promise since there's no async I/O waiting for callbacks happening here
local uv = require("uv")
local promiseResolveTimer = uv.new_timer()
local function resolvePromise()
	print("Resolving promise (timer elapsed)")

	promise:resolve()
	promiseResolveTimer:stop()
	promiseResolveTimer:close()

	print("Await finished (its promise should be resolved now)")

	assert(promise:isResolved(), "Should update the Promise with it after it was resolved")
	assert(hasDeferredFunctionBeenCalled, "Should call the deferred function after the promise was resolved")

end

promiseResolveTimer:start(1000, 0, resolvePromise)

print("Awaiting deferred function call")
local promise = await(promise)
dump(promise)
assert(promise:isPending(), "Should initialize the Promise with status PENDING")


print("OK\tBuiltins\tasync-await")
