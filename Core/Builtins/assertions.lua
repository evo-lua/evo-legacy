local tostring = tostring

function assertEquals(actual, expected, description)

	if actual == "" then actual = "<empty string>" end
	if expected == "" then expected = "<empty string>" end

	if actual ~= expected then

		actual = tostring(actual)
		expected = tostring(expected)

		actual = transform.bold(actual)
		expected = transform.bold(expected)

		description = description or actual .. " is not " ..  expected

		local errorMessage = transform.red("ASSERTION FAILURE: ") .. "Expected inputs to be equal" .. " "
			.. "(" .. actual .. " should be " .. expected .. ")" .. "\n"
		ERROR(errorMessage)
	end
	assert(actual == expected, description)
end

function assertFalse(conditionToCheck, description)
	-- Taking the lazy way out here until requirements demand more sophistication
	assertEquals(conditionToCheck, false, description)
end

function assertTrue(conditionToCheck, description)
	-- Taking the lazy way out here until requirements demand more sophistication
	assertEquals(conditionToCheck, true, description)
end

function assertFunctionCalls(codeUnderTest, hostTable, targetFunctionName, numExpectedInvocations, description)
	numExpectedInvocations = numExpectedInvocations or 1

	local backupFunctionToCall = hostTable[targetFunctionName]
	local numActualInvocations = 0

	local function spy(...)
		numActualInvocations = numActualInvocations + 1
		DEBUG("Spy called for function " .. targetFunctionName)
		backupFunctionToCall(...)
	end

	-- Must restore before asserting anything or unrelated tests may break
	hostTable[targetFunctionName] = spy
	codeUnderTest() -- Should call target function x times
	hostTable[targetFunctionName] = backupFunctionToCall

	assert(numActualInvocations == numExpectedInvocations, description)

end

function assertThrows(codeUnderTest, expectedErrorMessage, description)

	local numErrors = 0
	local lastErrorMessage = nil
	local function errorHandler(errorMessage)
		numErrors = numErrors + 1
		lastErrorMessage = errorMessage
		print("error handler in assertThrows", errorMessage)
	end

	local success, errorMessage = pcall(codeUnderTest, errorHandler)
print("assertThrows->success", success)
print("assertThrows->errorMessage", errorMessage)
	-- assert(numErrors == 1)
	-- local globalErrorHandler = _G.ERROR
	-- local numErrors = 0
	-- local lastErrorMessage = nil
	-- _G.ERROR = function(errorMessage)
	-- 	numErrors = numErrors + 1
	-- 	lastErrorMessage = errorMessage
	-- end

	-- _G.ERROR = globalErrorHandler
		assert(not success, description)
		assert(errorMessage == expectedErrorMessage, description)
	-- assertEquals(numErrors, 1, "Should raise an error")
	-- assert(numErrors == 1 and lastErrorMessage == expectedErrorMessage, description)
end

_G.assertEquals = assertEquals
_G.assertFalse = assertFalse
_G.assertTrue = assertTrue
_G.assertFunctionCalls = assertFunctionCalls
_G.assertThrows = assertThrows
