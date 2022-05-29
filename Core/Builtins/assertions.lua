-- TODO tests for this entire module

local error = error
local type = type

function assertEquals(actual, expected)

	if actual == "" then actual = "<empty string>" end
	if expected == "" then expected = "<empty string>" end

	actual = transform.bold(actual)
	expected = transform.bold(expected)

	if actual ~= expected then
		error(transform.red("\n\nASSERTION FAILURE:\n\n" .. tostring(actual) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. tostring(expected) .. "\n"))
	end
	-- assert(actual == expected, "Expected " .. tostring(actual) .. " to be " .. tostring(expected))
end

function assertFalse(conditionToCheck)
	if conditionToCheck then
		error(transform.red("\n\nASSERTION FAILURE:\n\n" .. transform.bold(tostring(conditionToCheck)) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. transform.bold("false") .. "\n"))
	end
end

function assertTrue(conditionToCheck)
	if not conditionToCheck then
		error(transform.red("\n\nASSERTION FAILURE:\n\n" .. transform.bold(tostring(conditionToCheck)) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. transform.bold("true") .. "\n"))
	end
end

-- function assertTypeOf(value, expectedType)

-- 	local actualType = type(value)

-- 	 value = transform.bold(value)
-- 	 actualType = transform.bold(actualType)
-- 	 expectedType = transform.bold(expectedType)

-- 	 if actualType ~= expectedType then
-- 		 error(transform.red("\n\nASSERTION FAILURE:\nType of\n\n\t" .. tostring(value) .. "\n\nIS\n\n\t" .. actualType .. "\n\n") .. transform.red("SHOULD BE\n\n" .. tostring(expectedType) .. "\n"))
-- 	 end
-- end

_G.assertEquals = assertEquals
_G.assertFalse = assertFalse
_G.assertTrue = assertTrue

-- _G.assertTypeOf = assertTypeOf