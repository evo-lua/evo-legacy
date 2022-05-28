assert(type(json) == "table", "The json builtin should be available")
assert(type(json.stringify) == "function", "Should expose the stringify() alias")
assert(type(json.parse) == "function", "Should expose the parse() alias")

-- We only test the community patches that weren't merged into the LuaDist repo here, since the base functionality should be mature

-- Source: https://github.com/LuaDist/dkjson/pull/3 (author: Cr4xy)
local jsonString = json.encode({A = 0, B = false, C = 0}, {keyorder = {"B", "A", "C"}})
local expectedJsonString = '{"B": false,"A": 0,"C": 0}'
assert(jsonString == expectedJsonString, "Should order false values correctly when a key order is given")
-- LPEG is a Luvi builtin, so there's really no reason to not use it
assert(json.using_lpeg == true, "Should be using the LPEG extension to improve performance")

-- By default, it indents everything with two spaces (gross :/)
jsonString = json.stringify({ A = 42, B = 123}, { indent = true, keyorder = { "A", "B" } })
local properlyIndentedJsonString = "{\n\t\"A\": 42,\n\t\"B\": 123\n}"
assert(jsonString == properlyIndentedJsonString, "Should indent stringified JSON with tabs and not spaces")

print("OK\tBuiltins\tjson")