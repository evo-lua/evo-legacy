-- Upvalues
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_running = coroutine.running
local coroutine_yield = coroutine.yield

function async(asyncFunctionToWrap, ...)
	-- In order to suspend execution, we need a coroutine that can yield as needed
	local wrappedFunction = coroutine_create(asyncFunctionToWrap)
	coroutine_resume(wrappedFunction, ...)
end

-- Only works if the current thread is running in a coroutine, so that it can be suspended
function await(wrappedAsyncFunctionToDefer)

	local currentThread = coroutine_running()
	local function onWrappedFunction

	local promise = promise.create()
	-- promise.
	coroutine_yield()
	return promise.result
end





-- TODO: Tests for this builtin
local setmetatable = setmetatable
function instantiate(prototype)
	prototype = prototype or {}

	local function onMissingKeyIndexed(_, key)
		return prototype[key]
	end

	local inheritanceLookupMetatable = {
		__index = onMissingKeyIndexed
	}

	local instance = {}
	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end



-- TODO mixin(prototype, ...) -> CreateFromMixin


local STATUS_PENDING = "Pending"
local STATUS_REJECTED = "Rejected"
local STATUS_RESOLVED = "Resolved"

local promise = {}

function promise.create()
	local instance = instantiate(promise)
	instance.status = STATUS_PENDING

	return instance
end

_G.promise = promise

local Promise = {}

function Promise:Construct()
	local instance = {}
	local currentThread = coroutine_running()
	instance.currentThread = currentThread

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

function Promise:Resolve(result)
	-- print("Resolving Promise (result: " .. result .. ")")
	DEBUG("Promise resolved")
	self.result = result
	assert(coroutine_resume(self.currentThread))
end

function Promise:Reject(message)
	error("Promise rejected!\n\nReason: " .. message)
	self.result = message
	assert(coroutine_resume(self.currentThread))
end