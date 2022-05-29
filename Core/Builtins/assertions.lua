
-- TODO tests for this
function assertEquals(actual, expected)

	if actual == "" then actual = "<empty string>" end
	if expected == "" then expected = "<empty string>" end

	actual = transform.bold(actual)
	expected = transform.bold(expected)

	if actual ~= expected then
		error(transform.red("\n\nASSERTION FAILURE:\n\n\t" .. tostring(actual) .. "\n\n") .. transform.red("SHOULD BE\n\n" .. tostring(expected) .. "\n"))
	end
	-- assert(actual == expected, "Expected " .. tostring(actual) .. " to be " .. tostring(expected))
end

_G.assertEquals = assertEquals