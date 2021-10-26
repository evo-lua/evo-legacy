assert(type(json) == "table", "The json builtin should be available")
assert(type(json.stringify) == "function", "Should expose the stringify() alias")
assert(type(json.parse) == "function", "Should expose the parse() alias")

-- LPEG is a Luvi builtin, so there's really no reason to not use it
assert(json.using_lpeg == true, "Should be using the LPEG extension to improve performance")

print("OK\tBuiltins\tjson")