

function _G.assertStrictEqual(actual, expected)
	if actual ~= expected then
		print("FAIL\t" .. actual .. " IS " .. expected .. " (" .. _G.currentNamespace .. ")")
		error(format("\nExpected %s, actual: %s", expected, actual) .. "\n" .. debug.traceback())
	end
	print("PASS\t" .. actual .. " IS " .. expected .. " (" .. _G.currentNamespace .. ")")
end