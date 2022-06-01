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
		assert(actual == expected, description)

	end
end

function assertFalse(conditionToCheck, description)
	-- Taking the lazy way out here until requirements demand more sophistication
	assertEquals(conditionToCheck, false, description)
end

function assertTrue(conditionToCheck, description)
	-- Taking the lazy way out here until requirements demand more sophistication
	assertEquals(conditionToCheck, true, description)
end

_G.assertEquals = assertEquals
_G.assertFalse = assertFalse
_G.assertTrue = assertTrue