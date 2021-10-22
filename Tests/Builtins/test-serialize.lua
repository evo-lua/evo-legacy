assert(type(serialize) == "function", "The serialize builtin should be available")

local someFunction = function() return "Simple functions can be deserialized via loadstring()" end
local someTable = {
	someField = 42,
	test = "Hello",
	"test"
}

assert(loadstring(serialize(nil))() == nil, "Should be able to serialize nil")
assert(loadstring(serialize(42))() == 42, "Should be able to serialize numbers")
assert(loadstring(serialize("Hello"))() == "Hello", "Should be able to serialize strings")
assert(loadstring(serialize(someFunction))()() == someFunction(), "Should be able to serialize simple functions")
assert(loadstring(serialize(someTable))().someField == someTable.someField, "Should be able to serialize simple tables")

print("OK\tBuiltins\tserialize")