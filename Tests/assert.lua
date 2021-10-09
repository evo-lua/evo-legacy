local format = string.format

function _G.assertStrictEqual(actual, expected)
	if actual ~= expected then
		print(format("FAIL\t%s IS NOT %s (%s)", actual, expected,  _G.currentNamespace))
		error(format("\nExpected %s, actual: %s", expected, actual) .. "\n" .. debug.traceback())
	end
	print(format("PASS\t%s IS %s (%s)", actual, expected,  _G.currentNamespace))
end