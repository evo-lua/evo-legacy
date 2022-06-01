


-- Assertions that don't fail should do nothing
	assertEquals(1, 1, "1 should be 1")
	-- Failed assertion handlers should call the default ERROR builtin

local originalErrorHandler = _G.ERROR

local wasErrorHandlerCalled = false
local lastErrorMessage = nil
local function fauxErrorHandler(message)
	wasErrorHandlerCalled = true
	lastErrorMessage = message
	originalErrorHandler(message) -- Forward transparently for easier debugging of assertion failures in this test
end

_G.ERROR = fauxErrorHandler

pcall(assertEquals, 1, 2, "1 should be 2") -- Need to avoid triggering errors here since we're intercepting them (awkward)
assertTrue(wasErrorHandlerCalled, "Should call the default ERROR handler on assertion failure")

-- There's a bit of an assertion-ception problem here, but that's merely an inconvenience
local expectedText = transform.red("ASSERTION FAILURE: ") .. "Expected inputs to be equal (" .. transform.bold("1") .. " should be " .. transform.bold("2") .. ")" .. "\n"

assertEquals(lastErrorMessage, expectedText, "Should pass an error message describing the assertion failure to the ERROR handler")

_G.ERROR = originalErrorHandler

print("OK\tBuiltins\tassertions")