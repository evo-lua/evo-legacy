-- TODO tests for this entire module

local error = error
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

		ERROR(transform.red("\n\nASSERTION FAILURE:\n\n" .. actual .. "\n\n") .. transform.red("SHOULD BE\n\n" .. expected .. "\n"))
		assert(actual == expected, description)

	end
end

function assertFalse(conditionToCheck, description)
	if conditionToCheck then
		ERROR(transform.red("\n\nASSERTION FAILURE:\n\n" .. transform.bold(tostring(conditionToCheck)) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. transform.bold("false") .. "\n"))
		assert(not conditionToCheck, description)
	end
end

function assertTrue(conditionToCheck, description)
	if not conditionToCheck then
		ERROR(transform.red("\n\nASSERTION FAILURE:\n\n" .. transform.bold(tostring(conditionToCheck)) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. transform.bold("true") .. "\n"))
		assert(conditionToCheck, description)
	end
end

_G.assertEquals = assertEquals
_G.assertFalse = assertFalse
_G.assertTrue = assertTrue